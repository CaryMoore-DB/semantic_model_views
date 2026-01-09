-- ============================================================================
-- dim_policy - Policy Dimension (SCD Type 2)
-- Resolves group through party_relationship table
-- ============================================================================

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
FROM STREAM(cmoore_user.pcdm_test.policy) pol
JOIN STREAM(cmoore_user.pcdm_test.agreement) agr ON pol.agreement_id = agr.agreement_id
-- Get the policyholder (INSURED) from agreement_party_role
JOIN STREAM(cmoore_user.pcdm_test.agreement_party_role) apr ON agr.agreement_id = apr.agreement_id AND apr.party_role_code = 'INSURED'
-- Find group membership through party_relationship
LEFT JOIN cmoore_user.pcdm_test.party_relationship pr ON apr.party_id = pr.party_id AND pr.relationship_type_code = 'MEMBER_OF'
JOIN STREAM(cmoore_user.pcdm_test.product) prod ON agr.product_id = prod.product_id
JOIN STREAM(cmoore_user.pcdm_test.line_of_business) lob ON prod.line_of_business_id = lob.line_of_business_id
JOIN STREAM(cmoore_user.pcdm_test.insurance_class) ic ON lob.insurance_class_id = ic.insurance_class_id
LEFT JOIN cmoore_user.pcdm_test.company comp ON comp.company_id = 1;

-- Apply SCD Type 2 to dim_policy
CREATE OR REFRESH STREAMING TABLE dim_policy;

APPLY CHANGES INTO dim_policy
FROM STREAM(LIVE.dim_policy_source)
KEYS (policy_id)
SEQUENCE BY effective_date
STORED AS SCD TYPE 2;
