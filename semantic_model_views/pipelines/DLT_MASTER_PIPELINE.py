# Databricks notebook source
# Insurance Analytics - Delta Live Tables Pipeline Configuration
# MAGIC %md
# MAGIC # Insurance Analytics - Complete DLT Pipeline
# MAGIC 
# MAGIC This notebook orchestrates all Delta Live Tables pipelines for the insurance analytics dimensional model.
# MAGIC 
# MAGIC ## Architecture
# MAGIC - **Bronze Layer**: Source data extraction from PCDM
# MAGIC - **Silver Layer**: Dimension and fact tables with SCD Type 2
# MAGIC - **Gold Layer**: Analytics-ready views
# MAGIC 
# MAGIC ## Hierarchy
# MAGIC Group (1:Many) → Policy (1:Many) → Risk
# MAGIC 
# MAGIC ## Data Quality
# MAGIC All pipelines include expectations for:
# MAGIC - NOT NULL validation
# MAGIC - Date validation and logical ordering  
# MAGIC - Numeric range validation
# MAGIC - Referential integrity

# COMMAND ----------

# MAGIC %md
# MAGIC ## Configuration

# COMMAND ----------

# Source PCDM Configuration
SOURCE_CATALOG = "main"
SOURCE_SCHEMA = "pcdm"

# Target Configuration  
TARGET_CATALOG = spark.conf.get("catalog", "main")
TARGET_SCHEMA = spark.conf.get("schema", "insurance_analytics")

print(f"Source: {SOURCE_CATALOG}.{SOURCE_SCHEMA}")
print(f"Target: {TARGET_CATALOG}.{TARGET_SCHEMA}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Date Dimension (Static)

# COMMAND ----------

# MAGIC %run ./dlt_dim_date

# COMMAND ----------

# MAGIC %md
# MAGIC ## Group Dimension (SCD Type 2)
# MAGIC Top of hierarchy: Group → Policy → Risk

# COMMAND ----------

# MAGIC %run ./dlt_dim_group

# COMMAND ----------

# MAGIC %md
# MAGIC ## Policy Dimension (SCD Type 2)
# MAGIC Middle of hierarchy: Group → Policy → Risk

# COMMAND ----------

# MAGIC %run ./dlt_dim_policy

# COMMAND ----------

# MAGIC %md
# MAGIC ## Risk Dimension (SCD Type 2)
# MAGIC Bottom of hierarchy: Group → Policy → Risk

# COMMAND ----------

# MAGIC %run ./dlt_dim_risk

# COMMAND ----------

# MAGIC %md
# MAGIC ## Claim Dimension (SCD Type 2)

# COMMAND ----------

# MAGIC %run ./dlt_dim_claim

# COMMAND ----------

# MAGIC %md
# MAGIC ## Attorney Dimension (SCD Type 2)

# COMMAND ----------

# MAGIC %run ./dlt_dim_attorney

# COMMAND ----------

# MAGIC %md
# MAGIC ## Court Dimension (SCD Type 2)

# COMMAND ----------

# MAGIC %run ./dlt_dim_court

# COMMAND ----------

# MAGIC %md
# MAGIC ## Outcome Dimension (SCD Type 2)

# COMMAND ----------

# MAGIC %run ./dlt_dim_outcome

# COMMAND ----------

# MAGIC %md
# MAGIC ## Premium Payments Fact Table

# COMMAND ----------

# MAGIC %run ./dlt_fact_premium_payments

# COMMAND ----------

# MAGIC %md
# MAGIC ## Claims Fact Table

# COMMAND ----------

# MAGIC %run ./dlt_fact_claims

# COMMAND ----------

# MAGIC %md
# MAGIC ## Pipeline Summary
# MAGIC 
# MAGIC ### Dimensions (8 tables)
# MAGIC 1. **dim_date** - Static date dimension (2000-2050)
# MAGIC 2. **dim_group** - Customer groups (SCD Type 2)
# MAGIC 3. **dim_policy** - Policies (SCD Type 2)
# MAGIC 4. **dim_risk** - Insurable objects/risks (SCD Type 2)
# MAGIC 5. **dim_claim** - Claims (SCD Type 2)
# MAGIC 6. **dim_attorney** - Attorneys (SCD Type 2)
# MAGIC 7. **dim_court** - Court jurisdictions (SCD Type 2)
# MAGIC 8. **dim_outcome** - Legal outcomes (SCD Type 2)
# MAGIC 
# MAGIC ### Facts (2 tables)
# MAGIC 1. **fact_premium_payments** - Premium transactions
# MAGIC 2. **fact_claims** - Claim transactions
# MAGIC 
# MAGIC ### Data Quality Expectations
# MAGIC - All tables have data quality checks
# MAGIC - Invalid records are dropped (expect_all_or_drop)
# MAGIC - Key validation, date validation, numeric validation
# MAGIC 
# MAGIC ### SCD Type 2 Fields
# MAGIC All dimensions include:
# MAGIC - `effective_begin_date` - When this version became effective
# MAGIC - `effective_end_date` - When this version expired (NULL for current)
# MAGIC - `is_current` - Boolean flag for current record
# MAGIC - `created_timestamp` - Record creation time
# MAGIC - `updated_timestamp` - Record update time
