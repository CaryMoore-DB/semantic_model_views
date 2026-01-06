# Databricks notebook source
"""
Delta Live Tables Pipeline - Date Dimension
Static dimension - no SCD Type 2 needed
"""
import dlt
from pyspark.sql.functions import (
    col, year, quarter, month, dayofmonth, dayofweek, dayofyear,
    weekofyear, date_format, when, concat, lpad, current_timestamp,
    expr, to_date
)
from datetime import datetime, timedelta

@dlt.table(
    name="dim_date",
    comment="Date Dimension - Static reference table covering 2000-2050",
    table_properties={
        "quality": "gold",
        "delta.autoOptimize.optimizeWrite": "true"
    }
)
@dlt.expect_all_or_drop({
    "valid_date_key": "date_key IS NOT NULL",
    "valid_year": "year BETWEEN 2000 AND 2050",
    "valid_month": "month BETWEEN 1 AND 12",
    "valid_day": "day_of_month BETWEEN 1 AND 31",
    "valid_quarter": "quarter BETWEEN 1 AND 4"
})
def dim_date():
    """
    Generate date dimension with all dates from 2000-01-01 to 2050-12-31
    """
    # Generate date range
    start_date = datetime(2000, 1, 1)
    end_date = datetime(2050, 12, 31)
    
    # Create DataFrame with date sequence
    date_df = spark.sql(f"""
        SELECT sequence(
            to_date('{start_date.strftime('%Y-%m-%d')}'),
            to_date('{end_date.strftime('%Y-%m-%d')}'),
            interval 1 day
        ) as date_array
    """).selectExpr("explode(date_array) as date_key")
    
    # Add all date attributes
    return (
        date_df
        .withColumn("year", year(col("date_key")))
        .withColumn("quarter", quarter(col("date_key")))
        .withColumn("month", month(col("date_key")))
        .withColumn("day_of_month", dayofmonth(col("date_key")))
        .withColumn("day_of_week", dayofweek(col("date_key")))
        .withColumn("day_of_year", dayofyear(col("date_key")))
        .withColumn("week_of_year", weekofyear(col("date_key")))
        .withColumn("month_name", date_format(col("date_key"), "MMMM"))
        .withColumn("month_short_name", date_format(col("date_key"), "MMM"))
        .withColumn("day_name", date_format(col("date_key"), "EEEE"))
        .withColumn("day_short_name", date_format(col("date_key"), "EEE"))
        .withColumn("is_weekend", when(col("day_of_week").isin([1, 7]), True).otherwise(False))
        .withColumn("is_quarter_start", when(col("month").isin([1, 4, 7, 10]), True).otherwise(False))
        .withColumn("is_quarter_end", when(col("month").isin([3, 6, 9, 12]), True).otherwise(False))
        .withColumn("fiscal_quarter", concat(col("year"), lit("-Q"), col("quarter")))
        .withColumn("fiscal_year_month", concat(col("year"), lit("-"), lpad(col("month"), 2, "0")))
        .withColumn("created_timestamp", current_timestamp())
    )
