-- =====================================================
-- dim_claim DDL - Claim Dimension (SCD Type 2)
-- =====================================================

CREATE TABLE IF NOT EXISTS IDENTIFIER(:catalog || '.' || :schema || '.dim_claim') (
  -- Surrogate Key :param_1
  claim_sk BIGINT GENERATED ALWAYS AS IDENTITY,
  
  -- Natural Key
  claim_key STRING NOT NULL,
  
  -- Claim Identifiers
  company_claim_number STRING,
  company_subclaim_number STRING,
  claim_description STRING,
  
  -- Claim Dates
  claim_open_date DATE,
  claim_close_date DATE,
  claim_reopen_date DATE,
  claim_reported_date DATE,
  claims_made_date DATE,
  
  -- Claim Status
  claim_status_code STRING,
  is_closed BOOLEAN,
  is_reopened BOOLEAN,
  is_open BOOLEAN,
  
  -- Calculated Days
  days_open INT,
  reporting_lag_days INT,
  
  -- Occurrence Information
  occurrence_id STRING,
  occurrence_begin_date DATE,
  occurrence_begin_time TIMESTAMP,
  occurrence_end_date DATE,
  occurrence_end_time TIMESTAMP,
  catastrophic_event_indicator STRING,
  
  -- Occurrence Location
  occurrence_location_id STRING,
  occurrence_location_name STRING,
  occurrence_state_code STRING,
  occurrence_state_name STRING,
  
  -- Catastrophe Information
  catastrophe_id STRING,
  catastrophe_name STRING,
  catastrophe_type_code STRING,
  industry_catastrophe_code STRING,
  company_catastrophe_code STRING,
  is_catastrophe BOOLEAN,
  
  -- Related Objects
  insurable_object_id STRING,
  coverage_count INT,
  
  -- Legal Indicators
  has_litigation BOOLEAN,
  has_arbitration BOOLEAN,
  
  -- SCD Type 2 Tracking
  effective_begin_date TIMESTAMP NOT NULL,
  effective_end_date TIMESTAMP,
  is_current BOOLEAN NOT NULL DEFAULT TRUE,
  
  -- Audit Columns
  created_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  updated_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  
  -- Primary Key
  CONSTRAINT pk_dim_claim PRIMARY KEY (claim_sk)
)
USING DELTA
TBLPROPERTIES (
  'delta.enableChangeDataFeed' = 'true',
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true',
  'delta.feature.allowColumnDefaults' = 'supported'
)
COMMENT 'Claim Dimension - SCD Type 2. Tracks claim information and status changes over time.';
