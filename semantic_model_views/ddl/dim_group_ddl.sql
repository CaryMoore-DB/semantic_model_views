-- =====================================================
-- dim_group DDL - Customer Group Dimension (SCD Type 2)
-- =====================================================
-- Groups represent the top level of the hierarchy:
-- Group (1:Many) -> Policy (1:Many) -> Risk
-- 
-- Includes: Households, Organizations, Professional Groups, etc.
-- =====================================================

CREATE TABLE IF NOT EXISTS ${catalog}.${schema}.dim_group (
  -- Surrogate Key
  group_sk BIGINT GENERATED ALWAYS AS IDENTITY,
  
  -- Natural Key
  group_key STRING NOT NULL,
  
  -- Group Attributes
  group_name STRING,
  group_type STRING,
  
  -- Party Information
  party_id STRING,
  party_name STRING,
  party_type_code STRING,
  
  -- Organization Details (if applicable)
  organization_id STRING,
  organization_name STRING,
  organization_type_code STRING,
  industry_type_code STRING,
  
  -- Dates
  group_begin_date DATE,
  group_end_date DATE,
  
  -- SCD Type 2 Tracking
  effective_begin_date TIMESTAMP NOT NULL,
  effective_end_date TIMESTAMP,
  is_current BOOLEAN NOT NULL DEFAULT TRUE,
  
  -- Audit Columns
  created_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  updated_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  
  -- Primary Key
  CONSTRAINT pk_dim_group PRIMARY KEY (group_sk)
)
USING DELTA
TBLPROPERTIES (
  'delta.enableChangeDataFeed' = 'true',
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true'
)
COMMENT 'Customer Group Dimension - SCD Type 2. Top level of hierarchy: Group -> Policy -> Risk';
