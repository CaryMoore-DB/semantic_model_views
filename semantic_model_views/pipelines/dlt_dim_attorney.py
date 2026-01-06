# Databricks notebook source
"""
Delta Live Tables Pipeline - Attorney Dimension (SCD Type 2)
"""
import dlt
from pyspark.sql.functions import (
    col, coalesce, when, lit, current_timestamp, current_date, to_date
)

SOURCE_CATALOG = "main"
SOURCE_SCHEMA = "pcdm"

@dlt.table(
    name="dim_attorney_source",
    comment="Source data for Attorney dimension from PCDM",
    table_properties={"quality": "bronze"}
)
def dim_attorney_source():
    """
    Extract and transform source data from PCDM for Attorney dimension
    """
    return (
        spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.attorney")
        .alias("att")
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.provider").alias("prv"),
            col("att.provider_id") == col("prv.provider_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.party_role").alias("pr"),
            col("prv.party_role_code") == col("pr.party_role_code"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.party").alias("p"),
            col("prv.party_id") == col("p.party_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.person").alias("per"),
            col("p.party_id") == col("per.party_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.organization").alias("org"),
            col("p.party_id") == col("org.party_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.geographic_location").alias("gl"),
            col("p.geographic_location_id") == col("gl.geographic_location_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.location_address").alias("la"),
            col("gl.location_address_id") == col("la.location_address_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.state").alias("st"),
            col("la.state_code") == col("st.state_code"),
            "left"
        )
        .select(
            col("att.attorney_id").alias("attorney_key"),
            col("att.attorney_id"),
            col("prv.provider_id"),
            col("prv.party_role_code").alias("provider_party_role_code"),
            col("p.party_id"),
            col("p.party_name").alias("attorney_name"),
            col("p.party_type_code"),
            col("per.person_id"),
            col("per.prefix_name"),
            col("per.first_name"),
            col("per.middle_name"),
            col("per.last_name"),
            col("per.suffix_name"),
            col("per.full_legal_name"),
            col("org.organization_id").alias("law_firm_id"),
            col("org.organization_name").alias("law_firm_name"),
            col("org.organization_type_code").alias("law_firm_type_code"),
            lit(None).cast("string").alias("communication_id"),
            lit(None).cast("string").alias("communication_type_code"),
            lit(None).cast("string").alias("communication_value"),
            col("la.location_address_id"),
            col("la.line_1_address"),
            col("la.line_2_address"),
            col("la.municipality_name").alias("city"),
            col("la.state_code"),
            col("st.state_name"),
            col("la.postal_code"),
            to_date(col("p.begin_date")).alias("begin_date"),
            to_date(col("p.end_date")).alias("end_date"),
            when(
                (col("p.end_date").isNull()) | (col("p.end_date") >= current_date()),
                lit(True)
            ).otherwise(lit(False)).alias("is_active"),
            current_timestamp().alias("source_timestamp")
        )
    )


@dlt.table(
    name="dim_attorney",
    comment="Attorney Dimension - SCD Type 2",
    table_properties={
        "quality": "silver",
        "delta.enableChangeDataFeed": "true",
        "pipelines.autoOptimize.zOrderCols": "attorney_key"
    }
)
@dlt.expect_all_or_drop({
    "valid_attorney_key": "attorney_key IS NOT NULL",
    "valid_attorney_name": "attorney_name IS NOT NULL",
    "dates_logical": "end_date IS NULL OR begin_date IS NULL OR begin_date <= end_date"
})
def dim_attorney():
    """
    Apply SCD Type 2 logic to Attorney dimension
    """
    source_df = dlt.read("dim_attorney_source")
    
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
