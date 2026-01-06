# Databricks notebook source
"""
09 - Generate Claim Data for PCDM
Creates: occurrence, catastrophe, claim, claim_coverage, claim_party_role
"""
import sys
from pyspark.sql import SparkSession
from config import *
from utils import *

def load_existing_data(spark, catalog, schema):
    """Load existing reference data"""
    print("Loading existing data...")
    
    # Load policies
    policies_df = spark.table(f"{catalog}.{schema}.policy")
    policies = [(row.policy_id, row.effective_date, row.expiration_date) 
                for row in policies_df.collect()]
    
    # Load policy coverage details
    pcd_df = spark.table(f"{catalog}.{schema}.policy_coverage_detail")
    policy_coverages = [(row.policy_coverage_detail_id, row.policy_id) 
                        for row in pcd_df.collect()]
    
    # Load parties (for claimants)
    parties_df = spark.table(f"{catalog}.{schema}.party")
    parties = [row.party_id for row in parties_df.collect()]
    
    # Load states
    states_df = spark.table(f"{catalog}.{schema}.state")
    states = [row.state_code for row in states_df.collect()]
    
    return {
        'policies': policies,
        'policy_coverages': policy_coverages,
        'parties': parties,
        'states': states,
    }


def generate_claim_data(spark):
    """Generate claim data"""
    catalog = DATABASE_CONFIG['catalog']
    schema = DATABASE_CONFIG['schema']
    
    print("=" * 60)
    print("Generating Claim Data")
    print("=" * 60)
    
    # Load reference data
    ref_data = load_existing_data(spark, catalog, schema)
    
    occurrences = []
    catastrophes = []
    claims = []
    claim_coverages = []
    claim_party_roles = []
    
    # 1. Generate Catastrophes
    print("\n1. Generating Catastrophes...")
    for i in range(1, DATA_VOLUMES['catastrophes'] + 1):
        cat_id = id_gen.next_id('catastrophe')
        cat_type, cat_name_template = random.choice(CATASTROPHE_TYPES)
        
        catastrophes.append({
            'catastrophe_id': cat_id,
            'catastrophe_type_code': i,
            'catastrophe_name': f"{cat_name_template} {random.randint(2020, 2024)}",
            'industry_catastrophe_code': random.randint(1000, 9999),
            'company_catastrophe_code': random.randint(100, 999),
        })
    
    print(f"✓ Generated {len(catastrophes)} catastrophes")
    
    # 2. Generate Occurrences
    print("\n2. Generating Occurrences...")
    for i in range(1, DATA_VOLUMES['occurrences'] + 1):
        occurrence_id = id_gen.next_id('occurrence')
        
        occurrence_date = random_date(
            DATE_RANGES['occurrence_start_date'],
            DATE_RANGES['occurrence_end_date']
        )
        
        # Some occurrences are catastrophic
        is_cat = random.random() < BUSINESS_RULES['catastrophe_probability']
        
        occurrences.append({
            'occurrence_id': occurrence_id,
            'catastrophic_event_indicator': 1 if is_cat else 0,
            'geographic_location_id': None,
            'occurrence_begin_date': occurrence_date,
            'occurrence_begin_time': datetime.now().time(),
            'occurrence_end_date': occurrence_date,
            'occurrence_end_time': datetime.now().time(),
        })
        
        if i % 500 == 0:
            print_progress(i, DATA_VOLUMES['occurrences'], 'Occurrences')
    
    print_progress(DATA_VOLUMES['occurrences'], DATA_VOLUMES['occurrences'], 'Occurrences')
    
    # 3. Generate Claims
    print("\n\n3. Generating Claims...")
    
    for i in range(1, DATA_VOLUMES['claims'] + 1):
        claim_id = id_gen.next_id('claim')
        
        # Select random occurrence and policy
        occurrence_id = random.randint(1, len(occurrences))
        occurrence = occurrences[occurrence_id - 1]
        
        policy_id, policy_eff_date, policy_exp_date = random.choice(ref_data['policies'])
        
        # Claim must occur during policy period
        claim_open_date = occurrence['occurrence_begin_date']
        if claim_open_date < policy_eff_date:
            claim_open_date = policy_eff_date
        elif claim_open_date > policy_exp_date:
            continue  # Skip this claim
        
        # Claim reported date (same or after open date)
        report_lag_days = random.randint(0, 30)
        claim_reported_date = add_days(claim_open_date, report_lag_days)
        
        # Determine if claim closes
        days_since_open = (datetime.now().date() - claim_open_date).days
        is_closed = should_claim_close(days_since_open)
        
        if is_closed:
            close_days = random.randint(30, min(days_since_open, 365))
            claim_close_date = add_days(claim_open_date, close_days)
            claim_status = 'CLOSED'
        else:
            claim_close_date = None
            claim_status = 'OPEN'
        
        # Assign to catastrophe if occurrence was catastrophic
        if occurrence['catastrophic_event_indicator'] == 1:
            catastrophe_id = random.randint(1, len(catastrophes))
        else:
            catastrophe_id = None
        
        claims.append({
            'claim_id': claim_id,
            'occurrence_id': occurrence_id,
            'catastrophe_id': catastrophe_id,
            'insurable_object_id': None,  # Would link to risk
            'company_claim_number': generate_claim_number(),
            'company_subclaim_number': None,
            'claim_description': fake.sentence(),
            'claim_open_date': claim_open_date,
            'claim_close_date': claim_close_date,
            'claim_reopen_date': None,
            'claim_status_code': claim_status,
            'claim_reported_date': claim_reported_date,
            'claims_made_date': None,
            'entry_in_to_claims_made_program_date': None,
        })
        
        # Link claim to policy coverages
        policy_covs = [pc for pc in ref_data['policy_coverages'] if pc[1] == policy_id]
        if policy_covs:
            selected_cov = random.choice(policy_covs)
            claim_coverages.append({
                'claim_coverage_id': id_gen.next_id('claim_coverage'),
                'claim_id': claim_id,
                'policy_coverage_detail_id': selected_cov[0],
            })
        
        # Add claimant party role
        claimant_party_id = random.choice(ref_data['parties'])
        claim_party_roles.append({
            'claim_party_role_id': id_gen.next_id('claim_party_role'),
            'party_role_code': 'CLAIMANT',
            'begin_date': claim_open_date,
            'party_id': claimant_party_id,
            'end_date': claim_close_date,
        })
        
        if i % 500 == 0:
            print_progress(i, DATA_VOLUMES['claims'], 'Claims')
    
    print_progress(DATA_VOLUMES['claims'], DATA_VOLUMES['claims'], 'Claims')
    
    # Save to tables
    print("\n\nSaving to Databricks tables...")
    
    df_cat = create_dataframe(catastrophes,
                              ['catastrophe_id', 'catastrophe_type_code', 'catastrophe_name',
                               'industry_catastrophe_code', 'company_catastrophe_code'])
    save_to_table(spark, df_cat, 'catastrophe', catalog, schema)
    
    df_occ = create_dataframe(occurrences,
                              ['occurrence_id', 'catastrophic_event_indicator',
                               'geographic_location_id', 'occurrence_begin_date',
                               'occurrence_begin_time', 'occurrence_end_date', 'occurrence_end_time'])
    save_to_table(spark, df_occ, 'occurrence', catalog, schema)
    
    df_claim = create_dataframe(claims,
                                ['claim_id', 'occurrence_id', 'catastrophe_id', 'insurable_object_id',
                                 'company_claim_number', 'company_subclaim_number', 'claim_description',
                                 'claim_open_date', 'claim_close_date', 'claim_reopen_date',
                                 'claim_status_code', 'claim_reported_date', 'claims_made_date',
                                 'entry_in_to_claims_made_program_date'])
    save_to_table(spark, df_claim, 'claim', catalog, schema)
    
    df_cc = create_dataframe(claim_coverages,
                             ['claim_coverage_id', 'claim_id', 'policy_coverage_detail_id'])
    save_to_table(spark, df_cc, 'claim_coverage', catalog, schema)
    
    df_cpr = create_dataframe(claim_party_roles,
                              ['claim_party_role_id', 'party_role_code', 'begin_date',
                               'party_id', 'end_date'])
    save_to_table(spark, df_cpr, 'claim_party_role', catalog, schema)
    
    print("\n" + "=" * 60)
    print("Claim Data Generation Complete!")
    print(f"  Catastrophes: {len(catastrophes)}")
    print(f"  Occurrences: {len(occurrences)}")
    print(f"  Claims: {len(claims)}")
    print(f"  Claim Coverages: {len(claim_coverages)}")
    print(f"  Claim Party Roles: {len(claim_party_roles)}")
    print("=" * 60)


if __name__ == "__main__":
    spark = SparkSession.builder \
        .appName("PCDM Claim Data Generator") \
        .getOrCreate()
    
    try:
        generate_claim_data(spark)
    except Exception as e:
        print(f"\nError: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        spark.stop()
