-- =====================================================
-- dim_court DDL - Court Jurisdiction Dimension (SCD Type 2)
-- =====================================================

CREATE TABLE IF NOT EXISTS IDENTIFIER(:catalog || '.' || :schema || '.dim_court') (
  -- Surrogate Key
  court_sk BIGINT GENERATED ALWAYS AS IDENTITY,
  
  -- Natural Key
  court_key STRING NOT NULL,
  
  -- Court Identifiers
  court_jurisdiction_id STRING,
  court_id STRING,
  jurisdiction_id STRING,
  
  -- Legal Jurisdiction Information
  legal_jurisdiction_id STRING,
  legal_jurisdiction_name STRING,
  legal_jurisdiction_description STRING,
  rules_preference_description STRING,
  
  -- Derived Attributes
  court_level STRING,
  court_location STRING,
  
  -- SCD Type 2 Tracking
  effective_begin_date TIMESTAMP NOT NULL,
  effective_end_date TIMESTAMP,
  is_current BOOLEAN NOT NULL DEFAULT TRUE,
  
  -- Audit Columns
  created_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  updated_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  
  -- Primary Key
  CONSTRAINT pk_dim_court PRIMARY KEY (court_sk)
)
USING DELTA
TBLPROPERTIES (
  'delta.enableChangeDataFeed' = 'true',
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true',
  'delta.feature.allowColumnDefaults' = 'supported'
)
COMMENT 'Court Jurisdiction Dimension - SCD Type 2. Tracks court and jurisdiction information.';
