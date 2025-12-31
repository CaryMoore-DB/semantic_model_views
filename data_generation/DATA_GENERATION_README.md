# PCDM Fake Data Generation

A comprehensive set of Python scripts to generate realistic synthetic data for the Property Casualty Data Model (PCDM).

## Features

✅ Generates realistic insurance data with referential integrity  
✅ Configurable data volumes and business rules  
✅ Maintains proper relationships between entities  
✅ Realistic probability distributions  
✅ Support for catastrophe events  
✅ Legal proceedings data (litigation, attorneys, courts)  
✅ Progress tracking and error handling

## Quick Start

### Option 1: Databricks Notebook (Recommended)

1. Upload all files to Databricks workspace
2. Open and run `DATABRICKS_NOTEBOOK.py`
3. Set your target catalog and schema
4. Run all cells sequentially

### Option 2: Python Scripts Locally

1. **Install Dependencies:**
```bash
cd data_generation
pip install -r requirements.txt
```

2. **Configure Settings:**
Edit `config.py` to set:
- Target catalog and schema
- Data volumes
- Date ranges
- Business rules

3. **Run All Generators:**
```bash
python run_all_generators.py
```

Or run individual scripts in order:
```bash
python 01_generate_reference_data.py
python 02_generate_parties.py
python 04_generate_products.py
python 05_generate_policies.py
python 09_generate_claims.py
# ... etc
```

## Generated Data

### Reference Data
- **States**: 50 US states
- **Party Roles**: 10 roles (Insured, Claimant, Attorney, etc.)
- **Coverage Types**: 20 coverage types
- **Lines of Business**: 15 LOBs (Personal Auto, Homeowners, etc.)

### Party Data (Configurable)
- **Persons**: 5,000 individuals with realistic names/demographics
- **Organizations**: 500 companies
- **Households**: 1,500 household groups
- **Professional Groups**: 50 business groups

### Policy Data
- **Policies**: 10,000 policies with realistic terms
- **Coverage Details**: Average 3 coverages per policy
- **Limits & Deductibles**: Realistic coverage limits

### Claim Data
- **Occurrences**: 3,000 loss events
- **Catastrophes**: 10 major events
- **Claims**: 2,500 claims with realistic lifecycle
- **Legal Proceedings**: 10-15% with litigation/arbitration

## Configuration

### Data Volumes (`config.py`)

```python
DATA_VOLUMES = {
    'persons': 5000,
    'organizations': 500,
    'policies': 10000,
    'claims': 2500,
    # ... adjust as needed
}
```

### Business Rules

```python
BUSINESS_RULES = {
    'claim_probability': 0.80,        # 80% of occurrences become claims
    'litigation_probability': 0.10,    # 10% go to litigation
    'catastrophe_probability': 0.05,   # 5% are catastrophes
    # ...
}
```

### Premium Ranges by Line of Business

```python
'premium_ranges': {
    'Personal Auto': {'min': 500, 'max': 3000},
    'Homeowners': {'min': 800, 'max': 5000},
    'Commercial Auto': {'min': 2000, 'max': 20000},
    # ...
}
```

## Execution Order

Scripts must be run in this order to maintain referential integrity:

1. **01_generate_reference_data.py** - Lookup tables
2. **02_generate_parties.py** - Persons, organizations, groups
3. **03_generate_locations.py** - Addresses and locations
4. **04_generate_products.py** - Products and LOBs
5. **05_generate_policies.py** - Policies and coverages
6. **06_generate_risks.py** - Insurable objects
7. **07_generate_premiums.py** - Premium transactions
8. **08_generate_occurrences.py** - Loss events
9. **09_generate_claims.py** - Claims
10. **10_generate_claim_amounts.py** - Payments, reserves, recoveries
11. **11_generate_legal_data.py** - Litigation, attorneys, courts

## Data Characteristics

### Realistic Distributions

- **Claim Severity**: Exponential distribution (most claims are small)
- **Claim Closure**: Time-based probability (longer open = more likely to close)
- **Premiums**: Vary by product and coverage
- **Legal Proceedings**: Concentrated in larger claims

### Business Logic

- Claims only occur during active policy periods
- Claim amounts respect deductibles and limits
- Catastrophe events can affect multiple claims
- Litigation claims have associated attorneys and courts
- Policy status updates based on dates (Active/Expired/Cancelled)

## Output Tables

The generators create properly structured tables in your specified catalog/schema:

### Core Tables
- `party`, `person`, `organization`, `grouping`, `household`
- `policy`, `agreement`, `policy_coverage_detail`
- `claim`, `occurrence`, `catastrophe`
- `claim_amount`, `claim_payment`, `claim_reserve`

### Legal Tables
- `attorney`, `litigation`, `arbitration`, `court_jurisdiction`
- `litigation_party_role`, `arbitration_party_role`

### Reference Tables
- `state`, `party_role`, `coverage`, `coverage_type`
- `line_of_business`, `product`, `company`

## Validation Queries

After generation, validate the data:

```sql
-- Check referential integrity
SELECT 
    'Policies without parties' as check_name,
    COUNT(*) as count
FROM main.pcdm_test.policy p
LEFT JOIN main.pcdm_test.agreement a ON p.agreement_id = a.agreement_id
LEFT JOIN main.pcdm_test.agreement_party_role apr ON a.agreement_id = apr.agreement_id
WHERE apr.agreement_party_role_id IS NULL;

-- Check claim date logic
SELECT 
    'Claims before policy effective' as check_name,
    COUNT(*) as count
FROM main.pcdm_test.claim c
JOIN main.pcdm_test.claim_coverage cc ON c.claim_id = cc.claim_id
JOIN main.pcdm_test.policy_coverage_detail pcd ON cc.policy_coverage_detail_id = pcd.policy_coverage_detail_id
JOIN main.pcdm_test.policy p ON pcd.policy_id = p.policy_id
WHERE c.claim_open_date < p.effective_date;

-- Check data volumes
SELECT 
    'Parties' as entity,
    COUNT(*) as count
FROM main.pcdm_test.party
UNION ALL
SELECT 'Policies', COUNT(*) FROM main.pcdm_test.policy
UNION ALL
SELECT 'Claims', COUNT(*) FROM main.pcdm_test.claim
UNION ALL
SELECT 'Claims with Litigation', COUNT(*) 
FROM main.pcdm_test.claim c
WHERE EXISTS (SELECT 1 FROM main.pcdm_test.claim_litigation cl WHERE cl.claim_id = c.claim_id);
```

## Customization

### Adding New Entities

1. Add configuration to `config.py`
2. Create new generator script `XX_generate_<entity>.py`
3. Add to `GENERATOR_SCRIPTS` in `run_all_generators.py`
4. Maintain proper execution order

### Adjusting Probabilities

Edit `BUSINESS_RULES` in `config.py`:

```python
BUSINESS_RULES = {
    'litigation_probability': 0.15,  # Increase to 15%
    'claim_severity': {
        'low': {'min': 1000, 'max': 10000},  # Adjust ranges
        # ...
    },
}
```

## Performance

- **Small dataset** (1K policies): ~2-3 minutes
- **Medium dataset** (10K policies): ~10-15 minutes  
- **Large dataset** (100K policies): ~1-2 hours

Progress bars show real-time status for long-running operations.

## Troubleshooting

### Common Issues

**Error: Table already exists**
- Set mode='overwrite' in `save_to_table()` calls
- Or drop existing tables first

**Error: Foreign key constraint**
- Ensure scripts run in correct order
- Check that reference data was generated

**Error: Out of memory**
- Reduce `DATA_VOLUMES` in config
- Process in smaller batches

## Dependencies

```
faker>=18.0.0
pandas>=1.5.0
numpy>=1.24.0
pyspark>=3.3.0  # Included in Databricks
```

## License

This is synthetic data generation for testing purposes only.

---

**Ready to populate your PCDM with realistic test data!** 🎉
