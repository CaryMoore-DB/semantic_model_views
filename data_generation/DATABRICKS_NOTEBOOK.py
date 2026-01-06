# Databricks notebook source

# COMMAND ----------

# MAGIC %md
# MAGIC # PCDM Fake Data Generation
# MAGIC
# MAGIC This notebook runs all data generation scripts to populate the PCDM with synthetic data.
# MAGIC
# MAGIC ## Execution Order:
# MAGIC 0. **Cleanup** - Drop existing tables (optional)
# MAGIC 1. Reference Data
# MAGIC 2. Party Data
# MAGIC 3. Geographic Location Data
# MAGIC 4. Product Data
# MAGIC 5. Policy Data
# MAGIC 6. Claim Data

# COMMAND ----------

# MAGIC %md
# MAGIC ## Configuration

# COMMAND ----------

# Set your target catalog and schema
CATALOG = "cmoore_user"
SCHEMA = "pcdm_test"  # Change this to your target schema

# Update the config
import sys
sys.path.append(".")

from config import DATABASE_CONFIG
DATABASE_CONFIG['catalog'] = CATALOG
DATABASE_CONFIG['schema'] = SCHEMA

print(f"Target: {CATALOG}.{SCHEMA}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Step 0: Cleanup (Optional)
# MAGIC 
# MAGIC **⚠️ WARNING**: This will drop all existing PCDM tables!
# MAGIC 
# MAGIC Uncomment the line below to run cleanup before generating new data.

# COMMAND ----------

# UNCOMMENT THE LINE BELOW TO DROP ALL TABLES BEFORE REGENERATING
# %run ./00_cleanup_tables

# COMMAND ----------

# MAGIC %md
# MAGIC ## Step 1: Reference Data

# COMMAND ----------

# MAGIC %run ./01_generate_reference_data

# COMMAND ----------

# MAGIC %md
# MAGIC ## Step 2: Party Data

# COMMAND ----------

# MAGIC %run ./02_generate_parties

# COMMAND ----------

# MAGIC %md
# MAGIC ## Step 3: Geographic Location Data

# COMMAND ----------

# MAGIC %run ./03_generate_locations

# COMMAND ----------

# MAGIC %md
# MAGIC ## Step 4: Product Data

# COMMAND ----------

# MAGIC %run ./04_generate_products

# COMMAND ----------

# MAGIC %md
# MAGIC ## Step 5: Policy Data

# COMMAND ----------

# MAGIC %run ./05_generate_policies

# COMMAND ----------

# MAGIC %md
# MAGIC ## Step 6: Claim Data

# COMMAND ----------

# MAGIC %run ./09_generate_claims

# COMMAND ----------

# MAGIC %md
# MAGIC ## Summary
# MAGIC
# MAGIC Data generation complete! 
# MAGIC
# MAGIC You can now query the generated data:
# MAGIC ```sql
# MAGIC SELECT COUNT(*) FROM main.pcdm_test.policy;
# MAGIC SELECT COUNT(*) FROM main.pcdm_test.claim;
# MAGIC ```

# COMMAND ----------

# Display summary statistics
summary_queries = [
    ("Parties", f"SELECT COUNT(*) as count FROM {CATALOG}.{SCHEMA}.party"),
    ("Persons", f"SELECT COUNT(*) as count FROM {CATALOG}.{SCHEMA}.person"),
    ("Organizations", f"SELECT COUNT(*) as count FROM {CATALOG}.{SCHEMA}.organization"),
    ("Geographic Locations", f"SELECT COUNT(*) as count FROM {CATALOG}.{SCHEMA}.geographic_location"),
    ("Products", f"SELECT COUNT(*) as count FROM {CATALOG}.{SCHEMA}.product"),
    ("Policies", f"SELECT COUNT(*) as count FROM {CATALOG}.{SCHEMA}.policy"),
    ("Occurrences", f"SELECT COUNT(*) as count FROM {CATALOG}.{SCHEMA}.occurrence"),
    ("Claims", f"SELECT COUNT(*) as count FROM {CATALOG}.{SCHEMA}.claim"),
]

print("=" * 60)
print("DATA GENERATION SUMMARY")
print("=" * 60)

for entity, query in summary_queries:
    result = spark.sql(query).collect()[0][0]
    print(f"{entity}: {result:,}")

print("=" * 60)
