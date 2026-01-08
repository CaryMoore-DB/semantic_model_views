-- ============================================================================
-- Insurance Analytics - Delta Live Tables Pipeline (SQL)
-- ============================================================================
-- 
-- This SQL file creates all dimension and fact tables for the insurance 
-- analytics star schema using DLT's native SCD Type 2 support.
-- 
-- Architecture:
--   - Source: PCDM tables in cmoore_user.pcdm_test
--   - Target: Star schema with SCD Type 2 dimensions using APPLY CHANGES INTO
--   - Hierarchy: Group (1:Many) -> Policy (1:Many) -> Risk
--   - Grouping resolved through party_relationship table
-- 
-- ============================================================================

-- ============================================================================
-- DIMENSION TABLES WITH SCD TYPE 2
-- ============================================================================

-- ----------------------------------------------------------------------------
-- dim_date - Date Dimension (Type 1 - Static)
-- ----------------------------------------------------------------------------

CREATE OR REFRESH MATERIALIZED VIEW dim_date (
  CONSTRAINT valid_date_key EXPECT (date_key IS NOT NULL),
  CONSTRAINT valid_full_date EXPECT (full_date IS NOT NULL)
)
COMMENT "Date dimension with calendar attributes"
AS
SELECT
  CAST(date_format(date_seq, 'yyyyMMdd') AS INT) as date_key,
  date_seq as full_date,
  year(date_seq) as year,
  quarter(date_seq) as quarter,
  month(date_seq) as month,
  dayofmonth(date_seq) as day,
  dayofweek(date_seq) as day_of_week,
  weekofyear(date_seq) as week_of_year,
  date_format(date_seq, 'MMMM') as month_name,
  date_format(date_seq, 'EEEE') as day_name,
  CASE WHEN dayofweek(date_seq) IN (1, 7) THEN 1 ELSE 0 END as is_weekend,
  CASE 
    WHEN month(date_seq) IN (1,2,3) THEN 'Q1'
    WHEN month(date_seq) IN (4,5,6) THEN 'Q2'
    WHEN month(date_seq) IN (7,8,9) THEN 'Q3'
    ELSE 'Q4'
  END as quarter_name
FROM (
  SELECT explode(sequence(to_date('2020-01-01'), to_date('2030-12-31'), interval 1 day)) as date_seq
);

-- ----------------------------------------------------------------------------
-- dim_group - Group Dimension (SCD Type 1 with APPLY CHANGES)
-- ----------------------------------------------------------------------------

-- Source stream for group dimension
CREATE OR REFRESH STREAMING TABLE dim_group_source (
  CONSTRAINT valid_group_id EXPECT (group_id IS NOT NULL)
)
COMMENT "Source stream for group dimension changes"
AS
-- Add "No Group" record for referential integrity
SELECT
  0 as group_id,
  'No Group' as group_name,
  'NONE' as group_type
UNION ALL
-- Actual groups from source data
SELECT
  g.grouping_id as group_id,
  p.party_name as group_name,
  p.party_type_code as group_type
FROM cmoore_user.pcdm_test.grouping g
JOIN cmoore_user.pcdm_test.party p ON g.party_id = p.party_id;

-- Apply changes with SCD Type 1 (upsert without history)
CREATE OR REFRESH STREAMING TABLE dim_group;

APPLY CHANGES INTO dim_group
FROM STREAM(LIVE.dim_group_source)
KEYS (group_id);

-- ----------------------------------------------------------------------------
-- dim_policy - Policy Dimension (SCD Type 2)
-- Resolves group through party_relationship table
-- ----------------------------------------------------------------------------

-- Source stream for policy dimension
CREATE OR REFRESH STREAMING TABLE dim_policy_source (
  CONSTRAINT valid_policy_id EXPECT (policy_id IS NOT NULL),
  CONSTRAINT valid_policy_number EXPECT (policy_number IS NOT NULL),
  CONSTRAINT valid_effective_date EXPECT (effective_date IS NOT NULL),
  CONSTRAINT valid_group_id EXPECT (group_id IS NOT NULL)
)
COMMENT "Source stream for policy dimension changes - group resolved via party_relationship"
AS
SELECT
  pol.policy_id,
  pol.policy_number,
  pol.effective_date,
  pol.expiration_date,
  pol.status_code,
  agr.agreement_original_inception_date as inception_date,
  prod.licensed_product_name as product_name,
  lob.line_of_business_name,
  lob.line_of_business_code,
  ic.insurance_class_name,
  comp.company_name,
  -- Resolve group through party_relationship (MEMBER_OF relationship)
  COALESCE(pr.related_party_id, 0) as group_id,  -- Foreign key to dim_group (0 = No Group)
  pol.geographic_location_id
FROM cmoore_user.pcdm_test.policy pol
JOIN cmoore_user.pcdm_test.agreement agr ON pol.agreement_id = agr.agreement_id
-- Get the policyholder (INSURED) from agreement_party_role
JOIN cmoore_user.pcdm_test.agreement_party_role apr ON agr.agreement_id = apr.agreement_id AND apr.party_role_code = 'INSURED'
-- Find group membership through party_relationship
LEFT JOIN cmoore_user.pcdm_test.party_relationship pr ON apr.party_id = pr.party_id AND pr.relationship_type_code = 'MEMBER_OF'
JOIN cmoore_user.pcdm_test.product prod ON agr.product_id = prod.product_id
JOIN cmoore_user.pcdm_test.line_of_business lob ON prod.line_of_business_id = lob.line_of_business_id
JOIN cmoore_user.pcdm_test.insurance_class ic ON lob.insurance_class_id = ic.insurance_class_id
LEFT JOIN cmoore_user.pcdm_test.company comp ON comp.company_id = 1;

-- Apply SCD Type 2 to dim_policy
CREATE OR REFRESH STREAMING TABLE dim_policy;

APPLY CHANGES INTO dim_policy
FROM STREAM(LIVE.dim_policy_source)
KEYS (policy_id)
SEQUENCE BY effective_date
STORED AS SCD TYPE 2;

-- ----------------------------------------------------------------------------
-- dim_risk - Risk Dimension (SCD Type 2)
-- Risk is based on policy_coverage_detail (the coverage on a specific insurable object)
-- This unions all insurable object types (vehicles, structures, etc.) into one dimension
-- ----------------------------------------------------------------------------

-- Source stream for risk dimension
CREATE OR REFRESH STREAMING TABLE dim_risk_source (
  CONSTRAINT valid_risk_id EXPECT (risk_id IS NOT NULL),
  CONSTRAINT valid_policy_id EXPECT (policy_id IS NOT NULL)
)
COMMENT "Source stream for risk dimension - based on policy_coverage_detail and insurable_objects"
AS
SELECT
  pcd.policy_coverage_detail_id as risk_id,
  pcd.policy_id,
  pcd.coverage_id,
  cov.coverage_name,
  COALESCE(io.insurable_object_type_code, 0) as insurable_object_type_code,
  CASE 
    WHEN io.insurable_object_type_code IS NULL THEN 'No Insurable Object'
    WHEN v.vehicle_id IS NOT NULL THEN 'Vehicle'
    WHEN s.structure_id IS NOT NULL THEN 'Structure'
    ELSE 'Other'
  END as risk_type,
  COALESCE(v.vehicle_make_name, 'N/A') as vehicle_make,
  COALESCE(v.vehicle_model_name, 'N/A') as vehicle_model,
  COALESCE(v.vehicle_model_year, 0) as vehicle_year,
  COALESCE(v.vehicle_identification_number, 'N/A') as vehicle_vin,
  CASE 
    WHEN cs.commercial_structure_id IS NOT NULL THEN 'Commercial'
    WHEN rs.residential_structure_id IS NOT NULL THEN 'Residential'
    WHEN s.structure_id IS NOT NULL THEN 'Other Structure'
    ELSE 'N/A'
  END as structure_type,
  io.geographic_location_id as risk_location_id,
  pcd.effective_date
FROM cmoore_user.pcdm_test.policy_coverage_detail pcd
JOIN cmoore_user.pcdm_test.coverage cov ON pcd.coverage_id = cov.coverage_id
LEFT JOIN cmoore_user.pcdm_test.insurable_object io ON pcd.insurable_object_id = io.insurable_object_id
LEFT JOIN cmoore_user.pcdm_test.vehicle v ON io.insurable_object_id = v.insurable_object_id
LEFT JOIN cmoore_user.pcdm_test.structure s ON io.insurable_object_id = s.insurable_object_id
LEFT JOIN cmoore_user.pcdm_test.commercial_structure cs ON s.structure_id = cs.structure_id
LEFT JOIN cmoore_user.pcdm_test.residential_structure rs ON s.structure_id = rs.structure_id;

-- Apply SCD Type 2 to dim_risk
CREATE OR REFRESH STREAMING TABLE dim_risk;

APPLY CHANGES INTO dim_risk
FROM STREAM(LIVE.dim_risk_source)
KEYS (risk_id)
SEQUENCE BY effective_date
STORED AS SCD TYPE 2;

-- ----------------------------------------------------------------------------
-- dim_claim - Claim Dimension (SCD Type 2)
-- ----------------------------------------------------------------------------

-- Source stream for claim dimension
CREATE OR REFRESH STREAMING TABLE dim_claim_source (
  CONSTRAINT valid_claim_id EXPECT (claim_id IS NOT NULL),
  CONSTRAINT valid_claim_number EXPECT (claim_number IS NOT NULL),
  CONSTRAINT valid_claim_reported_date EXPECT (claim_reported_date IS NOT NULL)
)
COMMENT "Source stream for claim dimension changes"
AS
SELECT
  c.claim_id,
  c.company_claim_number as claim_number,
  c.claim_description,
  c.claim_status_code,
  c.claim_open_date,
  c.claim_close_date,
  c.claim_reported_date,
  CASE WHEN c.claim_close_date IS NOT NULL THEN 1 ELSE 0 END as is_closed,
  CASE WHEN c.catastrophe_id IS NOT NULL THEN 1 ELSE 0 END as is_catastrophe,
  cat.catastrophe_name,
  occ.occurrence_begin_date as occurrence_date,
  occ.geographic_location_id as occurrence_location_id
FROM cmoore_user.pcdm_test.claim c
JOIN cmoore_user.pcdm_test.occurrence occ ON c.occurrence_id = occ.occurrence_id
LEFT JOIN cmoore_user.pcdm_test.catastrophe cat ON c.catastrophe_id = cat.catastrophe_id;

-- Apply SCD Type 2 to dim_claim
CREATE OR REFRESH STREAMING TABLE dim_claim;

APPLY CHANGES INTO dim_claim
FROM STREAM(LIVE.dim_claim_source)
KEYS (claim_id)
SEQUENCE BY claim_reported_date
STORED AS SCD TYPE 2;

-- ----------------------------------------------------------------------------
-- dim_attorney - Attorney Dimension (Static stub)
-- ----------------------------------------------------------------------------

CREATE OR REFRESH MATERIALIZED VIEW dim_attorney
COMMENT "Attorney dimension stub - static record"
AS
SELECT
  0 as attorney_id,
  'Unknown' as attorney_name,
  'Unknown' as law_firm,
  'Unknown' as attorney_type;

-- ----------------------------------------------------------------------------
-- dim_court - Court Dimension (Static stub)
-- ----------------------------------------------------------------------------

CREATE OR REFRESH MATERIALIZED VIEW dim_court
COMMENT "Court dimension stub - static record"
AS
SELECT
  0 as court_id,
  'Unknown' as court_name,
  'Unknown' as court_type,
  'Unknown' as jurisdiction;

-- ----------------------------------------------------------------------------
-- dim_outcome - Outcome Dimension (Static stub)
-- ----------------------------------------------------------------------------

CREATE OR REFRESH MATERIALIZED VIEW dim_outcome
COMMENT "Outcome dimension stub - static record"
AS
SELECT
  0 as outcome_id,
  'Unknown' as outcome_type,
  'Unknown' as outcome_description;

-- ============================================================================
-- FACT TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fact_premium_payments - Premium Payments Fact
-- Group resolved through party_relationship
-- ----------------------------------------------------------------------------

CREATE OR REFRESH MATERIALIZED VIEW fact_premium_payments (
  CONSTRAINT valid_policy_id EXPECT (policy_id IS NOT NULL),
  CONSTRAINT valid_risk_id EXPECT (risk_id IS NOT NULL),
  CONSTRAINT valid_premium_amount EXPECT (premium_amount >= 0),
  CONSTRAINT valid_date_key EXPECT (transaction_date_key IS NOT NULL)
)
COMMENT "Premium payments fact table - group resolved via party_relationship"
AS
SELECT
  pol.policy_id,
  -- Resolve group through party_relationship (MEMBER_OF relationship)
  COALESCE(pr.related_party_id, 0) as group_id,
  pcd.policy_coverage_detail_id as risk_id,
  CAST(date_format(pcd.effective_date, 'yyyyMMdd') AS INT) as transaction_date_key,
  CAST(date_format(pol.effective_date, 'yyyyMMdd') AS INT) as policy_effective_date_key,
  CAST(date_format(pol.expiration_date, 'yyyyMMdd') AS INT) as policy_expiration_date_key,
  -- Generate estimated premium based on coverage
  CASE 
    WHEN cov.coverage_name LIKE '%Liability%' THEN lim.limit_value * 0.005
    WHEN cov.coverage_name LIKE '%Property%' THEN lim.limit_value * 0.010
    WHEN cov.coverage_name LIKE '%Auto%' THEN lim.limit_value * 0.008
    ELSE lim.limit_value * 0.006
  END as premium_amount,
  lim.limit_value as coverage_limit,
  COALESCE(ded.deductible_value, 0) as deductible_amount,
  cov.coverage_name as coverage_type,
  pcd.coverage_part_code,
  1 as policy_count,
  current_timestamp() as load_date
FROM cmoore_user.pcdm_test.policy_coverage_detail pcd
JOIN cmoore_user.pcdm_test.policy pol ON pcd.policy_id = pol.policy_id
JOIN cmoore_user.pcdm_test.agreement agr ON pol.agreement_id = agr.agreement_id
-- Get the policyholder (INSURED) from agreement_party_role
JOIN cmoore_user.pcdm_test.agreement_party_role apr ON agr.agreement_id = apr.agreement_id AND apr.party_role_code = 'INSURED'
-- Find group membership through party_relationship
LEFT JOIN cmoore_user.pcdm_test.party_relationship pr ON apr.party_id = pr.party_id AND pr.relationship_type_code = 'MEMBER_OF'
JOIN cmoore_user.pcdm_test.coverage cov ON pcd.coverage_id = cov.coverage_id
LEFT JOIN cmoore_user.pcdm_test.policy_limit lim ON pcd.policy_coverage_detail_id = lim.policy_coverage_detail_id
LEFT JOIN cmoore_user.pcdm_test.policy_deductible ded ON pcd.policy_coverage_detail_id = ded.policy_coverage_detail_id;

-- ----------------------------------------------------------------------------
-- fact_claims - Claims Fact
-- Group resolved through party_relationship
-- ----------------------------------------------------------------------------

CREATE OR REFRESH MATERIALIZED VIEW fact_claims (
  CONSTRAINT valid_claim_id EXPECT (claim_id IS NOT NULL),
  CONSTRAINT valid_policy_id EXPECT (policy_id IS NOT NULL),
  CONSTRAINT valid_risk_id EXPECT (risk_id IS NOT NULL),
  CONSTRAINT valid_date_key EXPECT (claim_date_key IS NOT NULL)
)
COMMENT "Claims fact table - group resolved via party_relationship"
AS
SELECT
  c.claim_id,
  pol.policy_id,
  -- Resolve group through party_relationship (MEMBER_OF relationship)
  COALESCE(pr.related_party_id, 0) as group_id,
  pcd.policy_coverage_detail_id as risk_id,
  0 as attorney_id,
  0 as court_id,
  0 as outcome_id,
  CAST(date_format(c.claim_open_date, 'yyyyMMdd') AS INT) as claim_date_key,
  CAST(date_format(c.claim_reported_date, 'yyyyMMdd') AS INT) as reported_date_key,
  CAST(date_format(COALESCE(c.claim_close_date, current_date()), 'yyyyMMdd') AS INT) as close_date_key,
  CAST(date_format(occ.occurrence_begin_date, 'yyyyMMdd') AS INT) as occurrence_date_key,
  -- Estimated claim amounts (would come from claim_amount table if populated)
  CASE 
    WHEN c.claim_status_code = 'CLOSED' THEN 
      CASE 
        WHEN cat.catastrophe_id IS NOT NULL THEN lim.limit_value * 0.75
        ELSE lim.limit_value * 0.35
      END
    ELSE lim.limit_value * 0.20
  END as incurred_amount,
  CASE 
    WHEN c.claim_status_code = 'CLOSED' THEN 
      CASE 
        WHEN cat.catastrophe_id IS NOT NULL THEN lim.limit_value * 0.70
        ELSE lim.limit_value * 0.30
      END
    ELSE 0
  END as paid_amount,
  CASE 
    WHEN c.claim_status_code = 'OPEN' THEN lim.limit_value * 0.20
    ELSE 0
  END as reserve_amount,
  CASE WHEN c.claim_status_code = 'CLOSED' THEN 1 ELSE 0 END as closed_claim_count,
  CASE WHEN c.claim_status_code = 'OPEN' THEN 1 ELSE 0 END as open_claim_count,
  1 as claim_count,
  datediff(COALESCE(c.claim_close_date, current_date()), c.claim_open_date) as days_to_close,
  datediff(c.claim_reported_date, c.claim_open_date) as report_lag_days,
  current_timestamp() as load_date
FROM cmoore_user.pcdm_test.claim c
JOIN cmoore_user.pcdm_test.occurrence occ ON c.occurrence_id = occ.occurrence_id
LEFT JOIN cmoore_user.pcdm_test.catastrophe cat ON c.catastrophe_id = cat.catastrophe_id
JOIN cmoore_user.pcdm_test.claim_coverage cc ON c.claim_id = cc.claim_id
JOIN cmoore_user.pcdm_test.policy_coverage_detail pcd ON cc.policy_coverage_detail_id = pcd.policy_coverage_detail_id
JOIN cmoore_user.pcdm_test.policy pol ON pcd.policy_id = pol.policy_id
JOIN cmoore_user.pcdm_test.agreement agr ON pol.agreement_id = agr.agreement_id
-- Get the policyholder (INSURED) from agreement_party_role
JOIN cmoore_user.pcdm_test.agreement_party_role apr ON agr.agreement_id = apr.agreement_id AND apr.party_role_code = 'INSURED'
-- Find group membership through party_relationship
LEFT JOIN cmoore_user.pcdm_test.party_relationship pr ON apr.party_id = pr.party_id AND pr.relationship_type_code = 'MEMBER_OF'
LEFT JOIN cmoore_user.pcdm_test.policy_limit lim ON pcd.policy_coverage_detail_id = lim.policy_coverage_detail_id;

-- ============================================================================
-- PIPELINE COMPLETE
-- ============================================================================
-- 
-- All dimension and fact tables have been created with:
--   - SCD Type 2 for dimensions with business effective dates (policy, risk, claim)
--   - SCD Type 1 for dimensions without effective dates (group) - simple overwrite
--   - Static tables for stub dimensions (attorney, court, outcome)
--   - Automatic tracking of __START_AT, __END_AT, __CURRENT for SCD Type 2 tables
--   - Data quality expectations on all tables
--   - Business date sequencing for proper historical tracking
--   - Group membership resolved through party_relationship table (MEMBER_OF)
-- 
-- ============================================================================
