# Databricks notebook source

# COMMAND ----------

"""
05 - Generate Policy Data for PCDM
Creates: agreement, policy, policy_coverage_detail, policy_limit, policy_deductible
"""

# COMMAND ----------

from pyspark.sql import SparkSession
from config import *
from utils import *

# COMMAND ----------

def load_existing_data(spark, catalog, schema):
    """Load existing reference data"""
    print("Loading existing data...")
    
    # Load parties to use as insureds
    parties_df = spark.table(f"{catalog}.{schema}.party")
    parties = [(row.party_id, row.party_name) for row in parties_df.collect()]
    
    # Load products
    products_df = spark.table(f"{catalog}.{schema}.product")
    products = [(row.product_id, row.line_of_business_id, row.licensed_product_name) 
                for row in products_df.collect()]
    
    # Load states
    states_df = spark.table(f"{catalog}.{schema}.state")
    states = [row.state_code for row in states_df.collect()]
    
    # Load coverages
    coverages_df = spark.table(f"{catalog}.{schema}.coverage")
    coverages = [(row.coverage_id, row.coverage_part_code, row.coverage_name) 
                 for row in coverages_df.collect()]
    
    return {
        'parties': parties,
        'products': products,
        'states': states,
        'coverages': coverages,
    }

# COMMAND ----------

def generate_policy_data(spark):
    """Generate policy data"""
    catalog = DATABASE_CONFIG['catalog']
    schema = DATABASE_CONFIG['schema']
    
    print("=" * 60)
    print("Generating Policy Data")
    print("=" * 60)
    
    # Load reference data
    ref_data = load_existing_data(spark, catalog, schema)
    
    agreements = []
    policies = []
    policy_coverage_details = []
    policy_limits = []
    policy_deductibles = []
    agreement_party_roles = []
    
    print(f"\nGenerating {DATA_VOLUMES['policies']} policies...")
    
    for i in range(1, DATA_VOLUMES['policies'] + 1):
        agreement_id = id_gen.next_id('agreement')
        policy_id = id_gen.next_id('policy')
        
        # Select random product and party
        product_id, lob_id, product_name = random.choice(ref_data['products'])
        party_id, party_name = random.choice(ref_data['parties'])
        state_code = random.choice(ref_data['states'])
        
        # Generate policy dates
        inception_date = random_date(
            DATE_RANGES['policy_start_date'],
            DATE_RANGES['policy_end_date']
        )
        term_days = random.randint(
            DATE_RANGES['policy_term_days_min'],
            DATE_RANGES['policy_term_days_max']
        )
        effective_date = inception_date.date() if hasattr(inception_date, 'date') else inception_date
        expiration_date = add_days(effective_date, term_days)
        
        # Get today's date for comparison
        today = datetime.now().date()
        
        # Policy status
        if expiration_date < today:
            status = random.choice(['EXPIRED', 'CANCELLED'])
        elif effective_date > today:
            status = 'PENDING'
        else:
            status = 'ACTIVE'
        
        # Agreement record
        agreements.append({
            'agreement_id': agreement_id,
            'agreement_type_code': 1,  # Policy
            'agreement_name': f"Agreement {agreement_id}",
            'agreement_original_inception_date': inception_date,
            'product_id': product_id,
        })
        
        # Policy record
        policies.append({
            'policy_id': policy_id,
            'agreement_id': agreement_id,
            'policy_number': generate_policy_number(),
            'effective_date': effective_date,
            'expiration_date': expiration_date,
            'status_code': status,
        })
        
        # Agreement party role (insured)
        agreement_party_roles.append({
            'agreement_party_role_id': id_gen.next_id('agreement_party_role'),
            'agreement_id': agreement_id,
            'party_role_code': 'INSURED',
            'effective_date': effective_date,
            'party_id': party_id,
            'expiration_date': expiration_date,
        })
        
        # Add another role for group if party is organization
        if random.random() < 0.3:  # 30% chance of group policy
            agreement_party_roles.append({
                'agreement_party_role_id': id_gen.next_id('agreement_party_role'),
                'agreement_id': agreement_id,
                'party_role_code': 'GROUP',
                'effective_date': effective_date,
                'party_id': party_id,
                'expiration_date': expiration_date,
            })
        
        # Generate coverages for this policy
        num_coverages = random.randint(1, DATA_VOLUMES['avg_coverages_per_policy'])
        selected_coverages = random.sample(ref_data['coverages'], 
                                          min(num_coverages, len(ref_data['coverages'])))
        
        for coverage_id, coverage_part_code, coverage_name in selected_coverages:
            pcd_id = id_gen.next_id('policy_coverage_detail')
            
            policy_coverage_details.append({
                'policy_coverage_detail_id': pcd_id,
                'effective_date': effective_date,
                'policy_id': policy_id,
                'coverage_part_code': coverage_part_code,
                'coverage_id': coverage_id,
                'expiration_date': expiration_date,
                'coverage_inclusion_exclusion_code': 1,  # Inclusion
                'coverage_description': coverage_name,
            })
            
            # Add limit
            if 'Liability' in coverage_name:
                limit_value = random.choice([100000, 250000, 500000, 1000000])
            else:
                limit_value = random.choice([25000, 50000, 100000, 250000])
            
            policy_limits.append({
                'policy_limit_id': id_gen.next_id('policy_limit'),
                'policy_coverage_detail_id': pcd_id,
                'limit_type_code': 1,  # Per occurrence
                'limit_basis_code': 1,
                'limit_value': limit_value,
            })
            
            # Add deductible
            if 'Liability' not in coverage_name:
                deductible_value = random.choice([250, 500, 1000, 2500])
                policy_deductibles.append({
                    'policy_deductible_identifier': id_gen.next_id('policy_deductible'),
                    'policy_coverage_detail_id': pcd_id,
                    'deductible_type_code': 1,
                    'deductible_basis_code': 1,
                    'deductible_value': deductible_value,
                })
        
        if i % 1000 == 0:
            print_progress(i, DATA_VOLUMES['policies'], 'Policies')
    
    print_progress(DATA_VOLUMES['policies'], DATA_VOLUMES['policies'], 'Policies')
    
    # Save to tables
    print("\n\nSaving to Databricks tables...")
    
    df_agreement = create_dataframe(agreements,
                                    ['agreement_id', 'agreement_type_code', 'agreement_name',
                                     'agreement_original_inception_date', 'product_id'])
    save_to_table(spark, df_agreement, 'agreement', catalog, schema)
    
    df_policy = create_dataframe(policies,
                                 ['policy_id', 'agreement_id', 'policy_number',
                                  'effective_date', 'expiration_date', 'status_code'])
    save_to_table(spark, df_policy, 'policy', catalog, schema)
    
    df_apr = create_dataframe(agreement_party_roles,
                              ['agreement_party_role_id', 'agreement_id', 'party_role_code',
                               'effective_date', 'party_id', 'expiration_date'])
    save_to_table(spark, df_apr, 'agreement_party_role', catalog, schema)
    
    df_pcd = create_dataframe(policy_coverage_details,
                              ['policy_coverage_detail_id', 'effective_date', 'policy_id',
                               'coverage_part_code', 'coverage_id', 'expiration_date', 
                               'coverage_inclusion_exclusion_code', 'coverage_description'])
    save_to_table(spark, df_pcd, 'policy_coverage_detail', catalog, schema)
    
    df_limit = create_dataframe(policy_limits,
                                ['policy_limit_id', 'policy_coverage_detail_id',
                                 'limit_type_code', 'limit_basis_code', 'limit_value'])
    save_to_table(spark, df_limit, 'policy_limit', catalog, schema)
    
    if policy_deductibles:
        df_deduct = create_dataframe(policy_deductibles,
                                     ['policy_deductible_identifier', 'policy_coverage_detail_id',
                                      'deductible_type_code', 'deductible_basis_code', 
                                      'deductible_value'])
        save_to_table(spark, df_deduct, 'policy_deductible', catalog, schema)
    
    print("\n" + "=" * 60)
    print("Policy Data Generation Complete!")
    print(f"  Agreements: {len(agreements)}")
    print(f"  Policies: {len(policies)}")
    print(f"  Coverage Details: {len(policy_coverage_details)}")
    print(f"  Limits: {len(policy_limits)}")
    print(f"  Deductibles: {len(policy_deductibles)}")
    print("=" * 60)

# COMMAND ----------

# Execute the function (Databricks manages the Spark session)
generate_policy_data(spark)
