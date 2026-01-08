# Databricks notebook source

# COMMAND ----------

"""
05 - Generate Policy Data for PCDM
Creates: agreement, policy, policy_coverage_detail, policy_limit, policy_deductible
        insurable_object, vehicle, structure, commercial_structure, residential_structure
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
    
    # Load geographic locations
    geo_locations_df = spark.table(f"{catalog}.{schema}.geographic_location")
    geo_locations = [row.geographic_location_id for row in geo_locations_df.collect()]
    
    # Load coverages
    coverages_df = spark.table(f"{catalog}.{schema}.coverage")
    coverages = [(row.coverage_id, row.coverage_part_code, row.coverage_name) 
                 for row in coverages_df.collect()]
    
    return {
        'parties': parties,
        'products': products,
        'states': states,
        'geo_locations': geo_locations,
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
    
    # Insurable object lists
    insurable_objects = []
    vehicles = []
    structures = []
    commercial_structures = []
    residential_structures = []
    
    print(f"\nGenerating {DATA_VOLUMES['policies']} policies...")
    
    for i in range(1, DATA_VOLUMES['policies'] + 1):
        agreement_id = id_gen.next_id('agreement')
        policy_id = id_gen.next_id('policy')
        
        # Select random product, party, and location
        product_id, lob_id, product_name = random.choice(ref_data['products'])
        party_id, party_name = random.choice(ref_data['parties'])
        state_code = random.choice(ref_data['states'])
        geographic_location_id = random.choice(ref_data['geo_locations'])
        
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
            'geographic_location_id': geographic_location_id,
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
            
            # Determine if this coverage needs an insurable object
            insurable_object_id = None
            
            # Create vehicle for Auto coverages
            if any(keyword in coverage_name for keyword in ['Auto', 'Vehicle', 'Collision', 'Comprehensive']):
                insurable_object_id = id_gen.next_id('insurable_object')
                vehicle_id = id_gen.next_id('vehicle')
                
                # Create insurable object
                insurable_objects.append({
                    'insurable_object_id': insurable_object_id,
                    'insurable_object_type_code': 'VEHICLE',
                    'geographic_location_id': geographic_location_id
                })
                
                # Create vehicle
                vehicle_make = random.choice(VEHICLE_MAKES)
                vehicle_year = random.randint(2010, 2024)
                
                vehicles.append({
                    'vehicle_id': vehicle_id,
                    'insurable_object_id': insurable_object_id,
                    'vehicle_make_name': vehicle_make,
                    'vehicle_model_name': f"{vehicle_make} Model",
                    'vehicle_model_year': vehicle_year,
                    'vehicle_identification_number': f"VIN{insurable_object_id:010d}",
                    'vehicle_type_code': random.choice(['SEDAN', 'SUV', 'TRUCK', 'VAN']),
                })
            
            # Create structure for Property coverages
            elif any(keyword in coverage_name for keyword in ['Property', 'Dwelling', 'Building', 'Homeowners', 'Commercial Property']):
                insurable_object_id = id_gen.next_id('insurable_object')
                structure_id = id_gen.next_id('structure')
                
                # Create insurable object
                insurable_objects.append({
                    'insurable_object_id': insurable_object_id,
                    'insurable_object_type_code': 'STRUCTURE',
                    'geographic_location_id': geographic_location_id
                })
                
                # Create structure
                # Determine if commercial based on product name, coverage name, or specific commercial keywords
                is_commercial = ('Commercial' in product_name or 
                               'Business' in coverage_name or 
                               'Building' in coverage_name or
                               coverage_name in ['General Aggregate', 'Products/Completed Operations'])
                
                structures.append({
                    'structure_id': structure_id,
                    'insurable_object_id': insurable_object_id,
                    'structure_type_code': random.choice(['SINGLE_FAMILY', 'MULTI_FAMILY', 'COMMERCIAL']) if not is_commercial else 'COMMERCIAL',
                })
                
                # Create commercial or residential subtype
                if is_commercial:
                    commercial_structures.append({
                        'commercial_structure_id': id_gen.next_id('commercial_structure'),
                        'structure_id': structure_id,
                        'business_type_code': random.choice(['OFFICE', 'RETAIL', 'WAREHOUSE', 'MANUFACTURING']),
                    })
                else:
                    residential_structures.append({
                        'residential_structure_id': id_gen.next_id('residential_structure'),
                        'structure_id': structure_id,
                        'occupancy_type_code': random.choice(['OWNER', 'TENANT', 'VACANT']),
                    })
            
            # Create policy coverage detail with insurable_object_id
            policy_coverage_details.append({
                'policy_coverage_detail_id': pcd_id,
                'effective_date': effective_date,
                'policy_id': policy_id,
                'coverage_part_code': coverage_part_code,
                'coverage_id': coverage_id,
                'expiration_date': expiration_date,
                'coverage_inclusion_exclusion_code': 1,  # Inclusion
                'coverage_description': coverage_name,
                'insurable_object_id': insurable_object_id,  # Link to insurable object
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
                                  'effective_date', 'expiration_date', 'status_code',
                                  'geographic_location_id'])
    save_to_table(spark, df_policy, 'policy', catalog, schema)
    
    df_apr = create_dataframe(agreement_party_roles,
                              ['agreement_party_role_id', 'agreement_id', 'party_role_code',
                               'effective_date', 'party_id', 'expiration_date'])
    save_to_table(spark, df_apr, 'agreement_party_role', catalog, schema)
    
    df_pcd = create_dataframe(policy_coverage_details,
                              ['policy_coverage_detail_id', 'effective_date', 'policy_id',
                               'coverage_part_code', 'coverage_id', 'expiration_date', 
                               'coverage_inclusion_exclusion_code', 'coverage_description',
                               'insurable_object_id'])
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
    
    # Save insurable objects
    if insurable_objects:
        df_insurable_object = create_dataframe(insurable_objects,
                                               ['insurable_object_id', 'insurable_object_type_code',
                                                'geographic_location_id'])
        save_to_table(spark, df_insurable_object, 'insurable_object', catalog, schema)
    
    if vehicles:
        df_vehicle = create_dataframe(vehicles,
                                     ['vehicle_id', 'insurable_object_id', 'vehicle_make_name',
                                      'vehicle_model_name', 'vehicle_model_year',
                                      'vehicle_identification_number', 'vehicle_type_code'])
        save_to_table(spark, df_vehicle, 'vehicle', catalog, schema)
    
    if structures:
        df_structure = create_dataframe(structures,
                                       ['structure_id', 'insurable_object_id', 'structure_type_code'])
        save_to_table(spark, df_structure, 'structure', catalog, schema)
    
    if commercial_structures:
        df_commercial_structure = create_dataframe(commercial_structures,
                                                   ['commercial_structure_id', 'structure_id',
                                                    'business_type_code'])
        save_to_table(spark, df_commercial_structure, 'commercial_structure', catalog, schema)
    
    if residential_structures:
        df_residential_structure = create_dataframe(residential_structures,
                                                   ['residential_structure_id', 'structure_id',
                                                    'occupancy_type_code'])
        save_to_table(spark, df_residential_structure, 'residential_structure', catalog, schema)
    
    print("\n" + "=" * 60)
    print("Policy Data Generation Complete!")
    print(f"  Agreements: {len(agreements)}")
    print(f"  Policies: {len(policies)}")
    print(f"  Coverage Details: {len(policy_coverage_details)}")
    print(f"  Limits: {len(policy_limits)}")
    print(f"  Deductibles: {len(policy_deductibles)}")
    print(f"  Insurable Objects: {len(insurable_objects)}")
    print(f"  Vehicles: {len(vehicles)}")
    print(f"  Structures: {len(structures)}")
    print(f"  Commercial Structures: {len(commercial_structures)}")
    print(f"  Residential Structures: {len(residential_structures)}")
    print("=" * 60)

# COMMAND ----------

# Execute the function (Databricks manages the Spark session)
generate_policy_data(spark)
