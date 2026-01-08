-- =====================================================
-- dim_date DDL - Date Dimension (Type 1 - Static)
-- =====================================================
-- Date dimension is typically Type 1 (no SCD tracking needed)
-- Covers range from 2000-01-01 to 2050-12-31
-- =====================================================

CREATE TABLE IF NOT EXISTS IDENTIFIER( :catalog || '.' || :schema || '.dim_date') (
  -- Natural Key
  date_key DATE NOT NULL,
  
  -- Year Attributes
  year INT NOT NULL,
  quarter INT NOT NULL,
  
  -- Month Attributes
  month INT NOT NULL,
  month_name STRING NOT NULL,
  month_short_name STRING NOT NULL,
  
  -- Day Attributes
  day_of_month INT NOT NULL,
  day_of_week INT NOT NULL,
  day_of_year INT NOT NULL,
  day_name STRING NOT NULL,
  day_short_name STRING NOT NULL,
  
  -- Week Attributes
  week_of_year INT NOT NULL,
  
  -- Flags
  is_weekend BOOLEAN NOT NULL,
  is_quarter_start BOOLEAN NOT NULL,
  is_quarter_end BOOLEAN NOT NULL,
  
  -- Fiscal Periods
  fiscal_quarter STRING NOT NULL,
  fiscal_year_month STRING NOT NULL,
  
  -- Audit Columns
  created_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  
  -- Primary Key
  CONSTRAINT pk_dim_date PRIMARY KEY (date_key)
)
USING DELTA
TBLPROPERTIES (
  'delta.autoOptimize.optimizeWrite' = 'true',
  'delta.autoOptimize.autoCompact' = 'true',
  'delta.feature.allowColumnDefaults' = 'supported'
)
COMMENT 'Date Dimension - Type 1 (Static). Contains all dates from 2000 to 2050.';
