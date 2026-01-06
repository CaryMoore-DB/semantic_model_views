# Insurance Analytics Project v2.0 - SCD Type 2 with DLT

## 🎯 Major Updates

This version includes significant architectural improvements:

1. **Separate DDL and DML** - Table definitions separate from data loading
2. **Delta Live Tables (DLT)** - Declarative pipelines with data quality
3. **SCD Type 2** - All dimensions track historical changes
4. **Comprehensive Data Quality** - Expectations for validation
5. **Proper Hierarchy** - Group → Policy → Risk (1:Many relationships)

---

## 📁 Project Structure

```
semantic_model_views/
├── ddl/                                    # Table DDL (CREATE TABLE statements)
│   ├── dim_date_ddl.sql
│   ├── dim_group_ddl.sql                  # Customer groups (top of hierarchy)
│   ├── dim_policy_ddl.sql                 # Policies (middle of hierarchy)
│   ├── dim_risk_ddl.sql                   # Risks (bottom of hierarchy)
│   ├── dim_claim_ddl.sql
│   ├── dim_attorney_ddl.sql
│   ├── dim_court_ddl.sql
│   ├── dim_outcome_ddl.sql
│   ├── fact_premium_payments_ddl.sql
│   └── fact_claims_ddl.sql
│
├── pipelines/                              # Delta Live Tables pipelines
│   ├── README.md                          # Pipeline documentation
│   ├── DLT_MASTER_PIPELINE.py            # Master orchestration notebook
│   ├── dlt_dim_date.py
│   ├── dlt_dim_group.py                   # Group dimension with SCD Type 2
│   ├── dlt_dim_policy.py                  # Policy dimension with SCD Type 2
│   ├── dlt_dim_risk.py                    # Risk dimension with SCD Type 2
│   ├── dlt_dim_claim.py
│   ├── dlt_dim_attorney.py
│   ├── dlt_dim_court.py
│   ├── dlt_dim_outcome.py
│   ├── dlt_fact_premium_payments.py       # Premium fact with expectations
│   └── dlt_fact_claims.py                 # Claims fact with expectations
│
├── src/                                    # Legacy SQL views (reference)
│   ├── dim_*.sql                          # Original CTAS views
│   ├── fact_*.sql
│   └── sv_*.sql                           # Semantic views
│
├── databricks.yml                          # DAB configuration
├── insurance_premium_metrics.yaml          # Metric view definition
├── insurance_claims_metrics.yaml           # Metric view definition
└── STAR_SCHEMA_DOCUMENTATION.md           # Schema documentation
```

---

## 🏗️ Architecture

### Hierarchy Model

```
┌─────────────────┐
│   dim_group     │  Customer Groups (Households, Organizations, etc.)
└────────┬────────┘
         │ 1:Many
         ▼
┌─────────────────┐
│   dim_policy    │  Insurance Policies
└────────┬────────┘
         │ 1:Many
         ▼
┌─────────────────┐
│   dim_risk      │  Insurable Objects (Vehicles, Structures, etc.)
└─────────────────┘
```

### SCD Type 2 Implementation

All dimensions maintain history with:
- **effective_begin_date** - When this version started
- **effective_end_date** - When this version ended (NULL = current)
- **is_current** - Boolean flag for current record
- **Surrogate Keys** - Auto-generated identity columns

Example:
```sql
group_sk (surrogate key)    group_key (natural key)    group_name    effective_begin_date    effective_end_date    is_current
1                           G123                        Acme Corp     2023-01-01              2024-06-15            FALSE
2                           G123                        Acme Industries 2024-06-15            NULL                  TRUE
```

### Medallion Architecture

```
PCDM (Source)
    ↓
Bronze Layer (Source extraction)
    ↓
Silver Layer (Dimensional Model with SCD Type 2)
    ↓
Gold Layer (Analytics & Metrics)
```

---

## 🚀 Getting Started

### Step 1: Create Tables (DDL)

Execute DDL scripts to create table structures:

```sql
-- In Databricks SQL Editor or notebook
%sql
USE CATALOG main;
CREATE SCHEMA IF NOT EXISTS insurance_analytics;
USE SCHEMA insurance_analytics;

-- Execute each DDL file
%run ./ddl/dim_date_ddl.sql
%run ./ddl/dim_group_ddl.sql
%run ./ddl/dim_policy_ddl.sql
%run ./ddl/dim_risk_ddl.sql
%run ./ddl/dim_claim_ddl.sql
%run ./ddl/dim_attorney_ddl.sql
%run ./ddl/dim_court_ddl.sql
%run ./ddl/dim_outcome_ddl.sql
%run ./ddl/fact_premium_payments_ddl.sql
%run ./ddl/fact_claims_ddl.sql
```

### Step 2: Deploy DLT Pipeline

**Option A: Via Databricks UI**

1. Go to **Workflows** → **Delta Live Tables**
2. Click **Create Pipeline**
3. Configure:
   - **Name**: `insurance_analytics_pipeline`
   - **Notebook**: Select `pipelines/DLT_MASTER_PIPELINE.py`
   - **Target Catalog**: `main`
   - **Target Schema**: `insurance_analytics`
   - **Storage Location**: `/pipelines/insurance_analytics`
   - **Cluster Mode**: Enhanced Autoscaling
4. Click **Create** then **Start**

**Option B: Via Databricks CLI**

```bash
databricks pipelines create \
  --name "insurance_analytics_pipeline" \
  --notebook-path "/Workspace/path/to/pipelines/DLT_MASTER_PIPELINE.py" \
  --target "main.insurance_analytics" \
  --storage "/pipelines/insurance_analytics" \
  --continuous false \
  --configuration '{"catalog":"main","schema":"insurance_analytics"}'
```

### Step 3: Monitor Pipeline Execution

```python
# View pipeline progress
display(spark.sql("SELECT * FROM event_log('<pipeline-id>')"))

# View data quality metrics
display(spark.sql("""
  SELECT 
    timestamp,
    details:flow_progress.data_quality.expectations,
    details:flow_progress.metrics
  FROM event_log('<pipeline-id>')
  WHERE event_type = 'flow_progress'
"""))
```

### Step 4: Deploy Metric Views

```bash
# Via Databricks UI
# Data → Semantic Models → Create → Upload YAML

# Upload:
# - insurance_premium_metrics.yaml
# - insurance_claims_metrics.yaml
```

---

## 📊 Data Quality Expectations

Every pipeline includes comprehensive data quality checks:

### Example Expectations (Policy Dimension)

```python
@dlt.expect_all_or_drop({
    "valid_policy_key": "policy_key IS NOT NULL",
    "valid_group_key": "group_key IS NOT NULL",
    "valid_policy_number": "policy_number IS NOT NULL AND LENGTH(policy_number) > 0",
    "valid_effective_date": "effective_date IS NOT NULL",
    "valid_expiration_date": "expiration_date IS NOT NULL",
    "dates_in_order": "effective_date <= expiration_date",
    "policy_term_positive": "policy_term_days > 0"
})
```

### Validation Categories

| Category | Examples |
|----------|----------|
| **NOT NULL** | Key fields must exist |
| **Date Logic** | Start date ≤ End date |
| **Numeric Ranges** | Amounts ≥ 0 |
| **Referential Integrity** | Foreign keys valid |
| **Business Rules** | Domain-specific validations |

Records failing expectations are **dropped** and logged for review.

---

## 🔑 Key Features

### 1. Separate DDL from DML
- **DDL files** define table structures
- **DLT pipelines** populate tables
- Easy to version control and review
- No CREATE TABLE AS SELECT (CTAS)

### 2. SCD Type 2 for All Dimensions
- Track historical changes over time
- Point-in-time queries supported
- Surrogate keys for fact table joins
- Current flag for easy filtering

### 3. Comprehensive Data Quality
- Expectations defined in code
- Failed records logged and dropped
- Metrics tracked for monitoring
- Data quality reports available

### 4. Proper Hierarchy
- **Group → Policy → Risk** (1:Many at each level)
- Foreign keys properly defined
- Referential integrity maintained
- Easy to navigate relationships

### 5. Delta Optimizations
- Change Data Feed enabled
- Auto-optimize write enabled
- Auto-compaction enabled
- Z-ordering on key columns

---

## 📖 Dimensional Model

### Dimensions (8 tables)

| Dimension | SCD Type | Description | Key Hierarchy |
|-----------|----------|-------------|---------------|
| dim_date | Type 1 | Date attributes | date_key |
| **dim_group** | **Type 2** | **Customer groups** | **group_key** (top level) |
| **dim_policy** | **Type 2** | **Insurance policies** | **policy_key** → group_key |
| **dim_risk** | **Type 2** | **Insurable objects** | **risk_key** → policy_key |
| dim_claim | Type 2 | Claims | claim_key |
| dim_attorney | Type 2 | Attorneys | attorney_key |
| dim_court | Type 2 | Court jurisdictions | court_key |
| dim_outcome | Type 2 | Legal outcomes | outcome_key |

### Facts (2 tables)

| Fact | Grain | Measures |
|------|-------|----------|
| fact_premium_payments | Premium transaction | Premiums, taxes, fees, limits |
| fact_claims | Claim transaction | Payments, reserves, recoveries |

---

## 🔗 Hierarchy Relationships

### Group → Policy → Risk

```sql
-- Query across hierarchy
SELECT 
  g.group_name,
  g.organization_name,
  p.policy_number,
  p.line_of_business_name,
  r.vehicle_make_name,
  r.vehicle_model_name,
  f.premium_amount
FROM fact_premium_payments f
  JOIN dim_risk r ON f.risk_key = r.risk_key AND r.is_current = TRUE
  JOIN dim_policy p ON r.policy_key = p.policy_key AND p.is_current = TRUE
  JOIN dim_group g ON p.group_key = g.group_key AND g.is_current = TRUE
WHERE f.earning_begin_date >= '2024-01-01'
```

### SCD Type 2 Point-in-Time Query

```sql
-- Get policy as it was on a specific date
SELECT 
  p.policy_number,
  p.product_name,
  p.status_code,
  p.effective_begin_date,
  p.effective_end_date
FROM dim_policy p
WHERE p.policy_key = 'POL-12345'
  AND '2023-06-15' BETWEEN p.effective_begin_date 
  AND COALESCE(p.effective_end_date, CURRENT_TIMESTAMP())
```

---

## 📈 Example Queries

### Premium Analysis by Group and Product

```sql
SELECT 
  g.group_name,
  p.line_of_business_name,
  p.product_name,
  COUNT(DISTINCT f.policy_key) as policy_count,
  SUM(f.premium_amount) as total_premium,
  SUM(f.net_premium_amount) as net_premium
FROM fact_premium_payments f
  JOIN dim_policy p ON f.policy_key = p.policy_key AND p.is_current = TRUE
  JOIN dim_group g ON f.group_key = g.group_key AND g.is_current = TRUE
WHERE f.earning_begin_date >= '2024-01-01'
GROUP BY g.group_name, p.line_of_business_name, p.product_name
ORDER BY total_premium DESC
```

### Claims by Risk Type

```sql
SELECT 
  r.risk_category,
  r.vehicle_type,
  r.structure_type,
  COUNT(DISTINCT f.claim_key) as claim_count,
  SUM(f.loss_payment_amount) as total_loss_paid,
  AVG(f.days_claim_open) as avg_days_open
FROM fact_claims f
  JOIN dim_risk r ON f.risk_key = r.risk_key AND r.is_current = TRUE
  JOIN dim_claim c ON f.claim_key = c.claim_key AND c.is_current = TRUE
WHERE f.claim_open_date >= '2024-01-01'
GROUP BY r.risk_category, r.vehicle_type, r.structure_type
ORDER BY total_loss_paid DESC
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| `pipelines/README.md` | DLT pipeline details and configuration |
| `STAR_SCHEMA_DOCUMENTATION.md` | Detailed schema design |
| `PCDM_to_Dimensional_Model_Mapping.xlsx` | Source-to-target mappings (283 mappings) |
| `SOURCE_TARGET_MAPPING_README.md` | Mapping documentation |
| `METRIC_VIEWS_README.md` | Databricks Metric Views guide |

---

## ⚙️ Configuration

### Databricks Bundle (DAB)

```yaml
# databricks.yml
bundle:
  name: semantic_model_views

targets:
  dev:
    mode: development
    workspace:
      host: https://your-workspace.cloud.databricks.com
    variables:
      catalog: main
      schema: ${workspace.current_user.short_name}
```

### Pipeline Configuration

```python
# In DLT pipeline configuration
{
  "catalog": "main",
  "schema": "insurance_analytics"
}
```

---

## 🎯 Next Steps

1. **Deploy DDL** - Create all table structures
2. **Run DLT Pipeline** - Populate dimensional model
3. **Validate Data Quality** - Review expectation metrics
4. **Deploy Metric Views** - Enable business analytics
5. **Build Reports** - Create dashboards and reports
6. **Schedule Pipeline** - Set up incremental loads

---

## 🆕 What's New in v2.0

### ✅ Completed Updates

1. **Renamed Grouping → Group** throughout project
2. **Established Hierarchy** - Group → Policy → Risk with proper 1:Many relationships
3. **Separate DDL** - 10 DDL files (no CTAS)
4. **DLT Pipelines** - 10 pipelines with data quality expectations
5. **SCD Type 2** - All dimensions track historical changes
6. **Surrogate Keys** - Auto-generated identity columns
7. **Comprehensive Documentation** - Updated all docs for new structure

### 📊 By the Numbers

- **10** DDL files (separate table creation)
- **10** DLT pipelines (8 dims + 2 facts)
- **8** dimensions with SCD Type 2
- **75+** data quality expectations
- **283** source-to-target mappings
- **3** levels in hierarchy (Group → Policy → Risk)

---

## 🆘 Troubleshooting

### Pipeline Fails with "Table not found"
- **Cause**: DDL not executed or PCDM tables missing
- **Solution**: Run DDL scripts first, verify PCDM exists

### High Record Drop Rate
- **Cause**: Data quality issues in source
- **Solution**: Review expectation failures in pipeline logs

### SCD Not Working
- **Cause**: Simplified SCD logic in initial load
- **Solution**: Implement full MERGE logic for incremental updates

### Performance Issues
- **Cause**: Large data volumes, missing optimizations
- **Solution**: Increase cluster size, verify Z-ordering

---

## 📞 Support

For questions or issues:
1. Review pipeline execution logs
2. Check data quality metrics
3. Consult documentation
4. Review source-to-target mappings

---

**Version**: 2.0  
**Last Updated**: December 2025  
**Architecture**: Medallion (Bronze → Silver → Gold)  
**SCD**: Type 2 for all dimensions  
**Data Quality**: Comprehensive expectations  
**Hierarchy**: Group → Policy → Risk (1:Many)
