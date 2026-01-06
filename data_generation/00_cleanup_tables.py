# Databricks notebook source

# COMMAND ----------

# MAGIC %md
# MAGIC # PCDM Table Cleanup
# MAGIC 
# MAGIC This notebook drops all PCDM tables to allow for clean regeneration of data.
# MAGIC 
# MAGIC **WARNING**: This will delete all data in the specified catalog and schema!

# COMMAND ----------

from config import DATABASE_CONFIG

catalog = DATABASE_CONFIG['catalog']
schema = DATABASE_CONFIG['schema']

print("=" * 80)
print(f"CLEANING UP PCDM TABLES")
print(f"Catalog: {catalog}")
print(f"Schema: {schema}")
print("=" * 80)

# COMMAND ----------

# List of all PCDM tables in reverse dependency order
tables_to_drop = [
    # Dependent tables first
    'claim_party_role',
    'claim_coverage',
    'claim',
    'occurrence',
    'catastrophe',
    'policy_deductible',
    'policy_limit',
    'policy_coverage_detail',
    'agreement_party_role',
    'policy',
    'agreement',
    'geographic_location',
    'location_address',
    'product',
    'line_of_business',
    'company',
    'coverage',
    'coverage_type',
    'coverage_group',
    'coverage_part',
    'coverage_limit_type',
    'line_of_business_group',
    'insurance_class',
    'staff_classification',
    'household',
    'grouping',
    'organization',
    'person',
    'party',
    'party_role',
    'state',
]

# COMMAND ----------

dropped_count = 0
skipped_count = 0

for table_name in tables_to_drop:
    try:
        full_table_name = f"{catalog}.{schema}.{table_name}"
        spark.sql(f"DROP TABLE IF EXISTS {full_table_name}")
        print(f"✓ Dropped: {table_name}")
        dropped_count += 1
    except Exception as e:
        print(f"⚠ Skipped {table_name}: {str(e)}")
        skipped_count += 1

# COMMAND ----------

print("\n" + "=" * 80)
print("CLEANUP COMPLETE")
print("=" * 80)
print(f"Tables dropped: {dropped_count}")
print(f"Tables skipped: {skipped_count}")
print("=" * 80)
print("\nReady for fresh data generation!")
