:param_1 -- =====================================================
-- dim_policy DDL - Policy Dimension (SCD Type 2)
-- =====================================================
-- Policies are the middle level of the hierarchy:
-- Group (1:Many) -> Policy (1:Many) -> Risk
-- 
-- Links to Group via group_key
-- =====================================================

CREATE TABLE IF NOT EXISTS IDENTIFIER(:catalog || '.' || :schema || '.dim_policy') (
  -- Surrogate Key
  policy_sk BIGINT GENERATED ALWAYS AS IDENTITY,
  
  -- Natural Key
  policy_key STRING NOT NULL,
  
  -- Foreign Key to Group (Hierarchy)
  group_key STRING NOT NULL,
  
  -- Policy Attributes
  policy_number STRING,
  effective_date DATE,
  expiration_date DATE,
  status_code STRING,
  
  -- Agreement Information
  agreement_id STRING,
  agreement_name STRING,
  agreement_type_code STRING,
  agreement_original_inception_date DATE,
  
  -- Product Hierarchy
  product_id STRING,
  product_name STRING,
  product_description STRING,
  
  -- Line of Business Hierarchy
  line_of_business_id STRING,
  line_of_business_name STRING,
  line_of_business_code STRING,
  line_of_business_description STRING,
  line_of_business_group_id STRING,
  line_of_business_group_name STRING,
  
  -- Insurance Class
  insurance_class_id STRING,
  insurance_class_name STRING,
  
  -- Coverage Information
  coverage_part_count INT,
  
  -- Geographic Information
  geographic_location_id STRING,
  location_name STRING,
  state_code STRING,
  state_name STRING,
  
  -- Calculated Fields
  policy_term_days INT,
  policy_age_days INT,
  is_active BOOLEAN,
  
  -- SCD Type 2 Tracking
  effective_begin_date TIMESTAMP NOT NULL,
  effective_end_date TIMESTAMP,
  is_current BOOLEAN NOT NULL DEFAULT TRUE,
  
  -- Audit Columns
  created_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  updated_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  
  -- Primary Key
  CONSTRAINT pk_dim_policy PRIMARY KEY (policy_sk)
)
USING DELTA
TBLPROPERTIES (
  'delta.enableChangeDataFeed' = 'true',
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true',
  'delta.feature.allowColumnDefaults' = 'supported'
)
COMMENT 'Policy Dimension - SCD Type 2. Middle level of hierarchy: Group -> Policy -> Risk';
