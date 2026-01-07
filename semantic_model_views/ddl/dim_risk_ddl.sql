-- =====================================================
-- dim_risk DDL - Insurable Object/Risk Dimension (SCD Type 2)
-- =====================================================
-- Risks are the bottom level of the hierarchy:
-- Group (1:Many) -> Policy (1:Many) -> Risk
-- 
-- Links to Policy via policy_key
-- =====================================================

CREATE TABLE IF NOT EXISTS IDENTIFIER(:catalog || '.' || :schema || '.dim_risk') (
  -- Surrogate Key
  risk_sk BIGINT GENERATED ALWAYS AS IDENTITY,
  
  -- Natural Key
  risk_key STRING NOT NULL,
  
  -- Foreign Key to Policy (Hierarchy)
  policy_key STRING NOT NULL,
  
  -- Insurable Object Type
  insurable_object_type_code STRING,
  risk_category STRING,
  
  -- Vehicle Information (if applicable)
  vehicle_id STRING,
  vin STRING,
  vehicle_make_name STRING,
  vehicle_model_name STRING,
  vehicle_model_year INT,
  vehicle_type STRING,
  
  -- Structure Information (if applicable)
  structure_id STRING,
  structure_type STRING,
  dwelling_id STRING,
  mobile_home_id STRING,
  
  -- Farm Equipment (if applicable)
  farm_equipment_id STRING,
  farm_equipment_type STRING,
  
  -- Workers Comp / Transportation Classes
  workers_comp_class_id STRING,
  transportation_class_id STRING,
  
  -- Geographic/Location Information
  geographic_location_id STRING,
  location_name STRING,
  location_code STRING,
  state_code STRING,
  state_name STRING,
  
  -- Address Information
  location_address_id STRING,
  line_1_address STRING,
  line_2_address STRING,
  municipality_name STRING,
  postal_code STRING,
  
  -- SCD Type 2 Tracking
  effective_begin_date TIMESTAMP NOT NULL,
  effective_end_date TIMESTAMP,
  is_current BOOLEAN NOT NULL DEFAULT TRUE,
  
  -- Audit Columns
  created_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  updated_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  
  -- Primary Key
  CONSTRAINT pk_dim_risk PRIMARY KEY (risk_sk)
)
USING DELTA
TBLPROPERTIES (
  'delta.enableChangeDataFeed' = 'true',
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true',
  'delta.feature.allowColumnDefaults' = 'supported'
)
COMMENT 'Risk/Insurable Object Dimension - SCD Type 2. Bottom level of hierarchy: Group -> Policy -> Risk';
