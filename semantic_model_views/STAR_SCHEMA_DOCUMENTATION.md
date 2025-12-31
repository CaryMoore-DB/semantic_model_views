# Retail Insurance Star Schema - Property Casualty Data Model

## Overview
This star schema is designed for retail insurance analytics based on the Property Casualty Data Model (PCDM). It consists of two main fact tables (Premium Payments and Claims) with shared and specialized dimensions.

## Architecture

### Star Schema Structure

```
┌─────────────────────────────────────────────────────────────────────┐
│                      PREMIUM PAYMENTS MODEL                          │
└─────────────────────────────────────────────────────────────────────┘

        ┌──────────────┐
        │  Dim_Date    │
        │  (Calendar)  │
        └──────┬───────┘
               │
    ┌──────────┼──────────┐
    │          │          │
┌───▼────┐ ┌──▼──────┐ ┌─▼─────────┐
│Dim_Group│ │Dim_Policy│ │ Dim_Risk │
└───┬────┘ └──┬───────┘ └─┬─────────┘
    │         │            │
    └────┬────┴────┬───────┘
         │         │
    ┌────▼─────────▼─────┐
    │ Fact_Premium_      │
    │    Payments        │
    └────────────────────┘


┌─────────────────────────────────────────────────────────────────────┐
│                         CLAIMS MODEL                                 │
└─────────────────────────────────────────────────────────────────────┘

                                          ┌──────────────┐
                                          │  Dim_Date    │
                                          │  (Calendar)  │
                                          └──────┬───────┘
                                                 │
    ┌────────────┬────────────┬─────────────────┼──────────┬──────────┐
    │            │            │                 │          │          │
┌───▼─────┐ ┌───▼──────┐ ┌───▼───────┐ ┌──────▼──┐ ┌────▼─────┐ ┌──▼────────┐
│Dim_Group│ │Dim_Policy│ │ Dim_Risk  │ │Dim_Claim│ │Dim_Attorney│ │Dim_Court │
└───┬─────┘ └──┬───────┘ └─┬─────────┘ └────┬────┘ └────┬───────┘ └──┬────────┘
    │          │            │                │           │             │
    └─────┬────┴────┬───────┴────────────────┴───────────┴─────────────┤
          │         │                                                   │
     ┌────▼─────────▼─────┐                                      ┌──────▼─────┐
     │   Fact_Claims      │◄─────────────────────────────────────│Dim_Outcome │
     └────────────────────┘                                      └────────────┘
```

## Dimension Tables

### 1. Dim_Group
Contains grouping information (households, organizations, professional groups) for policy holders.

**Key Attributes:**
- `group_key` (PK): Surrogate key
- `grouping_name`: Name of the group
- `group_type`: Household, Professional Group, Project, Team, etc.
- `organization_name`: If group is an organization
- `organization_type_code`: Type of organization
- `industry_type_code`: Industry classification

**Business Use:** Segment policies by customer type, analyze household vs. commercial policies, industry analysis

### 2. Dim_Policy
Contains policy-level information including product, line of business, and coverage details.

**Key Attributes:**
- `policy_key` (PK): Surrogate key
- `policy_number`: Business key
- `effective_date`, `expiration_date`: Policy term dates
- `product_name`: Insurance product
- `line_of_business_name`: LOB classification
- `insurance_class_name`: Insurance class
- `state_code`, `state_name`: Policy jurisdiction
- `is_active`: Current policy status
- `policy_term_days`: Duration of policy

**Business Use:** Analyze by product line, geographic distribution, policy retention, active vs. expired policies

### 3. Dim_Risk
Contains information about insurable objects (what is being insured).

**Key Attributes:**
- `risk_key` (PK): Surrogate key
- `risk_category`: Vehicle, Structure, Farm Equipment, Workers Comp, Transportation
- `vehicle_type`: Automobile, Truck, Van, Motorcycle, RV, Boat, etc.
- `vin`, `vehicle_make_name`, `vehicle_model_name`, `vehicle_model_year`: Vehicle details
- `structure_type`: Commercial, Residential, Combination
- `state_code`, `state_name`: Risk location
- `line_1_address`, `municipality_name`, `postal_code`: Risk address

**Business Use:** Risk concentration analysis, vehicle type analysis, geographic risk exposure, structure type analysis

### 4. Dim_Claim
Contains claim-level information including occurrence and catastrophe details.

**Key Attributes:**
- `claim_key` (PK): Surrogate key
- `company_claim_number`: Business key
- `claim_open_date`, `claim_close_date`, `claim_reported_date`: Key dates
- `claim_status_code`: Current status
- `is_closed`, `is_reopened`, `is_open`: Status flags
- `days_open`: Claim duration
- `is_catastrophe`: Catastrophe indicator
- `catastrophe_name`: Catastrophe event name
- `occurrence_location_name`, `occurrence_state_code`: Where loss occurred
- `has_litigation`, `has_arbitration`: Legal proceeding indicators

**Business Use:** Claims frequency analysis, claim status tracking, catastrophe impact, claim duration analysis, litigation tracking

### 5. Dim_Attorney
Contains attorney information for claims with legal representation.

**Key Attributes:**
- `attorney_key` (PK): Surrogate key
- `attorney_name`: Full name
- `first_name`, `last_name`: Name components
- `law_firm_name`: Attorney's firm
- `city`, `state_code`, `state_name`: Attorney location
- `is_active`: Active status

**Business Use:** Attorney performance analysis, legal expense tracking by attorney, geographic attorney distribution

### 6. Dim_Court
Contains court and legal jurisdiction information.

**Key Attributes:**
- `court_key` (PK): Surrogate key
- `legal_jurisdiction_name`: Court name/jurisdiction
- `court_level`: Federal, State, County, Municipal
- `court_location`: Geographic location
- `rules_preference_description`: Jurisdiction rules

**Business Use:** Analyze claims by court jurisdiction, understand legal venue impacts, jurisdiction-specific outcomes

### 7. Dim_Outcome
Contains litigation and arbitration outcome information.

**Key Attributes:**
- `outcome_key` (PK): Surrogate key (prefixed L- for litigation, A- for arbitration)
- `outcome_type`: Litigation or Arbitration
- `litigation_description`: Outcome description
- `outcome_status_code`: Status
- `outcome_result`: Result of proceedings
- `judgment_amount`: Court judgment amount
- `settlement_amount`: Settlement amount
- `outcome_date`: Date of resolution

**Business Use:** Win/loss analysis, settlement vs. judgment comparison, outcome type effectiveness

### 8. Dim_Date
Standard date dimension for time-based analysis.

**Key Attributes:**
- `date_key` (PK): Date value
- `year`, `quarter`, `month`, `day_of_month`: Date components
- `month_name`, `day_name`: Descriptive names
- `is_weekend`, `is_quarter_start`, `is_quarter_end`: Date flags
- `fiscal_quarter`, `fiscal_year_month`: Fiscal period identifiers

**Business Use:** Time series analysis, trend analysis, seasonal patterns, fiscal period reporting

## Fact Tables

### 1. Fact_Premium_Payments
Transactional fact table for premium payments with full additivity.

**Key Foreign Keys:**
- `policy_key` → Dim_Policy
- `risk_key` → Dim_Risk
- `group_key` → Dim_Group
- `begin_date_key`, `end_date_key` → Dim_Date

**Key Measures:**
- `premium_amount`: Total premium transaction amount
- `premium_only_amount`: Pure premium (excluding taxes/fees)
- `tax_amount`: Tax portion
- `surcharge_amount`: Surcharge portion
- `fee_amount`: Fee portion
- `net_premium_amount`: Net amount (considering credits/debits)
- `direct_premium_amount`: Direct business
- `assumed_premium_amount`: Assumed reinsurance
- `ceded_premium_amount`: Ceded reinsurance

**Key Dimensions:**
- `earning_begin_date`, `earning_end_date`: Premium earning period
- `earning_period_days`: Duration
- `is_premium`, `is_tax`, `is_surcharge`, `is_fee`: Type flags
- `is_direct`, `is_assumed`, `is_ceded`: Business type flags
- `transaction_type`: Credit or Debit
- `coverage_description`: Coverage details
- `avg_deductible`, `avg_limit`: Coverage limits

**Grain:** One row per policy amount transaction
**Fact Type:** Transaction fact table (fully additive)

### 2. Fact_Claims
Transactional fact table for claims including payments, reserves, and recoveries.

**Key Foreign Keys:**
- `claim_key` → Dim_Claim
- `policy_key` → Dim_Policy
- `risk_key` → Dim_Risk
- `group_key` → Dim_Group
- `attorney_key` → Dim_Attorney (nullable)
- `court_key` → Dim_Court (nullable)
- `outcome_key` → Dim_Outcome (nullable)
- `transaction_date_key`, `claim_open_date_key` → Dim_Date

**Key Measures:**
- `total_claim_amount`: Total transaction amount
- `net_claim_amount`: Net amount (considering credits/debits)
- `payment_amount`: Total payments
- `reserve_amount`: Total reserves
- `recovery_amount`: Total recoveries
- `loss_payment_amount`: Loss portion of payments
- `expense_payment_amount`: Expense portion (ALAE/ULAE)
- `loss_reserve_amount`: Loss reserves
- `expense_reserve_amount`: Expense reserves
- `direct_claim_amount`: Direct business
- `assumed_claim_amount`: Assumed reinsurance
- `ceded_claim_amount`: Ceded reinsurance

**Key Dimensions:**
- `event_date`: Transaction date
- `transaction_type`: Credit or Debit
- `is_payment`, `is_reserve`, `is_recovery`: Transaction type flags
- `is_loss_payment`, `is_expense_payment`: Payment type flags
- `is_loss_reserve`, `is_expense_reserve`: Reserve type flags
- `is_salvage`, `is_subrogation`, `is_loss_recovery`: Recovery type flags
- `has_litigation`, `has_arbitration`: Legal proceeding indicators
- `settlement_offer_amount`: Offer amount
- `days_claim_open`, `days_since_claim_open`: Time metrics

**Grain:** One row per claim amount transaction
**Fact Type:** Transaction fact table with accumulating snapshot characteristics

## Semantic Views

### 1. sv_premium_summary
Business-friendly view denormalizing premium facts with all dimension attributes.

**Use Cases:**
- Premium revenue analysis by product/LOB/state
- Earned vs. written premium tracking
- Tax and fee analysis
- Direct vs. ceded premium analysis

**Sample Query:**
```sql
SELECT 
    earning_begin_year,
    line_of_business_name,
    policy_state,
    SUM(net_premium_amount) as total_earned_premium,
    SUM(direct_premium_amount) as total_direct_premium,
    COUNT(DISTINCT policy_number) as policy_count
FROM sv_premium_summary
WHERE earning_begin_year = 2024
GROUP BY earning_begin_year, line_of_business_name, policy_state
ORDER BY total_earned_premium DESC;
```

### 2. sv_claims_summary
Business-friendly view denormalizing claims facts with all dimension attributes including legal proceedings.

**Use Cases:**
- Claims paid and reserved analysis
- Loss ratio analysis
- Litigation and arbitration tracking
- Attorney and court performance analysis
- Catastrophe impact analysis

**Sample Query:**
```sql
SELECT 
    claim_open_year,
    line_of_business_name,
    has_litigation,
    COUNT(DISTINCT company_claim_number) as claim_count,
    SUM(loss_payment_amount) as total_loss_paid,
    SUM(expense_payment_amount) as total_expense_paid,
    AVG(days_claim_open) as avg_days_to_close
FROM sv_claims_summary
WHERE claim_open_year = 2024
GROUP BY claim_open_year, line_of_business_name, has_litigation;
```

### 3. sv_policy_analytics
Aggregated view combining premium and claims at the policy level with calculated ratios.

**Use Cases:**
- Loss ratio analysis by policy
- Policy profitability analysis
- Risk selection and underwriting analysis
- Claim frequency and severity categorization

**Key Calculated Metrics:**
- `loss_ratio_pct`: (Total Paid / Premium) × 100
- `incurred_loss_ratio_pct`: ((Paid + Reserved) / Premium) × 100
- `claim_frequency_category`: High/Medium/Single/No Claims
- `claim_severity_category`: High/Medium/Low/No Claims

**Sample Query:**
```sql
SELECT 
    line_of_business_name,
    state_code,
    COUNT(*) as policy_count,
    AVG(loss_ratio_pct) as avg_loss_ratio,
    SUM(total_net_premium) as total_premium,
    SUM(total_claims_paid) as total_paid,
    SUM(claim_count) as total_claims
FROM sv_policy_analytics
WHERE is_active = 1
GROUP BY line_of_business_name, state_code
HAVING AVG(loss_ratio_pct) > 60
ORDER BY avg_loss_ratio DESC;
```

### 4. sv_litigation_analytics
Focused view on claims with legal proceedings (litigation or arbitration).

**Use Cases:**
- Legal expense tracking
- Attorney performance analysis
- Court jurisdiction analysis
- Settlement vs. judgment analysis
- Recovery effectiveness

**Key Calculated Metrics:**
- `recovery_ratio_pct`: (Recoveries / Payments) × 100
- `litigation_duration_days`: Duration of legal proceedings

**Sample Query:**
```sql
SELECT 
    legal_proceeding_type,
    attorney_state,
    court_level,
    COUNT(DISTINCT company_claim_number) as litigation_count,
    SUM(total_legal_payments) as total_paid,
    SUM(total_legal_recoveries) as total_recovered,
    AVG(litigation_duration_days) as avg_duration_days,
    AVG(recovery_ratio_pct) as avg_recovery_ratio
FROM sv_litigation_analytics
WHERE outcome_date >= '2024-01-01'
GROUP BY legal_proceeding_type, attorney_state, court_level
ORDER BY litigation_count DESC;
```

## Common Analysis Patterns

### Premium Analysis
```sql
-- Monthly earned premium trend by line of business
SELECT 
    fiscal_year_month,
    line_of_business_name,
    SUM(net_premium_amount) as earned_premium
FROM sv_premium_summary
WHERE earning_begin_year >= 2023
GROUP BY fiscal_year_month, line_of_business_name
ORDER BY fiscal_year_month, line_of_business_name;
```

### Claims Analysis
```sql
-- Loss development by accident year
SELECT 
    claim_open_year,
    transaction_year,
    SUM(loss_payment_amount) as cumulative_paid,
    SUM(loss_reserve_amount) as case_reserves
FROM sv_claims_summary
GROUP BY claim_open_year, transaction_year
ORDER BY claim_open_year, transaction_year;
```

### Combined Premium and Claims
```sql
-- Loss ratio by state and product
SELECT 
    state_code,
    product_name,
    SUM(total_net_premium) as total_premium,
    SUM(total_claims_paid) as total_paid,
    AVG(loss_ratio_pct) as loss_ratio
FROM sv_policy_analytics
GROUP BY state_code, product_name
HAVING SUM(total_net_premium) > 100000
ORDER BY loss_ratio DESC;
```

### Legal Proceedings Analysis
```sql
-- Attorney effectiveness analysis
SELECT 
    attorney_name,
    law_firm_name,
    COUNT(DISTINCT claim_key) as case_count,
    SUM(total_legal_payments) as total_paid,
    SUM(total_legal_recoveries) as total_recovered,
    AVG(recovery_ratio_pct) as avg_recovery_pct,
    AVG(litigation_duration_days) as avg_duration
FROM sv_litigation_analytics
WHERE outcome_date IS NOT NULL
GROUP BY attorney_name, law_firm_name
HAVING case_count >= 5
ORDER BY avg_recovery_pct DESC;
```

## Implementation Notes

### Deployment
All SQL files are located in the Databricks Asset Bundle structure:
- **Dimensions:** `src/dim_*.sql`
- **Fact Tables:** `src/fact_*.sql`
- **Semantic Views:** `src/sv_*.sql`

### Execution Order
1. Create Date dimension first (no dependencies)
2. Create all other dimensions (can be parallel)
3. Create fact tables (depend on dimensions)
4. Create semantic views (depend on facts and dimensions)

### Variables
All scripts use Databricks variables:
- `${catalog}`: Target catalog
- `${schema}`: Target schema

### Refresh Strategy
- **Dimensions:** Daily incremental updates or full refresh
- **Facts:** Incremental loads based on transaction date
- **Semantic Views:** Materialized views or on-demand (based on performance needs)

## Data Quality Considerations

### Key Business Rules
1. Premium earning periods should not overlap for the same coverage
2. Claim payments should not exceed reserves + subsequent adjustments
3. Policy effective date should be <= claim open date
4. Ceded premium should not exceed direct premium
5. Attorney and court dimensions only populated for claims with litigation/arbitration

### Recommended Checks
- Orphaned fact records (missing dimension keys)
- Negative amounts where not expected
- Future-dated transactions
- Duplicate policy numbers
- Claims without associated policies
- Litigation without attorney or court information

## Performance Optimization

### Partitioning Recommendations
- **Fact_Premium_Payments:** Partition by `earning_begin_date` (monthly)
- **Fact_Claims:** Partition by `event_date` (monthly)
- **Dimensions:** No partitioning (relatively small)

### Indexing Recommendations
- Foreign key columns in fact tables
- Date columns in fact tables
- Policy number, claim number in dimensions

### Aggregation Tables (Optional)
Consider creating aggregate tables for:
- Monthly premium summary by LOB/State
- Monthly claims summary by LOB/State
- Annual policy metrics
- Litigation summary statistics

---

**Version:** 1.0  
**Created:** December 2025  
**Source:** Property Casualty Data Model (PCDM)  
**Platform:** Databricks SQL
