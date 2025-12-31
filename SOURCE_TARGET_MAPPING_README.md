# Source-to-Target Mapping Document

## Overview

**File:** `PCDM_to_Dimensional_Model_Mapping.xlsx`

This Excel workbook provides comprehensive source-to-target mappings showing how the Property Casualty Data Model (PCDM) source tables are transformed into the dimensional model target tables.

## Document Structure

### Summary Tab
- Project overview
- List of all target tables (dimensions and facts)
- Usage instructions

### Individual Table Tabs (10 tabs)
Each tab represents one target table in the dimensional model:

1. **dim_date** - Date dimension (17 mappings)
2. **dim_group** - Customer group dimension (16 mappings)
3. **dim_policy** - Policy dimension (30 mappings)
4. **dim_risk** - Insurable object/risk dimension (33 mappings)
5. **dim_claim** - Claim dimension (36 mappings)
6. **dim_attorney** - Attorney dimension (29 mappings)
7. **dim_court** - Court jurisdiction dimension (10 mappings)
8. **dim_outcome** - Legal outcome dimension (18 mappings)
9. **fact_premium_payments** - Premium fact table (37 mappings)
10. **fact_claims** - Claims fact table (57 mappings)

**Total Mappings:** 283 source-to-target column mappings

## Column Structure

Each mapping tab contains the following columns:

| Column | Description |
|--------|-------------|
| **Source Table** | The PCDM table providing the source data |
| **Source Column** | The specific column in the source table |
| **Transformation** | The SQL transformation logic applied (joins, calculations, CASE statements, etc.) |
| **Target Table** | The dimensional model table (repeated for clarity) |
| **Target Column** | The resulting column in the dimensional model |

## Special Source Table Indicators

- **GENERATED** - Data generated programmatically (e.g., date dimension sequences)
- **CONSTANT** - Hard-coded constant values
- **DERIVED** - Calculated from multiple sources or complex logic
- **SYSTEM** - System-generated values (e.g., timestamps)

## Transformation Types

### Direct Mapping
```
Source Column → Target Column (no transformation)
Example: policy.policy_id → dim_policy.policy_key
```

### Join Transformations
```
LEFT JOIN on foreign key relationships
Example: policy.agreement_id = agreement.agreement_id
```

### Calculated Fields
```
DATEDIFF, CASE WHEN, aggregations
Example: DATEDIFF(expiration_date, effective_date) → policy_term_days
```

### Type Indicators
```
CASE logic based on presence of related records
Example: WHEN automobile_id NOT NULL THEN "Automobile"
```

### Aggregations
```
COUNT, SUM, AVG from related tables
Example: COUNT(DISTINCT coverage_part_code) → coverage_part_count
```

## Key Features

✅ **Comprehensive** - All 10 dimensional model tables mapped  
✅ **Detailed Transformations** - Clear explanation of all SQL logic  
✅ **Organized by Target** - Easy to find mappings for specific tables  
✅ **Color Coded** - Professional formatting with headers  
✅ **Frozen Panes** - Headers remain visible when scrolling  
✅ **Wrapped Text** - Long transformations fully visible  

## Usage Examples

### Finding Source for a Target Column

1. Navigate to the target table tab (e.g., `dim_policy`)
2. Scroll to find your target column
3. Read the source table, source column, and transformation

**Example:**
- Target: `dim_policy.loss_ratio_pct`
- Source: Multiple tables through joins and calculations
- Transformation: Complex calculation involving claims and premium tables

### Understanding Complex Transformations

**Vehicle Type Determination (dim_risk):**
```
Multiple Source Tables: automobile, truck, van, motorcycle, etc.
Transformation: CASE logic checking which sub-type table has a record
Target: dim_risk.vehicle_type
```

**Group Type Classification (dim_group):**
```
Multiple Source Tables: household, professional_group, project, team
Transformation: LEFT JOINs with CASE WHEN logic
Target: dim_group.group_type
```

### Identifying Join Patterns

The transformation column clearly shows join relationships:

```
"LEFT JOIN on policy.agreement_id = agreement.agreement_id"
"LEFT JOIN on product.line_of_business_id = line_of_business.line_of_business_id"
```

## Common Transformation Patterns

### 1. Type/Status Flags
```sql
CASE WHEN claim_close_date IS NOT NULL THEN 1 ELSE 0 END
```
Used for: is_closed, is_active, is_catastrophe, etc.

### 2. Date Calculations
```sql
DATEDIFF(COALESCE(claim_close_date, CURRENT_DATE()), claim_open_date)
```
Used for: days_open, policy_age_days, etc.

### 3. Conditional Amounts
```sql
CASE WHEN is_premium = 1 THEN policy_amount ELSE 0 END
```
Used for: premium_only_amount, tax_amount, etc.

### 4. Hierarchical Joins
```sql
policy → agreement → product → line_of_business → line_of_business_group
```
Navigating through multiple levels of relationships

### 5. Existence Checks
```sql
EXISTS (SELECT 1 FROM claim_litigation WHERE claim_id = claim.claim_id)
```
Used for: has_litigation, has_arbitration flags

## Data Lineage Tracking

This document serves as:
- **Data Dictionary** - Understanding source data origins
- **Impact Analysis** - Seeing which targets are affected by source changes
- **Documentation** - Clear record of transformation logic
- **ETL Specification** - Reference for implementing data pipelines
- **Troubleshooting** - Debugging data quality issues

## Related Documentation

- **STAR_SCHEMA_DOCUMENTATION.md** - Detailed schema design and business rules
- **semantic_model_views/src/*.sql** - Actual SQL implementation
- **FINAL_PROJECT_SUMMARY.md** - Complete project overview

## Maintenance Notes

### When to Update This Document

Update the mapping when:
- Adding new dimensions or facts
- Modifying transformation logic
- Adding or changing source columns
- Implementing new calculated fields

### Validation Checklist

- [ ] All target columns have source mappings
- [ ] Transformation logic is clearly documented
- [ ] Join paths are correct and complete
- [ ] Calculated fields have formulas specified
- [ ] Data types are compatible

## Statistics

- **Total Target Tables:** 10 (8 dimensions + 2 facts)
- **Total Mappings:** 283
- **Source Tables Referenced:** 60+ PCDM tables
- **Transformation Types:** Direct, Join, Calculate, Aggregate, Conditional

## Key PCDM Source Tables

### Most Referenced Tables
1. **policy** - Core policy information (used in dim_policy, fact_premium_payments, fact_claims)
2. **claim** - Core claim information (used in dim_claim, fact_claims)
3. **party** - Party/customer data (used in dim_group, dim_attorney)
4. **agreement** - Policy agreements (used in dim_policy, fact_premium_payments)
5. **insurable_object** - Risks being insured (used in dim_risk)

### Supporting Tables
- Geographic: geographic_location, location_address, state
- Product: line_of_business, product, insurance_class
- Coverage: coverage, coverage_type, policy_coverage_detail
- Legal: litigation, arbitration, attorney, court_jurisdiction
- Financial: policy_amount, claim_amount, premium, claim_payment

## Tips for Using This Document

1. **Start with Summary** - Review project scope and target tables
2. **Navigate by Target** - Use tab for the table you're interested in
3. **Follow Join Paths** - Complex dimensions have multi-table joins
4. **Check Calculations** - Understand derived/calculated fields
5. **Verify Data Types** - Ensure source can populate target
6. **Cross-Reference SQL** - Compare with actual implementation in src/ folder

## Questions & Support

For questions about:
- **Transformation logic** - Review the Transformation column
- **Source tables** - See PCDM documentation (pcdm_create.sql)
- **Target schema** - See STAR_SCHEMA_DOCUMENTATION.md
- **Implementation** - See semantic_model_views/src/*.sql files

---

**Document Version:** 1.0  
**Created:** December 2025  
**Format:** Excel (.xlsx)  
**Total Mappings:** 283  
**Coverage:** Complete dimensional model
