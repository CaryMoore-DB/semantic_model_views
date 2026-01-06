-- =====================================================
-- dim_attorney DDL - Attorney Dimension (SCD Type 2)
-- =====================================================

CREATE TABLE IF NOT EXISTS ${catalog}.${schema}.dim_attorney (
  -- Surrogate Key
  attorney_sk BIGINT GENERATED ALWAYS AS IDENTITY,
  
  -- Natural Key
  attorney_key STRING NOT NULL,
  
  -- Attorney Identifiers
  attorney_id STRING,
  provider_id STRING,
  provider_party_role_code STRING,
  party_id STRING,
  
  -- Party Information
  attorney_name STRING,
  party_type_code STRING,
  
  -- Person Information (if individual attorney)
  person_id STRING,
  prefix_name STRING,
  first_name STRING,
  middle_name STRING,
  last_name STRING,
  suffix_name STRING,
  full_legal_name STRING,
  
  -- Law Firm Information
  law_firm_id STRING,
  law_firm_name STRING,
  law_firm_type_code STRING,
  
  -- Contact Information
  communication_id STRING,
  communication_type_code STRING,
  communication_value STRING,
  
  -- Address Information
  location_address_id STRING,
  line_1_address STRING,
  line_2_address STRING,
  city STRING,
  state_code STRING,
  state_name STRING,
  postal_code STRING,
  
  -- Activity Dates
  begin_date DATE,
  end_date DATE,
  is_active BOOLEAN,
  
  -- SCD Type 2 Tracking
  effective_begin_date TIMESTAMP NOT NULL,
  effective_end_date TIMESTAMP,
  is_current BOOLEAN NOT NULL DEFAULT TRUE,
  
  -- Audit Columns
  created_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  updated_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  
  -- Primary Key
  CONSTRAINT pk_dim_attorney PRIMARY KEY (attorney_sk)
)
USING DELTA
TBLPROPERTIES (
  'delta.enableChangeDataFeed' = 'true',
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
COMMENT 'Attorney Dimension - SCD Type 2. Tracks attorney information and changes over time.';
