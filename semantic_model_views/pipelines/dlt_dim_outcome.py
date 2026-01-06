# Databricks notebook source
"""
Delta Live Tables Pipeline - Outcome Dimension (SCD Type 2)
"""
import dlt
from pyspark.sql.functions import (
    col, concat, lit, current_timestamp, to_date
)

SOURCE_CATALOG = "main"
SOURCE_SCHEMA = "pcdm"

@dlt.table(
    name="dim_outcome_litigation_source",
    comment="Source data for Outcome dimension from litigation",
    table_properties={"quality": "bronze"}
)
def dim_outcome_litigation_source():
    """
    Extract litigation outcomes from PCDM
    """
    return (
        spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.litigation")
        .alias("lit")
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.court_jurisdiction").alias("cj"),
            col("lit.court_jurisdiction_id") == col("cj.court_jurisdiction_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.legal_jurisdiction").alias("lj"),
            col("cj.jurisdiction_id") == col("lj.legal_jurisdiction_id"),
            "left"
        )
        .select(
            concat(lit("L-"), col("lit.litigation_id")).alias("outcome_key"),
            lit("Litigation").alias("outcome_type"),
            col("lit.litigation_id").alias("outcome_id"),
            col("lit.litigation_description"),
            col("lit.court_jurisdiction_id"),
            lit(None).cast("string").alias("outcome_status_code"),
            lit(None).cast("string").alias("outcome_result"),
            lit(None).cast("decimal(18,2)").alias("judgment_amount"),
            lit(None).cast("decimal(18,2)").alias("settlement_amount"),
            lit(None).cast("date").alias("outcome_date"),
            col("cj.court_id"),
            col("cj.jurisdiction_id"),
            col("lj.legal_jurisdiction_name"),
            current_timestamp().alias("source_timestamp")
        )
    )


@dlt.table(
    name="dim_outcome_arbitration_source",
    comment="Source data for Outcome dimension from arbitration",
    table_properties={"quality": "bronze"}
)
def dim_outcome_arbitration_source():
    """
    Extract arbitration outcomes from PCDM
    """
    return (
        spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.arbitration")
        .select(
            concat(lit("A-"), col("arbitration_id")).alias("outcome_key"),
            lit("Arbitration").alias("outcome_type"),
            col("arbitration_id").alias("outcome_id"),
            col("arbitration_description").alias("litigation_description"),
            lit(None).cast("string").alias("court_jurisdiction_id"),
            lit(None).cast("string").alias("outcome_status_code"),
            lit(None).cast("string").alias("outcome_result"),
            lit(None).cast("decimal(18,2)").alias("judgment_amount"),
            lit(None).cast("decimal(18,2)").alias("settlement_amount"),
            lit(None).cast("date").alias("outcome_date"),
            lit(None).cast("string").alias("court_id"),
            lit(None).cast("string").alias("jurisdiction_id"),
            lit(None).cast("string").alias("legal_jurisdiction_name"),
            current_timestamp().alias("source_timestamp")
        )
    )


@dlt.table(
    name="dim_outcome_source",
    comment="Combined outcome source (litigation + arbitration)",
    table_properties={"quality": "bronze"}
)
def dim_outcome_source():
    """
    Combine litigation and arbitration outcomes
    """
    lit_df = dlt.read("dim_outcome_litigation_source")
    arb_df = dlt.read("dim_outcome_arbitration_source")
    
    return lit_df.union(arb_df)


@dlt.table(
    name="dim_outcome",
    comment="Outcome Dimension - SCD Type 2",
    table_properties={
        "quality": "silver",
        "delta.enableChangeDataFeed": "true",
        "pipelines.autoOptimize.zOrderCols": "outcome_key"
    }
)
@dlt.expect_all_or_drop({
    "valid_outcome_key": "outcome_key IS NOT NULL",
    "valid_outcome_type": "outcome_type IN ('Litigation', 'Arbitration')",
    "valid_amounts": "judgment_amount IS NULL OR judgment_amount >= 0"
})
def dim_outcome():
    """
    Apply SCD Type 2 logic to Outcome dimension
    """
    source_df = dlt.read("dim_outcome_source")
    
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
