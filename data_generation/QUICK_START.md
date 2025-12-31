# PCDM Data Generation - Quick Start Guide

## 🚀 Quick Start (Databricks)

### Option 1: Run in Databricks Notebook

1. **Upload to Workspace:**
   - Upload entire `data_generation` folder to Databricks workspace
   - Or use Databricks CLI: `databricks workspace import-dir data_generation /Workspace/Users/<your-email>/pcdm_generation`

2. **Open Notebook:**
   - Open `DATABRICKS_NOTEBOOK.py` in Databricks

3. **Configure:**
   ```python
   CATALOG = "main"
   SCHEMA = "pcdm_test"  # Your target schema
   ```

4. **Run All Cells:**
   - Execute cells sequentially
   - Progress will be shown for each step

5. **Verify:**
   ```sql
   SELECT COUNT(*) FROM main.pcdm_test.policy;
   SELECT COUNT(*) FROM main.pcdm_test.claim;
   ```

### Option 2: Run Individual Scripts

```python
# In Databricks notebook
%run ./01_generate_reference_data
%run ./02_generate_parties
%run ./04_generate_products
%run ./05_generate_policies
%run ./09_generate_claims
```

## 💻 Local Development (Optional)

### Setup

```bash
cd data_generation
pip install -r requirements.txt
```

### Configuration

Edit `config.py`:

```python
DATABASE_CONFIG = {
    'catalog': 'main',
    'schema': 'pcdm_test',
}

DATA_VOLUMES = {
    'persons': 5000,
    'policies': 10000,
    'claims': 2500,
    # Adjust volumes as needed
}
```

### Run

```bash
# Run all generators
python run_all_generators.py

# Or run individually
python 01_generate_reference_data.py
python 02_generate_parties.py
# ... etc
```

## 📊 What Gets Generated

### Reference Data
- 50 US States
- 10 Party Roles
- 20 Coverage Types
- 15 Lines of Business
- 10 Insurance Companies

### Entity Data (Configurable Volumes)
- **5,000** Persons with realistic demographics
- **500** Organizations
- **1,500** Households
- **10,000** Policies with coverages
- **3,000** Occurrences/Loss Events
- **2,500** Claims
- **250** Claims with litigation
- **100** Attorneys

### Realistic Features
✅ Proper date logic (claims within policy periods)  
✅ Referential integrity maintained  
✅ Realistic premium ranges by product  
✅ Exponential claim severity distribution  
✅ Catastrophe events  
✅ Legal proceedings (10% of claims)  
✅ Time-based claim closure logic

## 🎯 Expected Runtime

- **Small** (1K policies): 2-3 minutes
- **Medium** (10K policies): 10-15 minutes
- **Large** (100K policies): 1-2 hours

## ✅ Validation

After generation, run these queries:

```sql
-- Data volumes
SELECT 
    'Parties' as entity, COUNT(*) as count FROM main.pcdm_test.party
UNION ALL
SELECT 'Policies', COUNT(*) FROM main.pcdm_test.policy
UNION ALL
SELECT 'Claims', COUNT(*) FROM main.pcdm_test.claim;

-- Referential integrity check
SELECT 
    p.policy_id,
    p.policy_number,
    COUNT(pcd.policy_coverage_detail_id) as coverage_count
FROM main.pcdm_test.policy p
LEFT JOIN main.pcdm_test.policy_coverage_detail pcd 
    ON p.policy_id = pcd.policy_id
GROUP BY p.policy_id, p.policy_number
HAVING coverage_count = 0;  -- Should return no rows

-- Claim date validation
SELECT COUNT(*) as invalid_claims
FROM main.pcdm_test.claim c
JOIN main.pcdm_test.claim_coverage cc ON c.claim_id = cc.claim_id
JOIN main.pcdm_test.policy_coverage_detail pcd 
    ON cc.policy_coverage_detail_id = pcd.policy_coverage_detail_id
JOIN main.pcdm_test.policy p ON pcd.policy_id = p.policy_id
WHERE c.claim_open_date < p.effective_date
   OR c.claim_open_date > p.expiration_date;
-- Should return 0
```

## 🔧 Customization

### Adjust Data Volumes

In `config.py`:
```python
DATA_VOLUMES = {
    'persons': 10000,      # Double the persons
    'policies': 50000,     # 5x policies
    'claims': 10000,       # 4x claims
    # ...
}
```

### Modify Business Rules

```python
BUSINESS_RULES = {
    'litigation_probability': 0.20,  # 20% go to litigation
    'catastrophe_probability': 0.10, # 10% catastrophes
    # ...
}
```

### Change Premium Ranges

```python
'premium_ranges': {
    'Personal Auto': {'min': 1000, 'max': 5000},  # Higher premiums
    # ...
}
```

## 📁 File Structure

```
data_generation/
├── README.md                          # This file
├── DATA_GENERATION_README.md          # Detailed documentation
├── requirements.txt                   # Python dependencies
├── config.py                          # Configuration settings
├── utils.py                           # Utility functions
├── run_all_generators.py              # Master runner script
├── DATABRICKS_NOTEBOOK.py             # Databricks notebook version
├── 01_generate_reference_data.py      # Reference data
├── 02_generate_parties.py             # Persons, orgs, groups
├── 04_generate_products.py            # Products and LOBs
├── 05_generate_policies.py            # Policies and coverages
└── 09_generate_claims.py              # Claims and occurrences
```

## 🐛 Troubleshooting

**Error: Module not found**
- Ensure `faker`, `pandas`, `numpy` are installed
- In Databricks, these are pre-installed

**Error: Table already exists**
- Tables are overwritten by default
- Or drop existing schema first

**Error: Foreign key constraint**
- Run scripts in correct order
- Don't skip reference data generation

**Slow performance**
- Reduce DATA_VOLUMES in config.py
- Run in cluster with more resources

## 📝 Next Steps

After generating data:

1. **Test Star Schema:**
   ```bash
   cd ../semantic_model_views
   databricks bundle deploy --target dev
   ```

2. **Query Semantic Views:**
   ```sql
   -- Premium analysis
   SELECT 
       line_of_business_name,
       SUM(net_premium_amount) as total_premium
   FROM main.pcdm_test.sv_premium_summary
   GROUP BY line_of_business_name;
   
   -- Claims analysis
   SELECT 
       claim_status_code,
       COUNT(*) as claim_count,
       SUM(total_claim_amount) as total_amount
   FROM main.pcdm_test.sv_claims_summary
   GROUP BY claim_status_code;
   ```

3. **Build Reports:**
   - Connect BI tools to semantic views
   - Create dashboards
   - Analyze loss ratios and trends

## 💡 Tips

- Start with smaller volumes for testing
- Monitor progress bars for long-running operations
- Check validation queries after each major step
- Save configuration changes for reproducibility
- Use different schemas for different test scenarios

---

**Ready to generate realistic PCDM test data!** 🎉

For detailed documentation, see `DATA_GENERATION_README.md`
