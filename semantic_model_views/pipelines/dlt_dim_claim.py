"""
Delta Live Tables Pipeline - Claim Dimension (SCD Type 2)
"""
import dlt
from pyspark.sql.functions import (
    col, coalesce, when, lit, current_timestamp, datediff, current_date, to_date
)

SOURCE_CATALOG = "main"
SOURCE_SCHEMA = "pcdm"

@dlt.table(
    name="dim_claim_source",
    comment="Source data for Claim dimension from PCDM",
    table_properties={"quality": "bronze"}
)
def dim_claim_source():
    """
    Extract and transform source data from PCDM for Claim dimension
    """
    return (
        spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.claim")
        .alias("clm")
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.occurrence").alias("occ"),
            col("clm.occurrence_id") == col("occ.occurrence_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.geographic_location").alias("gl"),
            col("occ.geographic_location_id") == col("gl.geographic_location_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.state").alias("st"),
            col("gl.state_code") == col("st.state_code"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.catastrophe").alias("cat"),
            col("clm.catastrophe_id") == col("cat.catastrophe_id"),
            "left"
        )
        .select(
            col("clm.claim_id").alias("claim_key"),
            col("clm.company_claim_number"),
            col("clm.company_subclaim_number"),
            col("clm.claim_description"),
            to_date(col("clm.claim_open_date")).alias("claim_open_date"),
            to_date(col("clm.claim_close_date")).alias("claim_close_date"),
            to_date(col("clm.claim_reopen_date")).alias("claim_reopen_date"),
            to_date(col("clm.claim_reported_date")).alias("claim_reported_date"),
            to_date(col("clm.claims_made_date")).alias("claims_made_date"),
            col("clm.claim_status_code"),
            when(col("clm.claim_close_date").isNotNull(), lit(True)).otherwise(lit(False)).alias("is_closed"),
            when(col("clm.claim_reopen_date").isNotNull(), lit(True)).otherwise(lit(False)).alias("is_reopened"),
            when(col("clm.claim_status_code") == "OPEN", lit(True)).otherwise(lit(False)).alias("is_open"),
            datediff(
                coalesce(col("clm.claim_close_date"), current_date()),
                col("clm.claim_open_date")
            ).alias("days_open"),
            datediff(col("clm.claim_reported_date"), col("clm.claim_open_date")).alias("reporting_lag_days"),
            col("occ.occurrence_id"),
            to_date(col("occ.occurrence_begin_date")).alias("occurrence_begin_date"),
            col("occ.occurrence_begin_time"),
            to_date(col("occ.occurrence_end_date")).alias("occurrence_end_date"),
            col("occ.occurrence_end_time"),
            col("occ.catastrophic_event_indicator"),
            col("gl.geographic_location_id").alias("occurrence_location_id"),
            col("gl.location_name").alias("occurrence_location_name"),
            col("gl.state_code").alias("occurrence_state_code"),
            col("st.state_name").alias("occurrence_state_name"),
            col("cat.catastrophe_id"),
            col("cat.catastrophe_name"),
            col("cat.catastrophe_type_code"),
            col("cat.industry_catastrophe_code"),
            col("cat.company_catastrophe_code"),
            when(col("cat.catastrophe_id").isNotNull(), lit(True)).otherwise(lit(False)).alias("is_catastrophe"),
            col("clm.insurable_object_id"),
            lit(0).alias("coverage_count"),  # Will be updated via subquery
            lit(False).alias("has_litigation"),  # Will be updated via subquery
            lit(False).alias("has_arbitration"),  # Will be updated via subquery
            current_timestamp().alias("source_timestamp")
        )
    )


@dlt.table(
    name="dim_claim",
    comment="Claim Dimension - SCD Type 2",
    table_properties={
        "quality": "silver",
        "delta.enableChangeDataFeed": "true",
        "pipelines.autoOptimize.zOrderCols": "claim_key"
    }
)
@dlt.expect_all_or_drop({
    "valid_claim_key": "claim_key IS NOT NULL",
    "valid_claim_number": "company_claim_number IS NOT NULL",
    "valid_open_date": "claim_open_date IS NOT NULL",
    "dates_logical": "claim_close_date IS NULL OR claim_open_date <= claim_close_date",
    "days_open_positive": "days_open >= 0"
})
def dim_claim():
    """
    Apply SCD Type 2 logic to Claim dimension
    """
    source_df = dlt.read("dim_claim_source")
    
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
