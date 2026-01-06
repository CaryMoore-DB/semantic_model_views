"""
Delta Live Tables Pipeline - Policy Dimension (SCD Type 2)
Hierarchy: Group (1:Many) -> Policy (1:Many) -> Risk
"""
import dlt
from pyspark.sql.functions import (
    col, coalesce, when, lit, current_timestamp, datediff, current_date, to_date,
    count, countDistinct
)

SOURCE_CATALOG = "main"
SOURCE_SCHEMA = "pcdm"

@dlt.table(
    name="dim_policy_source",
    comment="Source data for Policy dimension from PCDM",
    table_properties={"quality": "bronze"}
)
def dim_policy_source():
    """
    Extract and transform source data from PCDM for Policy dimension
    Includes linkage to Group via agreement_party_role
    """
    return (
        spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.policy")
        .alias("pol")
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.agreement").alias("agr"),
            col("pol.agreement_id") == col("agr.agreement_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.product").alias("prd"),
            col("agr.product_id") == col("prd.product_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.line_of_business").alias("lob"),
            col("prd.line_of_business_id") == col("lob.line_of_business_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.line_of_business_group").alias("lobg"),
            col("lob.line_of_business_group_id") == col("lobg.line_of_business_group_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.insurance_class").alias("ic"),
            col("lob.insurance_class_id") == col("ic.insurance_class_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.geographic_location").alias("gl"),
            col("pol.geographic_location_id") == col("gl.geographic_location_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.state").alias("st"),
            col("gl.state_code") == col("st.state_code"),
            "left"
        )
        .join(
            # Get the Group key via agreement_party_role
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.agreement_party_role").alias("apr")
            .where(col("party_role_code") == "GROUP"),
            col("agr.agreement_id") == col("apr.agreement_id"),
            "left"
        )
        .join(
            # Get grouping_id from party
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.party").alias("p"),
            col("apr.party_id") == col("p.party_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.grouping").alias("grp"),
            col("p.party_id") == col("grp.party_id"),
            "left"
        )
        .select(
            col("pol.policy_id").alias("policy_key"),
            col("grp.grouping_id").alias("group_key"),
            col("pol.policy_number"),
            to_date(col("pol.effective_date")).alias("effective_date"),
            to_date(col("pol.expiration_date")).alias("expiration_date"),
            col("pol.status_code"),
            col("agr.agreement_id"),
            col("agr.agreement_name"),
            col("agr.agreement_type_code"),
            to_date(col("agr.agreement_original_inception_date")).alias("agreement_original_inception_date"),
            col("prd.product_id"),
            col("prd.licensed_product_name").alias("product_name"),
            col("prd.product_description"),
            col("lob.line_of_business_id"),
            col("lob.line_of_business_name"),
            col("lob.line_of_business_code"),
            col("lob.line_of_business_description"),
            col("lobg.line_of_business_group_id"),
            col("lobg.line_of_business_group_name"),
            col("ic.insurance_class_id"),
            col("ic.insurance_class_name"),
            col("gl.geographic_location_id"),
            col("gl.location_name"),
            col("gl.state_code"),
            col("st.state_name"),
            datediff(col("pol.expiration_date"), col("pol.effective_date")).alias("policy_term_days"),
            datediff(current_date(), col("pol.effective_date")).alias("policy_age_days"),
            when(
                (col("pol.status_code") == "ACTIVE") &
                (current_date().between(col("pol.effective_date"), col("pol.expiration_date"))),
                lit(True)
            ).otherwise(lit(False)).alias("is_active"),
            current_timestamp().alias("source_timestamp")
        )
    )


@dlt.table(
    name="dim_policy_coverage_counts",
    comment="Coverage counts per policy",
    table_properties={"quality": "bronze"}
)
def dim_policy_coverage_counts():
    """Calculate coverage part counts per policy"""
    return (
        spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.policy_coverage_part")
        .groupBy("policy_id")
        .agg(countDistinct("coverage_part_code").alias("coverage_part_count"))
    )


@dlt.table(
    name="dim_policy",
    comment="Policy Dimension - SCD Type 2. Middle of hierarchy: Group -> Policy -> Risk",
    table_properties={
        "quality": "silver",
        "delta.enableChangeDataFeed": "true",
        "pipelines.autoOptimize.zOrderCols": "policy_key,group_key"
    }
)
@dlt.expect_all_or_drop({
    "valid_policy_key": "policy_key IS NOT NULL",
    "valid_group_key": "group_key IS NOT NULL",
    "valid_policy_number": "policy_number IS NOT NULL AND LENGTH(policy_number) > 0",
    "valid_effective_date": "effective_date IS NOT NULL",
    "valid_expiration_date": "expiration_date IS NOT NULL",
    "dates_in_order": "effective_date <= expiration_date",
    "policy_term_positive": "policy_term_days > 0"
})
def dim_policy():
    """
    Apply SCD Type 2 logic to Policy dimension
    """
    source_df = dlt.read("dim_policy_source")
    coverage_df = dlt.read("dim_policy_coverage_counts")
    
    # Join coverage counts
    result_df = (
        source_df
        .join(
            coverage_df,
            source_df.policy_key == coverage_df.policy_id,
            "left"
        )
        .drop("policy_id")
        .fillna({"coverage_part_count": 0})
    )
    
    # SCD Type 2 - simplified initial load
    return (
        result_df
        .withColumn("effective_begin_date", current_timestamp())
        .withColumn("effective_end_date", lit(None).cast("timestamp"))
        .withColumn("is_current", lit(True))
        .withColumn("created_timestamp", current_timestamp())
        .withColumn("updated_timestamp", current_timestamp())
        .drop("source_timestamp")
    )
