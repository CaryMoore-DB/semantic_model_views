# Databricks Semantic Metric Views for Insurance Analytics

## Overview

This folder contains Databricks semantic metric view definitions in YAML format for comprehensive insurance analytics. These metric views provide a business-friendly interface to the insurance star schema with pre-defined dimensions, measures, and industry-standard calculations.

## Files

### 1. insurance_premium_metrics.yaml
Metric view for **Premium Analytics** based on `fact_premium_payments`

**Key Features:**
- 40+ dimensions covering policy, customer, risk, coverage, and temporal aspects
- 30+ measures including core premium metrics and insurance industry KPIs
- Pre-calculated ratios and rates
- Risk-weighted premium calculations
- Exposure-based metrics

**Core Metrics:**
- Earned Premium
- Written Premium
- Net Retained Premium
- Risk-Weighted Premium
- Premium per Exposure Unit
- Retention Ratio
- Tax Rate
- Composite Rate

### 2. insurance_claims_metrics.yaml
Metric view for **Claims Analytics** based on `fact_claims`

**Key Features:**
- 50+ dimensions including claim, policy, legal, and outcome attributes
- 45+ measures covering payments, reserves, recoveries, and industry ratios
- Legal proceeding analytics (litigation, attorney, court)
- Catastrophe loss tracking
- Loss development metrics

**Core Metrics:**
- Loss Ratio
- Expense Ratio
- Combined Ratio
- Incurred Loss Ratio
- Claim Frequency & Severity
- Pure Premium (Loss Cost)
- Closure Rate
- Litigation Rate
- Recovery Ratio
- Risk-Weighted Losses

## Deployment

### Option 1: Databricks UI

1. Navigate to your Databricks workspace
2. Go to **Data** → **Semantic Models** (or **Delta Sharing** → **Semantic Models**)
3. Click **Create Semantic Model**
4. Upload the YAML file
5. Configure catalog and schema variables
6. Save and publish

### Option 2: Databricks CLI

```bash
# Premium metrics
databricks semantic-models create \
  --file insurance_premium_metrics.yaml \
  --catalog main \
  --schema your_schema

# Claims metrics
databricks semantic-models create \
  --file insurance_claims_metrics.yaml \
  --catalog main \
  --schema your_schema
```

### Option 3: Databricks Asset Bundle

Add to your `databricks.yml`:

```yaml
resources:
  semantic_models:
    insurance_premium_metrics:
      file_path: insurance_premium_metrics.yaml
      catalog: ${var.catalog}
      schema: ${var.schema}
    
    insurance_claims_metrics:
      file_path: insurance_claims_metrics.yaml
      catalog: ${var.catalog}
      schema: ${var.schema}
```

Then deploy:
```bash
databricks bundle deploy --target dev
```

## Usage Examples

### Premium Analytics Queries

#### 1. Premium by Product Line
```sql
SELECT 
    line_of_business,
    earning_begin_year,
    SUM(earned_premium) as total_earned_premium,
    SUM(risk_weighted_premium) as risk_adjusted_premium,
    COUNT(DISTINCT policy_count) as policies
FROM semantic_model.insurance_premium_metrics
WHERE earning_begin_year >= 2023
GROUP BY line_of_business, earning_begin_year
ORDER BY total_earned_premium DESC;
```

#### 2. Geographic Premium Concentration
```sql
SELECT 
    policy_state,
    SUM(net_premium) as state_premium,
    SUM(geographic_concentration_premium) as concentration_amount,
    AVG(average_limit_amount) as avg_coverage_limit,
    SUM(exposure_units) as policy_years
FROM semantic_model.insurance_premium_metrics
WHERE policy_is_active = 1
GROUP BY policy_state
ORDER BY state_premium DESC
LIMIT 10;
```

#### 3. Retention and Reinsurance Analysis
```sql
SELECT 
    product_name,
    SUM(direct_premium) as gross_premium,
    SUM(ceded_premium) as ceded_amount,
    SUM(net_retained_premium) as net_premium,
    AVG(retention_ratio) as avg_retention_pct
FROM semantic_model.insurance_premium_metrics
GROUP BY product_name
HAVING SUM(direct_premium) > 1000000
ORDER BY gross_premium DESC;
```

#### 4. Premium Rate Analysis
```sql
SELECT 
    line_of_business,
    vehicle_type,
    AVG(premium_per_exposure_unit) as avg_rate_per_year,
    AVG(premium_per_thousand_limit) as rate_per_1000,
    AVG(composite_rate) as annual_composite_rate
FROM semantic_model.insurance_premium_metrics
WHERE risk_category = 'Vehicle'
GROUP BY line_of_business, vehicle_type
ORDER BY avg_rate_per_year DESC;
```

### Claims Analytics Queries

#### 1. Loss Ratio by Product
```sql
SELECT 
    product_name,
    claim_open_year,
    SUM(total_incurred) as incurred_losses,
    SUM(loss_paid) as paid_losses,
    AVG(loss_ratio) as loss_ratio_pct,
    AVG(combined_ratio) as combined_ratio_pct,
    COUNT(DISTINCT claim_count) as num_claims
FROM semantic_model.insurance_claims_metrics
WHERE claim_open_year >= 2022
GROUP BY product_name, claim_open_year
ORDER BY combined_ratio_pct DESC;
```

#### 2. Frequency and Severity Analysis
```sql
SELECT 
    line_of_business,
    claim_open_year,
    SUM(claim_frequency) as frequency_per_exposure,
    AVG(claim_severity) as avg_severity,
    SUM(pure_premium) as loss_cost_per_exposure,
    COUNT(DISTINCT claim_count) as total_claims
FROM semantic_model.insurance_claims_metrics
GROUP BY line_of_business, claim_open_year
ORDER BY claim_open_year, line_of_business;
```

#### 3. Litigation Impact Analysis
```sql
SELECT 
    has_litigation,
    COUNT(DISTINCT litigation_claim_count) as claim_count,
    AVG(average_days_to_close) as avg_days_to_settle,
    AVG(average_incurred_per_claim) as avg_severity,
    SUM(total_expense_incurred) as total_legal_expenses,
    AVG(legal_expense_ratio) as legal_expense_pct
FROM semantic_model.insurance_claims_metrics
WHERE claim_status IN ('CLOSED', 'OPEN')
GROUP BY has_litigation
ORDER BY has_litigation;
```

#### 4. Attorney Performance
```sql
SELECT 
    attorney_name,
    law_firm_name,
    attorney_state,
    COUNT(DISTINCT claim_count) as cases_handled,
    AVG(average_incurred_per_claim) as avg_settlement,
    AVG(average_days_to_close) as avg_days_to_close,
    SUM(total_recoveries) as total_recovered,
    AVG(recovery_ratio) as recovery_rate
FROM semantic_model.insurance_claims_metrics
WHERE has_litigation = 1
GROUP BY attorney_name, law_firm_name, attorney_state
HAVING COUNT(DISTINCT claim_count) >= 5
ORDER BY recovery_rate DESC;
```

#### 5. Catastrophe Loss Analysis
```sql
SELECT 
    catastrophe_name,
    catastrophe_type,
    occurrence_state,
    COUNT(DISTINCT catastrophe_claim_count) as cat_claims,
    SUM(total_incurred) as total_cat_losses,
    AVG(average_incurred_per_claim) as avg_cat_severity,
    SUM(ceded_claims) as reinsurance_recovery
FROM semantic_model.insurance_claims_metrics
WHERE is_catastrophe = 1
GROUP BY catastrophe_name, catastrophe_type, occurrence_state
ORDER BY total_cat_losses DESC;
```

#### 6. Reserve Development
```sql
SELECT 
    claim_open_year,
    transaction_year,
    SUM(loss_paid) as cumulative_paid,
    SUM(loss_reserved) as case_reserves,
    SUM(total_loss_incurred) as total_incurred,
    AVG(reserve_to_paid_ratio) as reserve_to_paid,
    AVG(closure_rate) as pct_closed
FROM semantic_model.insurance_claims_metrics
WHERE claim_open_year >= 2020
GROUP BY claim_open_year, transaction_year
ORDER BY claim_open_year, transaction_year;
```

#### 7. Claim Efficiency Metrics
```sql
SELECT 
    claim_status,
    line_of_business,
    COUNT(DISTINCT claim_count) as num_claims,
    AVG(average_days_to_close) as avg_settlement_days,
    AVG(closure_rate) as closure_pct,
    AVG(reopen_rate) as reopen_pct,
    COUNT(DISTINCT reopened_claim_count) as reopened_claims
FROM semantic_model.insurance_claims_metrics
GROUP BY claim_status, line_of_business
ORDER BY line_of_business, claim_status;
```

### Combined Premium and Claims Analysis

```sql
-- Loss Ratio Comparison
WITH premium_data AS (
    SELECT 
        policy_key,
        line_of_business,
        earning_begin_year as year,
        SUM(earned_premium) as premium
    FROM semantic_model.insurance_premium_metrics
    GROUP BY policy_key, line_of_business, earning_begin_year
),
claims_data AS (
    SELECT 
        policy_key,
        line_of_business,
        claim_open_year as year,
        SUM(total_loss_incurred) as incurred
    FROM semantic_model.insurance_claims_metrics
    GROUP BY policy_key, line_of_business, claim_open_year
)
SELECT 
    p.line_of_business,
    p.year,
    SUM(p.premium) as total_premium,
    SUM(c.incurred) as total_incurred,
    (SUM(c.incurred) / NULLIF(SUM(p.premium), 0)) * 100 as loss_ratio_pct
FROM premium_data p
LEFT JOIN claims_data c 
    ON p.policy_key = c.policy_key 
    AND p.year = c.year
GROUP BY p.line_of_business, p.year
ORDER BY p.year DESC, loss_ratio_pct DESC;
```

## Key Insurance Metrics Included

### Premium Metrics
- **Earned Premium**: Premium recognized as revenue during the period
- **Written Premium**: Premium booked on new and renewed policies
- **Risk-Weighted Premium**: Premium adjusted for coverage limits
- **Exposure Units**: Policy years of exposure
- **Retention Ratio**: Premium retained after reinsurance
- **Premium per Exposure**: Rate per policy year
- **Composite Rate**: Annualized premium rate

### Claims Metrics
- **Loss Ratio**: Losses divided by earned premium (target: 60-70%)
- **Expense Ratio**: Claim expenses divided by premium (target: 10-20%)
- **Combined Ratio**: Sum of loss and expense ratios (target: <100%)
- **Claim Frequency**: Claims per exposure unit
- **Claim Severity**: Average cost per claim
- **Pure Premium**: Expected loss cost per exposure
- **Closure Rate**: Percentage of claims closed
- **Litigation Rate**: Percentage of claims in litigation
- **Recovery Ratio**: Recoveries as percentage of payments

### Advanced Metrics
- **Risk-Weighted Losses**: Losses adjusted for policy limits
- **Reserve to Paid Ratio**: Indicator of claim maturity
- **Reopen Rate**: Quality metric for initial reserves
- **Catastrophe Loss Percentage**: Volatility measure
- **Legal Expense Ratio**: Cost of litigation
- **Ceded Loss Ratio**: Reinsurance effectiveness
- **IBNR Indicator**: Late reporting pattern metric

## Best Practices

### 1. Use Appropriate Time Dimensions
- **Premium Analysis**: Use `earning_begin_year` for earned premium
- **Claims Analysis**: Use `claim_open_year` (accident year) for loss development
- **Cash Flow**: Use `transaction_year` for actual payment timing

### 2. Filter for Data Quality
```sql
WHERE policy_is_active = 1  -- For in-force analysis
WHERE claim_status = 'CLOSED'  -- For closed claim severity
WHERE earning_period_days > 0  -- Exclude zero-day periods
```

### 3. Calculate Ratios at Proper Aggregation Level
```sql
-- Correct: Aggregate first, then calculate ratio
SUM(losses) / NULLIF(SUM(premium), 0)

-- Incorrect: Average of individual ratios
AVG(loss_ratio)
```

### 4. Handle Division by Zero
Always use `NULLIF()` when dividing:
```sql
SUM(amount) / NULLIF(SUM(base), 0)
```

### 5. Use Risk-Weighted Metrics for Exposure Analysis
```sql
SELECT 
    SUM(risk_weighted_premium) as exposure_adjusted_premium,
    SUM(risk_weighted_losses) as exposure_adjusted_losses
FROM semantic_model
WHERE avg_limit > 0;
```

## Metric Definitions Reference

### Loss Ratio
```
Loss Ratio = (Incurred Losses / Earned Premium) × 100
```
Target: 60-70% for most lines

### Combined Ratio
```
Combined Ratio = Loss Ratio + Expense Ratio
```
Target: < 100% for underwriting profit

### Pure Premium (Loss Cost)
```
Pure Premium = Total Losses / Exposure Units
```
Fundamental pricing metric

### Claim Frequency
```
Frequency = Claim Count / Exposure Units
```

### Claim Severity
```
Severity = Total Paid / Closed Claim Count
```

### Risk-Weighted Premium
```
Risk-Weighted Premium = Premium × (Coverage Limit / Base Limit)
```
Adjusts for different policy sizes

## Performance Optimization

### 1. Use Partition Filters
```sql
WHERE earning_begin_year >= 2023  -- Partition pruning
```

### 2. Pre-aggregate When Possible
```sql
CREATE TABLE aggregated_metrics AS
SELECT 
    line_of_business,
    claim_open_year,
    SUM(total_incurred) as incurred,
    COUNT(DISTINCT claim_key) as claim_count
FROM semantic_model.insurance_claims_metrics
GROUP BY line_of_business, claim_open_year;
```

### 3. Materialize Common Queries
Create materialized views for frequently-used aggregations

## Troubleshooting

### Issue: Null Values in Ratios
**Solution**: Use NULLIF() and COALESCE()
```sql
COALESCE(SUM(amount) / NULLIF(SUM(base), 0), 0)
```

### Issue: Unexpected Loss Ratios
**Check**:
- Matching time periods (accident year vs calendar year)
- Policy effective dates align with claim dates
- Premium is earned (not written)
- Claims are in correct status

### Issue: Performance Slow
**Optimize**:
- Add date range filters
- Use appropriate indexes
- Check query plan for full table scans
- Consider pre-aggregation

## Additional Resources

- **Star Schema Documentation**: `../STAR_SCHEMA_DOCUMENTATION.md`
- **Semantic Views**: `../src/sv_*.sql`
- **Databricks Docs**: [Semantic Models](https://docs.databricks.com/semantic-models/)

---

**Version**: 1.0  
**Last Updated**: December 2025  
**Platform**: Databricks
