# PCDM Fake Data Generation Requirements

## Installation

```bash
pip install faker pandas numpy
```

## Data Generation Scripts

This folder contains Python scripts to generate synthetic data for the Property Casualty Data Model (PCDM).

## Execution Order

The scripts must be run in the following order to maintain referential integrity:

### Phase 1: Reference Data
1. `01_generate_reference_data.py` - States, coverage types, etc.

### Phase 2: Party Data
2. `02_generate_parties.py` - Persons, organizations, groups

### Phase 3: Geographic Data
3. `03_generate_locations.py` - Addresses and geographic locations

### Phase 4: Product Data
4. `04_generate_products.py` - Lines of business, products

### Phase 5: Policy Data
5. `05_generate_policies.py` - Agreements and policies

### Phase 6: Risk Data
6. `06_generate_risks.py` - Insurable objects (vehicles, structures)

### Phase 7: Premium Data
7. `07_generate_premiums.py` - Policy amounts and premiums

### Phase 8: Occurrence Data
8. `08_generate_occurrences.py` - Occurrences and catastrophes

### Phase 9: Claim Data
9. `09_generate_claims.py` - Claims

### Phase 10: Claim Amount Data
10. `10_generate_claim_amounts.py` - Payments, reserves, recoveries

### Phase 11: Legal Data
11. `11_generate_legal_data.py` - Litigation, arbitration, attorneys

## Running All Scripts

```bash
python run_all_generators.py
```

## Configuration

Edit `config.py` to control:
- Number of records to generate
- Date ranges
- Probability distributions
- Database connection settings
