-- Dimension: Date
-- Standard date dimension for time-based analysis

CREATE OR REPLACE TABLE ${catalog}.${schema}.dim_date AS
WITH date_range AS (
  SELECT explode(sequence(
    date('2000-01-01'), 
    date('2050-12-31'), 
    interval 1 day
  )) as date_value
)
SELECT 
    date_value as date_key,
    year(date_value) as year,
    quarter(date_value) as quarter,
    month(date_value) as month,
    dayofmonth(date_value) as day_of_month,
    dayofweek(date_value) as day_of_week,
    dayofyear(date_value) as day_of_year,
    weekofyear(date_value) as week_of_year,
    date_format(date_value, 'MMMM') as month_name,
    date_format(date_value, 'MMM') as month_short_name,
    date_format(date_value, 'EEEE') as day_name,
    date_format(date_value, 'EEE') as day_short_name,
    CASE WHEN dayofweek(date_value) IN (1, 7) THEN 1 ELSE 0 END as is_weekend,
    CASE WHEN month(date_value) IN (1,4,7,10) THEN 1 ELSE 0 END as is_quarter_start,
    CASE WHEN month(date_value) IN (3,6,9,12) THEN 1 ELSE 0 END as is_quarter_end,
    CASE WHEN month(date_value) = 1 AND dayofmonth(date_value) = 1 THEN 1 ELSE 0 END as is_year_start,
    CASE WHEN month(date_value) = 12 AND dayofmonth(date_value) = 31 THEN 1 ELSE 0 END as is_year_end,
    concat(year(date_value), '-Q', quarter(date_value)) as fiscal_quarter,
    concat(year(date_value), '-', lpad(month(date_value), 2, '0')) as fiscal_year_month
FROM date_range;
