# Retail Insurance Star Schema - Semantic Model Views

A comprehensive dimensional data model for retail property & casualty insurance analytics, based on the Property Casualty Data Model (PCDM).

## Overview

This project implements a star schema designed for insurance analytics with two main business processes:
1. **Premium Payments** - Track and analyze premium revenue across policies, products, and coverages
2. **Claims Management** - Comprehensive claims analysis including legal proceedings, settlements, and outcomes

## Project Structure

```
semantic_model_views/
├── databricks.yml                    # Databricks Asset Bundle configuration
├── STAR_SCHEMA_DOCUMENTATION.md     # Detailed documentation
├── README.md                         # This file
├── src/                             # SQL scripts
│   ├── dim_attorney.sql             # Attorney dimension
│   ├── dim_claim.sql                # Claim dimension
│   ├── dim_court.sql                # Court jurisdiction dimension
│   ├── dim_date.sql                 # Date dimension (calendar)
│   ├── dim_group.sql                # Group/Organization dimension
│   ├── dim_outcome.sql              # Legal outcome dimension
│   ├── dim_policy.sql               # Policy dimension
│   ├── dim_risk.sql                 # Insurable object/risk dimension
│   ├── fact_claims.sql              # Claims fact table
│   ├── fact_premium_payments.sql    # Premium payments fact table
│   ├── sv_claims_summary.sql        # Claims semantic view
│   ├── sv_litigation_analytics.sql  # Litigation analytics view
│   ├── sv_policy_analytics.sql      # Policy analytics view
│   └── sv_premium_summary.sql       # Premium summary view
├── resources/                        # DAB job definitions
│   └── semantic_model_views_sql.job.yml
└── scratch/                          # Development notebooks
    └── exploration.ipynb
```

## Data Model

### Star Schema Components

#### Premium Payments Model
```
Dim_Date ─┐
          ├─→ Fact_Premium_Payments ←─┐
Dim_Group ┘                            ├─ Dim_Policy
                                       └─ Dim_Risk
```

**Dimensions:**
- **Group** - Policy holder groups (households, organizations)
- **Policy** - Policy details, products, lines of business
- **Risk** - Insurable objects (vehicles, structures, equipment)
- **Date** - Calendar dimension for time analysis

**Facts:**
- Premium amounts (net, direct, assumed, ceded)
- Tax, surcharge, and fee breakouts
- Earning period metrics
- Coverage limits and deductibles

#### Claims Model
```
Dim_Date ────┐
             ├─→ Fact_Claims ←─┬─ Dim_Claim
Dim_Group ───┘                 ├─ Dim_Policy
                               ├─ Dim_Risk
                               ├─ Dim_Attorney (nullable)
                               ├─ Dim_Court (nullable)
                               └─ Dim_Outcome (nullable)
```

**Additional Dimensions:**
- **Claim** - Claim details, occurrence, catastrophe information
- **Attorney** - Attorney and law firm details
- **Court** - Court jurisdiction information
- **Outcome** - Litigation and arbitration outcomes

**Facts:**
- Payments (loss and expense)
- Reserves (loss and expense)
- Recoveries (subrogation, salvage, reinsurance)
- Settlement offers and judgments
- Legal proceeding indicators

### Semantic Views

Four business-friendly views that denormalize the star schema for easy querying:

1. **sv_premium_summary** - Premium revenue analysis with all dimensions
2. **sv_claims_summary** - Comprehensive claims analysis
3. **sv_policy_analytics** - Policy-level aggregations with loss ratios
4. **sv_litigation_analytics** - Legal proceedings analysis

## Getting Started

### Prerequisites

- Databricks workspace access
- Databricks CLI installed
- Python 3.10+ virtual environment (optional but recommended)
- Property Casualty Data Model (PCDM) source tables

### Installation

1. **Clone the repository:**
   ```bash
   cd /path/to/your/workspace
   ```

2. **Activate virtual environment (if using):**
   ```bash
   source venv/bin/activate
   ```

3. **Configure Databricks CLI:**
   ```bash
   databricks configure
   ```

4. **Review configuration:**
   Edit `databricks.yml` to set your:
   - Workspace host
   - Warehouse ID
   - Catalog and schema names

### Deployment

#### Deploy to Development:
```bash
cd semantic_model_views
databricks bundle deploy --target dev
```

This will create all tables and views in your personal schema (e.g., `main.firstname_lastname`).

#### Deploy to Production:
```bash
databricks bundle deploy --target prod
```

This deploys to the shared production schema (e.g., `main.default`).

### Execution Order

The SQL files should be executed in the following order:

1. **Date dimension** (no dependencies)
   ```bash
   databricks bundle run dim_date
   ```

2. **Other dimensions** (can run in parallel)
   ```bash
   databricks bundle run dim_group
   databricks bundle run dim_policy
   databricks bundle run dim_risk
   databricks bundle run dim_claim
   databricks bundle run dim_attorney
   databricks bundle run dim_court
   databricks bundle run dim_outcome
   ```

3. **Fact tables**
   ```bash
   databricks bundle run fact_premium_payments
   databricks bundle run fact_claims
   ```

4. **Semantic views**
   ```bash
   databricks bundle run sv_premium_summary
   databricks bundle run sv_claims_summary
   databricks bundle run sv_policy_analytics
   databricks bundle run sv_litigation_analytics
   ```

## Usage Examples

### Premium Analysis

**Monthly earned premium by line of business:**
```sql
SELECT 
    earning_begin_year,
    earning_begin_month_name,
    line_of_business_name,
    SUM(net_premium_amount) as total_earned_premium,
    COUNT(DISTINCT policy_number) as policy_count
FROM main.default.sv_premium_summary
WHERE earning_begin_year = 2024
GROUP BY earning_begin_year, earning_begin_month_name, line_of_business_name
ORDER BY earning_begin_year, earning_begin_month, total_earned_premium DESC;
```

### Claims Analysis

**Claims paid by state and catastrophe indicator:**
```sql
SELECT 
    policy_state,
    is_catastrophe,
    COUNT(DISTINCT company_claim_number) as claim_count,
    SUM(loss_payment_amount) as total_loss_paid,
    AVG(days_claim_open) as avg_days_to_close
FROM main.default.sv_claims_summary
WHERE claim_open_year = 2024
GROUP BY policy_state, is_catastrophe
ORDER BY total_loss_paid DESC;
```

### Policy Performance

**Loss ratio analysis by product:**
```sql
SELECT 
    product_name,
    line_of_business_name,
    COUNT(*) as policy_count,
    SUM(total_net_premium) as total_premium,
    SUM(total_claims_paid) as total_paid,
    AVG(loss_ratio_pct) as avg_loss_ratio,
    SUM(claim_count) as total_claims
FROM main.default.sv_policy_analytics
WHERE is_active = 1
GROUP BY product_name, line_of_business_name
ORDER BY avg_loss_ratio DESC;
```

### Litigation Analysis

**Attorney performance analysis:**
```sql
SELECT 
    attorney_name,
    law_firm_name,
    COUNT(DISTINCT claim_key) as case_count,
    SUM(total_legal_payments) as total_paid,
    SUM(total_legal_recoveries) as total_recovered,
    AVG(recovery_ratio_pct) as avg_recovery_pct,
    AVG(litigation_duration_days) as avg_duration_days
FROM main.default.sv_litigation_analytics
WHERE outcome_date >= '2024-01-01'
GROUP BY attorney_name, law_firm_name
HAVING case_count >= 5
ORDER BY avg_recovery_pct DESC;
```

## Key Features

### Premium Payments
- ✅ Direct, assumed, and ceded premium tracking
- ✅ Tax, surcharge, and fee breakdowns
- ✅ Earning period analysis
- ✅ Coverage limit and deductible tracking
- ✅ Credit/debit transaction handling

### Claims Management
- ✅ Payment, reserve, and recovery tracking
- ✅ Loss vs. expense separation
- ✅ Litigation and arbitration tracking
- ✅ Attorney and court analytics
- ✅ Settlement and judgment tracking
- ✅ Catastrophe claim identification
- ✅ Claim lifecycle metrics

### Analytics Capabilities
- ✅ Loss ratio calculations
- ✅ Claim frequency and severity categorization
- ✅ Geographic risk analysis
- ✅ Product and LOB performance
- ✅ Legal outcome effectiveness
- ✅ Recovery ratio analysis

## Configuration

### Databricks Variables

The SQL scripts use Databricks bundle variables:

- `${catalog}`: Target catalog (e.g., "main")
- `${schema}`: Target schema (e.g., "default" for prod, user-specific for dev)

These are configured in `databricks.yml`:

```yaml
variables:
  catalog:
    description: The catalog to use
  schema:
    description: The schema to use

targets:
  dev:
    variables:
      catalog: main
      schema: ${workspace.current_user.short_name}
  
  prod:
    variables:
      catalog: main
      schema: default
```

## Data Quality

### Recommended Validations

1. **Foreign key integrity** - Verify all dimension keys exist
2. **Date logic** - Ensure claim dates >= policy effective dates
3. **Amount validations** - Check for unexpected negative amounts
4. **Duplicate prevention** - Validate unique business keys
5. **Legal data consistency** - Litigation claims should have attorney/court data

### Monitoring Queries

See `STAR_SCHEMA_DOCUMENTATION.md` for detailed data quality check queries.

## Performance Optimization

### Partitioning
- **Fact_Premium_Payments:** Partitioned by `earning_begin_date` (monthly)
- **Fact_Claims:** Partitioned by `event_date` (monthly)

### Materialization
Consider materializing semantic views as tables for large datasets:
```sql
CREATE TABLE main.default.mat_premium_summary AS
SELECT * FROM main.default.sv_premium_summary;
```

## Documentation

For detailed documentation including:
- Complete dimension and fact table specifications
- Business rules and calculations
- Data model diagrams
- Advanced query patterns
- Implementation notes

See **[STAR_SCHEMA_DOCUMENTATION.md](./STAR_SCHEMA_DOCUMENTATION.md)**

## Source Data

This star schema is designed to work with the **Property Casualty Data Model (PCDM)**, which should contain source tables such as:
- `policy`, `agreement`, `product`
- `claim`, `claim_amount`, `occurrence`
- `insurable_object`, `vehicle`, `structure`
- `party`, `organization`, `grouping`
- `litigation`, `arbitration`, `attorney`
- And many more...

## Contributing

When making changes:
1. Update dimension or fact table SQL
2. Test in development environment
3. Update semantic views if needed
4. Update documentation
5. Deploy to production

## License

This project is based on the Property Casualty Data Model (PCDM) standard.

## Contact

For questions about the data model or implementation, please refer to the PCDM documentation or contact your data architecture team.

---

**Built with Databricks Asset Bundles for easy deployment and management.**
