-- ============================================================================
-- dim_date - Date Dimension (Type 1 - Static)
-- ============================================================================

CREATE OR REFRESH MATERIALIZED VIEW dim_date (
  CONSTRAINT valid_date_key EXPECT (date_key IS NOT NULL),
  CONSTRAINT valid_full_date EXPECT (full_date IS NOT NULL)
)
COMMENT "Date dimension with calendar attributes"
AS
SELECT
  CAST(date_format(date_seq, 'yyyyMMdd') AS INT) as date_key,
  date_seq as full_date,
  year(date_seq) as year,
  quarter(date_seq) as quarter,
  month(date_seq) as month,
  dayofmonth(date_seq) as day,
  dayofweek(date_seq) as day_of_week,
  weekofyear(date_seq) as week_of_year,
  date_format(date_seq, 'MMMM') as month_name,
  date_format(date_seq, 'EEEE') as day_name,
  CASE WHEN dayofweek(date_seq) IN (1, 7) THEN 1 ELSE 0 END as is_weekend,
  CASE 
    WHEN month(date_seq) IN (1,2,3) THEN 'Q1'
    WHEN month(date_seq) IN (4,5,6) THEN 'Q2'
    WHEN month(date_seq) IN (7,8,9) THEN 'Q3'
    ELSE 'Q4'
  END as quarter_name
FROM (
  SELECT explode(sequence(to_date('2020-01-01'), to_date('2030-12-31'), interval 1 day)) as date_seq
);
