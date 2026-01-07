-- =====================================================
-- fact_claims DDL - Claims Fact Table
-- =====================================================
-- Fact tables are typically not SCD Type 2
-- They reference dimension surrogate keys (SK) for SCD lookups
-- =====================================================

CREATE TABLE IF NOT EXISTS IDENTIFIER(:catalog || '.' || :schema || '.fact_claims') (
  -- Surrogate Key
  claim_transaction_sk BIGINT GENERATED ALWAYS AS IDENTITY,
  
  -- Natural Key
  claim_transaction_key STRING NOT NULL,
  
  -- Foreign Keys to Dimensions (using surrogate keys for SCD)
  claim_sk BIGINT NOT NULL,
  policy_sk BIGINT,
  risk_sk BIGINT,
  group_sk BIGINT,
  attorney_sk BIGINT,
  court_sk BIGINT,
  outcome_sk BIGINT,
  transaction_date_sk DATE NOT NULL,
  claim_open_date_sk DATE,
  claim_close_date_sk DATE,
  claim_reported_date_sk DATE,
  
  -- Natural Keys (for reference)
  claim_key STRING,
  policy_key STRING,
  risk_key STRING,
  group_key STRING,
  
  -- Coverage and Offer Details
  policy_coverage_detail_id STRING,
  claim_offer_id STRING,
  settlement_offer_amount DECIMAL(18,2),
  settlement_offer_provision_description STRING,
  
  -- Date Attributes
  event_date DATE NOT NULL,
  claim_open_date DATE,
  claim_close_date DATE,
  claim_reported_date DATE,
  
  -- Claim Identifiers
  company_claim_number STRING,
  company_subclaim_number STRING,
  claim_status_code STRING,
  
  -- Transaction Classification
  insurance_type_code STRING,
  amount_type_code STRING,
  transaction_type STRING,
  
  -- Boolean Flags - Transaction Types
  is_payment BOOLEAN,
  is_reserve BOOLEAN,
  is_recovery BOOLEAN,
  is_loss_payment BOOLEAN,
  is_expense_payment BOOLEAN,
  is_loss_reserve BOOLEAN,
  is_expense_reserve BOOLEAN,
  is_loss_recovery BOOLEAN,
  is_salvage BOOLEAN,
  is_subrogation BOOLEAN,
  is_reinsurance_recovery BOOLEAN,
  
  -- Boolean Flags - Business Classification
  is_direct BOOLEAN,
  is_assumed BOOLEAN,
  is_ceded BOOLEAN,
  
  -- Boolean Flags - Legal
  has_litigation BOOLEAN,
  has_arbitration BOOLEAN,
  
  -- Amount Measures
  total_claim_amount DECIMAL(18,2),
  net_claim_amount DECIMAL(18,2),
  payment_amount DECIMAL(18,2),
  reserve_amount DECIMAL(18,2),
  recovery_amount DECIMAL(18,2),
  loss_payment_amount DECIMAL(18,2),
  expense_payment_amount DECIMAL(18,2),
  loss_reserve_amount DECIMAL(18,2),
  expense_reserve_amount DECIMAL(18,2),
  direct_claim_amount DECIMAL(18,2),
  assumed_claim_amount DECIMAL(18,2),
  ceded_claim_amount DECIMAL(18,2),
  
  -- Calculated Days
  days_claim_open INT,
  days_since_claim_open INT,
  
  -- Audit Columns
  created_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  updated_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  
  -- Primary Key
  CONSTRAINT pk_fact_claims PRIMARY KEY (claim_transaction_sk)
)
USING DELTA
TBLPROPERTIES (
  'delta.enableChangeDataFeed' = 'true',
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true',
  'delta.feature.allowColumnDefaults' = 'supported'
)
COMMENT 'Claims Fact Table. Links to dimension SKs for SCD Type 2 support.';
