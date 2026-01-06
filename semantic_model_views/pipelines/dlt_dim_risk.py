# Databricks notebook source
"""
Delta Live Tables Pipeline - Risk Dimension (SCD Type 2)
Hierarchy: Group (1:Many) -> Policy (1:Many) -> Risk
"""
import dlt
from pyspark.sql.functions import (
    col, coalesce, when, lit, current_timestamp, to_date
)

SOURCE_CATALOG = "main"
SOURCE_SCHEMA = "pcdm"

@dlt.table(
    name="dim_risk_source",
    comment="Source data for Risk dimension from PCDM",
    table_properties={"quality": "bronze"}
)
def dim_risk_source():
    """
    Extract and transform source data from PCDM for Risk dimension
    Includes linkage to Policy via policy_coverage_detail
    """
    return (
        spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.insurable_object")
        .alias("io")
        # Link to policy through policy_coverage_detail
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.policy_coverage_detail").alias("pcd"),
            col("io.insurable_object_id") == col("pcd.insurable_object_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.policy_coverage_part").alias("pcp"),
            col("pcd.policy_coverage_part_id") == col("pcp.policy_coverage_part_id"),
            "left"
        )
        # Vehicle information
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.vehicle").alias("v"),
            col("io.insurable_object_id") == col("v.insurable_object_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.automobile").alias("auto"),
            col("v.vehicle_id") == col("auto.vehicle_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.truck").alias("trk"),
            col("v.vehicle_id") == col("trk.vehicle_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.van").alias("van"),
            col("v.vehicle_id") == col("van.vehicle_id"),
            "left"
        )
        # Structure information
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.structure").alias("str"),
            col("io.insurable_object_id") == col("str.insurable_object_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.commercial_structure").alias("cs"),
            col("str.structure_id") == col("cs.structure_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.residential_structure").alias("rs"),
            col("str.structure_id") == col("rs.structure_id"),
            "left"
        )
        # Geographic information
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.geographic_location").alias("gl"),
            col("io.geographic_location_id") == col("gl.geographic_location_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.state").alias("st"),
            col("gl.state_code") == col("st.state_code"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.location_address").alias("la"),
            col("gl.location_address_id") == col("la.location_address_id"),
            "left"
        )
        .select(
            col("io.insurable_object_id").alias("risk_key"),
            col("pcp.policy_id").alias("policy_key"),
            col("io.insurable_object_type_code"),
            # Risk category
            when(col("v.vehicle_id").isNotNull(), lit("Vehicle"))
            .when(col("str.structure_id").isNotNull(), lit("Structure"))
            .otherwise(lit("Other")).alias("risk_category"),
            # Vehicle attributes
            col("v.vehicle_id"),
            col("v.vehicle_identification_number").alias("vin"),
            col("v.vehicle_make_name"),
            col("v.vehicle_model_name"),
            col("v.vehicle_model_year"),
            when(col("auto.automobile_id").isNotNull(), lit("Automobile"))
            .when(col("trk.truck_id").isNotNull(), lit("Truck"))
            .when(col("van.van_id").isNotNull(), lit("Van"))
            .otherwise(lit(None)).alias("vehicle_type"),
            # Structure attributes
            col("str.structure_id"),
            when(col("cs.commercial_structure_id").isNotNull(), lit("Commercial"))
            .when(col("rs.residential_structure_id").isNotNull(), lit("Residential"))
            .otherwise(lit(None)).alias("structure_type"),
            col("rs.dwelling_id"),
            col("rs.mobile_home_id"),
            # Other attributes
            lit(None).cast("string").alias("farm_equipment_id"),
            lit(None).cast("string").alias("farm_equipment_type"),
            lit(None).cast("string").alias("workers_comp_class_id"),
            lit(None).cast("string").alias("transportation_class_id"),
            # Geographic attributes
            col("gl.geographic_location_id"),
            col("gl.location_name"),
            col("gl.location_code"),
            col("gl.state_code"),
            col("st.state_name"),
            # Address attributes
            col("la.location_address_id"),
            col("la.line_1_address"),
            col("la.line_2_address"),
            col("la.municipality_name"),
            col("la.postal_code"),
            current_timestamp().alias("source_timestamp")
        )
        .dropDuplicates(["risk_key", "policy_key"])
    )


@dlt.table(
    name="dim_risk",
    comment="Risk Dimension - SCD Type 2. Bottom of hierarchy: Group -> Policy -> Risk",
    table_properties={
        "quality": "silver",
        "delta.enableChangeDataFeed": "true",
        "pipelines.autoOptimize.zOrderCols": "risk_key,policy_key"
    }
)
@dlt.expect_all_or_drop({
    "valid_risk_key": "risk_key IS NOT NULL",
    "valid_policy_key": "policy_key IS NOT NULL",
    "valid_risk_category": "risk_category IN ('Vehicle', 'Structure', 'Other')",
    "vehicle_has_make_or_null": "vehicle_id IS NULL OR vehicle_make_name IS NOT NULL",
    "structure_has_type_or_null": "structure_id IS NULL OR structure_type IS NOT NULL"
})
def dim_risk():
    """
    Apply SCD Type 2 logic to Risk dimension
    """
    source_df = dlt.read("dim_risk_source")
    
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
