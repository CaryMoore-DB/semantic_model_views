-- =====================================================
-- fact_premium_payments DDL - Premium Payment Fact Table
-- =====================================================
-- Fact tables are typically not SCD Type 2
-- They reference dimension surrogate keys (SK) for SCD lookups
-- =====================================================

CREATE TABLE IF NOT EXISTS IDENTIFIER(:catalog || '.' || :schema || '.fact_premium_payments') (
  -- Surrogate Key
  premium_payment_sk BIGINT GENERATED ALWAYS AS IDENTITY,
  
  -- Natural Key
  premium_payment_key STRING NOT NULL,
  
  -- Foreign Keys to Dimensions (using surrogate keys for SCD)
  policy_sk BIGINT NOT NULL,
  risk_sk BIGINT,
  group_sk BIGINT,
  begin_date_sk DATE,
  end_date_sk DATE,
  
  -- Natural Keys (for reference)
  policy_key STRING,
  risk_key STRING,
  group_key STRING,
  location_key STRING,
  
  -- Coverage Detail
  policy_coverage_detail_id STRING,
  coverage_id STRING,
  coverage_part_code STRING,
  coverage_description STRING,
  
  -- Date Attributes
  earning_begin_date DATE NOT NULL,
  earning_end_date DATE NOT NULL,
  earning_period_days INT,
  
  -- Transaction Classification
  insurance_type_code STRING,
  amount_type_code STRING,
  transaction_type STRING,
  
  -- Boolean Flags
  is_premium BOOLEAN,
  is_tax BOOLEAN,
  is_surcharge BOOLEAN,
  is_fee BOOLEAN,
  is_direct BOOLEAN,
  is_assumed BOOLEAN,
  is_ceded BOOLEAN,
  
  -- Amount Measures
  premium_amount DECIMAL(18,2),
  premium_only_amount DECIMAL(18,2),
  tax_amount DECIMAL(18,2),
  surcharge_amount DECIMAL(18,2),
  fee_amount DECIMAL(18,2),
  net_premium_amount DECIMAL(18,2),
  direct_premium_amount DECIMAL(18,2),
  assumed_premium_amount DECIMAL(18,2),
  ceded_premium_amount DECIMAL(18,2),
  
  -- Coverage Limits and Deductibles
  avg_deductible DECIMAL(18,2),
  avg_limit DECIMAL(18,2),
  
  -- Audit Columns
  created_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  updated_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  
  -- Primary Key
  CONSTRAINT pk_fact_premium_payments PRIMARY KEY (premium_payment_sk)
)
USING DELTA
TBLPROPERTIES (
  'delta.enableChangeDataFeed' = 'true',
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true',
  'delta.feature.allowColumnDefaults' = 'supported'
)
COMMENT 'Premium Payment Fact Table. Links to dimension SKs for SCD Type 2 support.';
