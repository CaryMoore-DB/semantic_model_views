# Databricks notebook source
"""
Delta Live Tables Pipeline - Court Dimension (SCD Type 2)
"""
import dlt
from pyspark.sql.functions import (
    col, when, lit, current_timestamp
)

SOURCE_CATALOG = "main"
SOURCE_SCHEMA = "pcdm"

@dlt.table(
    name="dim_court_source",
    comment="Source data for Court dimension from PCDM",
    table_properties={"quality": "bronze"}
)
def dim_court_source():
    """
    Extract and transform source data from PCDM for Court dimension
    """
    return (
        spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.court_jurisdiction")
        .alias("cj")
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.legal_jurisdiction").alias("lj"),
            col("cj.jurisdiction_id") == col("lj.legal_jurisdiction_id"),
            "left"
        )
        .select(
            col("cj.court_jurisdiction_id").alias("court_key"),
            col("cj.court_jurisdiction_id"),
            col("cj.court_id"),
            col("cj.jurisdiction_id"),
            col("lj.legal_jurisdiction_id"),
            col("lj.legal_jurisdiction_name"),
            col("lj.legal_jurisdiction_description"),
            col("lj.rules_preference_description"),
            when(col("lj.legal_jurisdiction_name").contains("Federal"), lit("Federal"))
            .when(col("lj.legal_jurisdiction_name").contains("State"), lit("State"))
            .when(col("lj.legal_jurisdiction_name").contains("County"), lit("County"))
            .otherwise(lit("Other")).alias("court_level"),
            col("lj.legal_jurisdiction_name").alias("court_location"),
            current_timestamp().alias("source_timestamp")
        )
    )


@dlt.table(
    name="dim_court",
    comment="Court Dimension - SCD Type 2",
    table_properties={
        "quality": "silver",
        "delta.enableChangeDataFeed": "true",
        "pipelines.autoOptimize.zOrderCols": "court_key"
    }
)
@dlt.expect_all_or_drop({
    "valid_court_key": "court_key IS NOT NULL",
    "valid_court_level": "court_level IN ('Federal', 'State', 'County', 'Other')"
})
def dim_court():
    """
    Apply SCD Type 2 logic to Court dimension
    """
    source_df = dlt.read("dim_court_source")
    
    # SCD Type 2 - simplified initial load
    return (
        source_df
        .withColumn("effective_begin_date", current_timestamp())
        .withColumn("effective_end_date", lit(None).cast("timestamp"))
        .withColumn("is_current", lit(True))
        .withColumn("created_timestamp", current_timestamp())
        .withColumn("updated_timestamp", current_timestamp())
        .drop("source_timestamp")
    )
