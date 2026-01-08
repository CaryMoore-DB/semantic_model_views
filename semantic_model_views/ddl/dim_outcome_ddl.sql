-- =====================================================
-- dim_outcome DDL - Legal Outcome Dimension (SCD Type 2)
-- =====================================================

CREATE TABLE IF NOT EXISTS IDENTIFIER(:catalog || '.' || :schema || '.dim_outcome') (
  -- Surrogate Key
  outcome_sk BIGINT GENERATED ALWAYS AS IDENTITY,
  
  -- Natural Key
  outcome_key STRING NOT NULL,
  
  -- Outcome Type (Litigation or Arbitration)
  outcome_type STRING NOT NULL,
  outcome_id STRING,
  
  -- Litigation/Arbitration Information
  litigation_description STRING,
  court_jurisdiction_id STRING,
  
  -- Outcome Details
  outcome_status_code STRING,
  outcome_result STRING,
  judgment_amount DECIMAL(18,2),
  settlement_amount DECIMAL(18,2),
  outcome_date DATE,
  
  -- Related Court Information
  court_id STRING,
  jurisdiction_id STRING,
  legal_jurisdiction_name STRING,
  
  -- SCD Type 2 Tracking
  effective_begin_date TIMESTAMP NOT NULL,
  effective_end_date TIMESTAMP,
  is_current BOOLEAN NOT NULL DEFAULT TRUE,
  
  -- Audit Columns
  created_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  updated_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  
  -- Primary Key
  CONSTRAINT pk_dim_outcome PRIMARY KEY (outcome_sk)
)
USING DELTA
TBLPROPERTIES (
  'delta.enableChangeDataFeed' = 'true',
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true',
  'delta.feature.allowColumnDefaults' = 'supported'
)
COMMENT 'Legal Outcome Dimension - SCD Type 2. Tracks litigation and arbitration outcomes.';
