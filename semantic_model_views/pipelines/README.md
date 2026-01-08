# Delta Live Tables Pipelines - Insurance Analytics

## Overview

This directory contains **individual SQL Delta Live Tables (DLT)** pipelines for building the insurance analytics dimensional model with **SCD Type 2** support and comprehensive **data quality expectations**.

Each dimension and fact table has its own SQL file, allowing for:
- ✅ **Modular development** - Work on individual tables independently
- ✅ **Easier debugging** - Isolate issues to specific tables
- ✅ **Flexible deployment** - Deploy only the tables you need
- ✅ **Clear organization** - One file per table

## Architecture

### Dimensional Hierarchy

```
dim_group (1:Many)
  ↓ (FK: group_id)
dim_policy (1:Many)
  ↓ (FK: policy_id)
dim_risk (policy_coverage_detail + insurable_objects)
```

### Group Resolution

Group membership is resolved through the `party_relationship` table:
- Persons (insureds) → `party_relationship` (MEMBER_OF) → Groups
- If no group membership, defaults to group_id = 0 ("No Group")

## Pipeline Files

### Dimension Pipelines (8)

| File | Table | SCD Type | Description |
|------|-------|----------|-------------|
| `dlt_dim_date.sql` | dim_date | Static | Date dimension 2020-2030 |
| `dlt_dim_group.sql` | dim_group | Type 1 | Customer groups (upsert only) |
| `dlt_dim_policy.sql` | dim_policy | Type 2 | Policies with SCD history |
| `dlt_dim_risk.sql` | dim_risk | Type 2 | Insurable objects (vehicles, structures) |
| `dlt_dim_claim.sql` | dim_claim | Type 2 | Claims with SCD history |
| `dlt_dim_attorney.sql` | dim_attorney | Static | Attorney dimension stub |
| `dlt_dim_court.sql` | dim_court | Static | Court dimension stub |
| `dlt_dim_outcome.sql` | dim_outcome | Static | Outcome dimension stub |

### Fact Pipelines (2)

| File | Table | Description |
|------|-------|-------------|
| `dlt_fact_premium_payments.sql` | fact_premium_payments | Premium transactions with group resolution |
| `dlt_fact_claims.sql` | fact_claims | Claim transactions with group resolution |

## SCD Type 2 Implementation

DLT's native `APPLY CHANGES INTO ... STORED AS SCD TYPE 2` is used for dimensions with effective dates.

### SCD Type 2 Syntax

```sql
CREATE OR REFRESH STREAMING TABLE dim_policy_source (...);

CREATE OR REFRESH STREAMING TABLE dim_policy;

APPLY CHANGES INTO dim_policy
FROM STREAM(LIVE.dim_policy_source)
KEYS (policy_id)
SEQUENCE BY effective_date
STORED AS SCD TYPE 2;
```

DLT automatically manages:
- `__START_AT` - When this version became effective
- `__END_AT` - When this version expired (NULL = current)
- `__CURRENT` - TRUE for current record

### SCD Type 1 (Upsert Only)

For dimensions without effective dates (e.g., `dim_group`):

```sql
APPLY CHANGES INTO dim_group
FROM STREAM(LIVE.dim_group_source)
KEYS (group_id);
-- No SEQUENCE BY or STORED AS SCD TYPE 2 = upsert only
```

## Data Quality Expectations

All pipelines include data quality expectations using DLT's EXPECT clause:

```sql
CREATE OR REFRESH STREAMING TABLE dim_policy_source (
  CONSTRAINT valid_policy_id EXPECT (policy_id IS NOT NULL),
  CONSTRAINT valid_policy_number EXPECT (policy_number IS NOT NULL),
  CONSTRAINT valid_effective_date EXPECT (effective_date IS NOT NULL),
  CONSTRAINT valid_group_id EXPECT (group_id IS NOT NULL)
)
```

### Validation Types

1. **NOT NULL Validation**: Key fields must be present
2. **Numeric Validation**: Amounts must be non-negative
3. **Date Validation**: Dates must be populated and logical
4. **Referential Integrity**: Foreign keys must exist

## Pipeline Execution

### Option 1: Deploy Individual Pipeline via Databricks UI

1. Navigate to **Workflows** → **Delta Live Tables**
2. Click **Create Pipeline**
3. Configure:
   - **Name**: `insurance_dim_policy`
   - **Notebook**: Select `dlt_dim_policy.sql`
   - **Target**: `cmoore_user.insurance_analytics`
   - **Cluster**: Enhanced Autoscaling
4. Click **Create** and **Start**

### Option 2: Deploy All Pipelines

Create a master pipeline that references all individual SQL files:

1. Create a new pipeline with configuration:
```json
{
  "name": "insurance_analytics_full_pipeline",
  "target": "cmoore_user.insurance_analytics",
  "catalog": "cmoore_user",
  "libraries": [
    {"notebook": {"path": "pipelines/dlt_dim_date.sql"}},
    {"notebook": {"path": "pipelines/dlt_dim_group.sql"}},
    {"notebook": {"path": "pipelines/dlt_dim_policy.sql"}},
    {"notebook": {"path": "pipelines/dlt_dim_risk.sql"}},
    {"notebook": {"path": "pipelines/dlt_dim_claim.sql"}},
    {"notebook": {"path": "pipelines/dlt_dim_attorney.sql"}},
    {"notebook": {"path": "pipelines/dlt_dim_court.sql"}},
    {"notebook": {"path": "pipelines/dlt_dim_outcome.sql"}},
    {"notebook": {"path": "pipelines/dlt_fact_premium_payments.sql"}},
    {"notebook": {"path": "pipelines/dlt_fact_claims.sql"}}
  ]
}
```

2. Start the pipeline

### Option 3: Test Individual Pipeline in Notebook

You can test a single pipeline by running the SQL file directly in a Databricks notebook.

## Source Data Requirements

### PCDM Tables Required

**dim_group:**
- `grouping`, `party`

**dim_policy:**
- `policy`, `agreement`, `product`, `line_of_business`, `insurance_class`
- `company`, `agreement_party_role`, `party_relationship`

**dim_risk:**
- `policy_coverage_detail`, `coverage`, `insurable_object`
- `vehicle`, `structure`, `commercial_structure`, `residential_structure`
- `geographic_location`

**dim_claim:**
- `claim`, `occurrence`, `catastrophe`

**fact_premium_payments:**
- `policy_coverage_detail`, `policy`, `agreement`, `agreement_party_role`
- `party_relationship`, `coverage`, `policy_limit`, `policy_deductible`

**fact_claims:**
- `claim`, `claim_coverage`, `policy_coverage_detail`, `policy`
- `agreement`, `agreement_party_role`, `party_relationship`
- `occurrence`, `catastrophe`, `policy_limit`

## Key Features

### 1. Modular SQL Files
Each table has its own SQL file for easier maintenance and debugging.

### 2. Native DLT SCD Type 2
Uses `APPLY CHANGES INTO ... STORED AS SCD TYPE 2` for automatic history tracking.

### 3. Party Relationship Resolution
Groups are resolved through the `party_relationship` table using the `MEMBER_OF` relationship type.

### 4. Streaming Tables
Source tables use `CREATE OR REFRESH STREAMING TABLE` for incremental processing.

### 5. Materialized Views
Static dimensions and fact tables use `CREATE OR REFRESH MATERIALIZED VIEW`.

### 6. Data Quality
All tables include CONSTRAINT EXPECT clauses for data validation.

## Troubleshooting

### Common Issues

**Issue**: Pipeline fails with "Table not found"
- **Solution**: Verify PCDM tables exist in `cmoore_user.pcdm_test` catalog/schema

**Issue**: "LIVE.table_name" reference error
- **Solution**: In APPLY CHANGES INTO, use table name without LIVE. prefix:
  - ✅ `APPLY CHANGES INTO dim_policy`
  - ❌ `APPLY CHANGES INTO LIVE.dim_policy`

**Issue**: High record drop rate
- **Solution**: Review data quality expectations, check source data quality

**Issue**: SCD Type 2 not creating history
- **Solution**: Verify `SEQUENCE BY` uses correct effective date column

**Issue**: Group_id is NULL
- **Solution**: Verify `party_relationship` table is populated and relationship_type_code = 'MEMBER_OF'

## Next Steps

After successful pipeline execution:

1. **Verify Data**: Query dimension and fact tables
```sql
SELECT * FROM cmoore_user.insurance_analytics.dim_policy LIMIT 10;
SELECT * FROM cmoore_user.insurance_analytics.fact_premium_payments LIMIT 10;
```

2. **Check SCD Type 2**:
```sql
SELECT 
  policy_id,
  policy_number,
  effective_date,
  __START_AT,
  __END_AT,
  __CURRENT
FROM cmoore_user.insurance_analytics.dim_policy
WHERE policy_id = 1
ORDER BY __START_AT;
```

3. **Verify Group Resolution**:
```sql
SELECT 
  p.policy_id,
  p.policy_number,
  p.group_id,
  g.group_name
FROM cmoore_user.insurance_analytics.dim_policy p
JOIN cmoore_user.insurance_analytics.dim_group g ON p.group_id = g.group_id
LIMIT 10;
```

4. **Build Views**: Create semantic views on top of dimensional model
5. **Deploy Metrics**: Deploy Databricks Metric Views YAML
6. **Schedule**: Set up pipeline schedule for incremental loads

## Related Documentation

- `../ddl/*.sql` - Table DDL definitions
- `../STAR_SCHEMA_DOCUMENTATION.md` - Schema design
- `../../PCDM_to_Dimensional_Model_Mapping_v2.xlsx` - Source-to-target mappings
- `../../SOURCE_TARGET_MAPPING_README.md` - Mapping documentation

---

**Pipeline Version**: 3.0  
**Format**: Individual SQL files  
**SCD Type**: Type 2 using APPLY CHANGES INTO  
**Group Resolution**: Via party_relationship table  
**Data Quality**: Comprehensive EXPECT constraints
