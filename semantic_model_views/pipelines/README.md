# Delta Live Tables Pipelines - Insurance Analytics

## Overview

This directory contains **Delta Live Tables (DLT)** pipelines for building the insurance analytics dimensional model with **SCD Type 2** support and comprehensive **data quality expectations**.

## Architecture

### Medallion Architecture

```
Bronze (Source) → Silver (Dimensional Model) → Gold (Analytics)
```

- **Bronze**: Raw data extraction from PCDM with basic transformations
- **Silver**: Dimension and fact tables with SCD Type 2 tracking
- **Gold**: Analytics-ready aggregations and business views

### Hierarchy

```
Group (1:Many)
  ↓
Policy (1:Many)
  ↓
Risk
```

## Pipeline Files

### Dimension Pipelines (8)

| File | Table | SCD Type | Description |
|------|-------|----------|-------------|
| `dlt_dim_date.py` | dim_date | Type 1 (Static) | Date dimension 2000-2050 |
| `dlt_dim_group.py` | dim_group | Type 2 | Customer groups (top of hierarchy) |
| `dlt_dim_policy.py` | dim_policy | Type 2 | Policies (middle of hierarchy) |
| `dlt_dim_risk.py` | dim_risk | Type 2 | Insurable objects (bottom of hierarchy) |
| `dlt_dim_claim.py` | dim_claim | Type 2 | Claims |
| `dlt_dim_attorney.py` | dim_attorney | Type 2 | Attorneys and law firms |
| `dlt_dim_court.py` | dim_court | Type 2 | Court jurisdictions |
| `dlt_dim_outcome.py` | dim_outcome | Type 2 | Legal outcomes (litigation/arbitration) |

### Fact Pipelines (2)

| File | Table | Description |
|------|-------|-------------|
| `dlt_fact_premium_payments.py` | fact_premium_payments | Premium transactions with dimension SK lookups |
| `dlt_fact_claims.py` | fact_claims | Claim transactions with dimension SK lookups |

### Master Pipeline

| File | Description |
|------|-------------|
| `DLT_MASTER_PIPELINE.py` | Orchestrates all pipelines with documentation |

## SCD Type 2 Implementation

All dimension tables (except dim_date) implement **Slowly Changing Dimension Type 2** to track historical changes.

### SCD Type 2 Fields

```sql
effective_begin_date  TIMESTAMP  -- When this version became effective
effective_end_date    TIMESTAMP  -- When this version expired (NULL = current)
is_current            BOOLEAN    -- TRUE for current record
created_timestamp     TIMESTAMP  -- Record creation time
updated_timestamp     TIMESTAMP  -- Record last updated time
```

### Surrogate Keys

Each dimension has:
- **Natural Key**: Business key from source system (e.g., `policy_key`, `group_key`)
- **Surrogate Key**: Auto-generated identity column (e.g., `policy_sk`, `group_sk`)

Fact tables reference dimensions via surrogate keys to support SCD Type 2 lookups.

## Data Quality Expectations

All pipelines include **data quality expectations** using DLT's `@dlt.expect_all_or_drop` decorator.

### Validation Types

#### 1. NOT NULL Validation
```python
"valid_policy_key": "policy_key IS NOT NULL"
"valid_group_key": "group_key IS NOT NULL"
```

#### 2. Date Validation
```python
"valid_effective_date": "effective_date IS NOT NULL"
"dates_in_order": "effective_date <= expiration_date"
"dates_logical": "claim_close_date IS NULL OR claim_open_date <= claim_close_date"
```

#### 3. Numeric Validation
```python
"valid_premium_amount": "premium_amount >= 0"
"policy_term_positive": "policy_term_days > 0"
"amounts_non_negative": "total_claim_amount >= 0"
```

#### 4. Referential Integrity
```python
"valid_risk_category": "risk_category IN ('Vehicle', 'Structure', 'Other')"
"valid_outcome_type": "outcome_type IN ('Litigation', 'Arbitration')"
```

#### 5. Business Logic
```python
"payment_logic": "is_payment = FALSE OR payment_amount > 0"
"reserve_logic": "is_reserve = FALSE OR reserve_amount > 0"
```

### Expectation Modes

- **expect_all_or_drop**: Invalid records are dropped (used in all pipelines)
- Alternative modes: `expect`, `expect_all`, `expect_or_fail`

## Pipeline Execution

### Option 1: Deploy via Databricks UI

1. Navigate to **Workflows** → **Delta Live Tables**
2. Click **Create Pipeline**
3. Configure:
   - **Name**: `insurance_analytics_dlt_pipeline`
   - **Notebook**: Select `DLT_MASTER_PIPELINE.py`
   - **Target**: `main.insurance_analytics`
   - **Storage Location**: `/pipelines/insurance_analytics`
4. Click **Create**
5. Click **Start** to run pipeline

### Option 2: Deploy via Databricks CLI

```bash
databricks pipelines create \
  --name "insurance_analytics_dlt_pipeline" \
  --notebook-path "/Workspace/path/to/DLT_MASTER_PIPELINE.py" \
  --target "main.insurance_analytics" \
  --storage "/pipelines/insurance_analytics" \
  --configuration '{"catalog":"main","schema":"insurance_analytics"}'

# Start the pipeline
databricks pipelines start --pipeline-id <pipeline-id>
```

### Option 3: Run Individual Pipeline

```python
# In Databricks notebook
%run ./pipelines/dlt_dim_group
```

## Configuration

Set these Spark configurations before running:

```python
spark.conf.set("catalog", "main")
spark.conf.set("schema", "insurance_analytics")
```

Or pass as pipeline configuration:
```json
{
  "catalog": "main",
  "schema": "insurance_analytics"
}
```

## Source Data Requirements

### PCDM Tables Required

**Group Dimension:**
- grouping, party, organization, household, professional_group, project, team

**Policy Dimension:**
- policy, agreement, product, line_of_business, line_of_business_group, insurance_class
- geographic_location, state, agreement_party_role, party, grouping
- policy_coverage_part

**Risk Dimension:**
- insurable_object, vehicle, automobile, truck, van
- structure, commercial_structure, residential_structure
- geographic_location, location_address, state
- policy_coverage_detail, policy_coverage_part

**Claim Dimension:**
- claim, occurrence, geographic_location, state, catastrophe

**Attorney Dimension:**
- attorney, provider, party_role, party, person, organization
- geographic_location, location_address, state

**Court Dimension:**
- court_jurisdiction, legal_jurisdiction

**Outcome Dimension:**
- litigation, arbitration, court_jurisdiction, legal_jurisdiction

**Premium Fact:**
- policy_amount, policy_coverage_detail, policy_coverage_part, policy
- agreement, agreement_party_role, party, grouping
- premium, tax, coverage

**Claims Fact:**
- claim_amount, claim, claim_coverage, policy_coverage_detail
- policy_coverage_part, policy, agreement, agreement_party_role
- party, grouping, claim_payment, claim_reserve, loss_payment
- expense_payment, claim_litigation

## Monitoring

### Data Quality Metrics

Monitor pipeline execution for:
- Records processed per table
- Records dropped due to expectation failures
- Pipeline execution time
- Data freshness

### Access Metrics

```python
# View expectation metrics
display(spark.sql("SELECT * FROM event_log(<pipeline-id>)"))

# View data quality metrics
display(spark.sql("""
  SELECT * FROM event_log(<pipeline-id>)
  WHERE event_type = 'flow_progress'
  AND details:flow_progress.metrics IS NOT NULL
"""))
```

## Optimization

### Delta Optimizations Enabled

All tables configured with:
```python
table_properties={
    "delta.enableChangeDataFeed": "true",
    "delta.autoOptimize.optimizeWrite": "true",
    "delta.autoOptimize.autoCompact": "true",
    "pipelines.autoOptimize.zOrderCols": "key_columns"
}
```

### Z-Ordering

Optimized for common query patterns:
- **dim_group**: `group_key`
- **dim_policy**: `policy_key, group_key`
- **dim_risk**: `risk_key, policy_key`
- **fact_premium_payments**: `policy_key, group_key`
- **fact_claims**: `claim_key, policy_key`

## Troubleshooting

### Common Issues

**Issue**: Pipeline fails with "Table not found"
- **Solution**: Verify PCDM tables exist in source catalog/schema

**Issue**: High record drop rate
- **Solution**: Review data quality expectations, check source data quality

**Issue**: Performance issues
- **Solution**: Adjust cluster size, enable auto-scaling, review Z-order columns

**Issue**: SCD Type 2 not updating
- **Solution**: Verify change detection logic, check effective dates

## Next Steps

After successful pipeline execution:

1. **Verify Data**: Query dimension and fact tables
2. **Check Quality**: Review expectation metrics
3. **Build Views**: Create semantic views on top of dimensional model
4. **Deploy Metrics**: Deploy Databricks Metric Views YAML
5. **Schedule**: Set up pipeline schedule for incremental loads

## Related Documentation

- `../ddl/*.sql` - Table DDL definitions
- `../STAR_SCHEMA_DOCUMENTATION.md` - Schema design
- `../../PCDM_to_Dimensional_Model_Mapping.xlsx` - Source-to-target mappings
- `../../SOURCE_TARGET_MAPPING_README.md` - Mapping documentation

## Support

For questions or issues:
- Review pipeline execution logs in Databricks UI
- Check data quality metrics
- Verify source data availability
- Review expectation failures

---

**Pipeline Version**: 2.0  
**SCD Type**: Type 2 for all dimensions  
**Data Quality**: Comprehensive expectations  
**Optimization**: Auto-optimize, Z-order, CDF enabled
