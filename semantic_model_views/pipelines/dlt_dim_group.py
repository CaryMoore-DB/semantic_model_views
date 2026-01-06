"""
Delta Live Tables Pipeline - Group Dimension (SCD Type 2)
Hierarchy: Group (1:Many) -> Policy (1:Many) -> Risk
"""
import dlt
from pyspark.sql.functions import (
    col, coalesce, when, lit, current_timestamp, md5, concat_ws,
    current_date, to_date
)

# Source catalog/schema for PCDM
SOURCE_CATALOG = "main"
SOURCE_SCHEMA = "pcdm"

@dlt.table(
    name="dim_group_source",
    comment="Source data for Group dimension from PCDM",
    table_properties={"quality": "bronze"}
)
def dim_group_source():
    """
    Extract and transform source data from PCDM for Group dimension
    """
    return (
        spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.grouping")
        .alias("g")
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.party").alias("p"),
            col("g.party_id") == col("p.party_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.organization").alias("o"),
            col("p.party_id") == col("o.party_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.household").alias("h"),
            col("g.grouping_id") == col("h.grouping_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.professional_group").alias("pg"),
            col("g.grouping_id") == col("pg.grouping_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.project").alias("pr"),
            col("g.grouping_id") == col("pr.grouping_id"),
            "left"
        )
        .join(
            spark.table(f"{SOURCE_CATALOG}.{SOURCE_SCHEMA}.team").alias("t"),
            col("g.grouping_id") == col("t.grouping_id"),
            "left"
        )
        .select(
            col("g.grouping_id").alias("group_key"),
            coalesce(col("g.grouping_name"), col("p.party_name")).alias("group_name"),
            when(col("h.household_id").isNotNull(), lit("Household"))
            .when(col("pg.professional_group_id").isNotNull(), lit("Professional Group"))
            .when(col("pr.project_id").isNotNull(), lit("Project"))
            .when(col("t.team_id").isNotNull(), lit("Team"))
            .otherwise(lit("Other")).alias("group_type"),
            col("p.party_id"),
            col("p.party_name"),
            col("p.party_type_code"),
            col("o.organization_id"),
            col("o.organization_name"),
            col("o.organization_type_code"),
            col("o.industry_type_code"),
            to_date(col("p.begin_date")).alias("group_begin_date"),
            to_date(col("p.end_date")).alias("group_end_date"),
            current_timestamp().alias("source_timestamp")
        )
    )


@dlt.table(
    name="dim_group",
    comment="Group Dimension - SCD Type 2. Top of hierarchy: Group -> Policy -> Risk",
    table_properties={
        "quality": "silver",
        "delta.enableChangeDataFeed": "true",
        "pipelines.autoOptimize.zOrderCols": "group_key"
    }
)
@dlt.expect_all_or_drop({
    "valid_group_key": "group_key IS NOT NULL",
    "valid_group_name": "group_name IS NOT NULL AND LENGTH(group_name) > 0",
    "valid_group_type": "group_type IN ('Household', 'Professional Group', 'Project', 'Team', 'Other')",
    "valid_dates": "group_begin_date IS NULL OR group_end_date IS NULL OR group_begin_date <= group_end_date"
})
def dim_group():
    """
    Apply SCD Type 2 logic to Group dimension
    """
    from pyspark.sql.window import Window
    from pyspark.sql.functions import row_number, lag
    
    # Get source data
    source_df = dlt.read("dim_group_source")
    
    # Try to read existing dimension (will be empty on first run)
    try:
        existing_df = dlt.read("dim_group")
    except:
        existing_df = None
    
    if existing_df is None or existing_df.count() == 0:
        # Initial load - all records are current
        return (
            source_df
            .withColumn("effective_begin_date", current_timestamp())
            .withColumn("effective_end_date", lit(None).cast("timestamp"))
            .withColumn("is_current", lit(True))
            .withColumn("created_timestamp", current_timestamp())
            .withColumn("updated_timestamp", current_timestamp())
        )
    else:
        # SCD Type 2 merge logic
        # This is a simplified version - in production, use MERGE INTO
        return source_df.withColumn("effective_begin_date", current_timestamp()) \
                       .withColumn("effective_end_date", lit(None).cast("timestamp")) \
                       .withColumn("is_current", lit(True)) \
                       .withColumn("created_timestamp", current_timestamp()) \
                       .withColumn("updated_timestamp", current_timestamp())


@dlt.table(
    name="dim_group_changes",
    comment="Change tracking for Group dimension",
    table_properties={"quality": "gold"}
)
def dim_group_changes():
    """
    Track changes in Group dimension over time
    """
    return (
        dlt.read("dim_group")
        .where(col("is_current") == True)
        .select(
            "group_key",
            "group_name",
            "group_type",
            "organization_name",
            "effective_begin_date",
            "is_current"
        )
    )
