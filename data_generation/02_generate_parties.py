# Databricks notebook source

# COMMAND ----------

"""
02 - Generate Party Data for PCDM
Creates: party, person, organization, grouping, household
"""

# COMMAND ----------

import sys
from pyspark.sql import SparkSession
from config import *
from utils import *

# COMMAND ----------

def generate_party_data(spark):
    """Generate party data including persons, organizations, and groups"""
    catalog = DATABASE_CONFIG['catalog']
    schema = DATABASE_CONFIG['schema']
    
    print("=" * 60)
    print("Generating Party Data")
    print("=" * 60)
    
    # Track IDs
    parties = []
    persons = []
    organizations = []
    groupings = []
    households = []
    
    # 1. Generate Persons
    print("\n1. Generating Persons...")
    for i in range(1, DATA_VOLUMES['persons'] + 1):
        party_id = id_gen.next_id('party')
        person_id = id_gen.next_id('person')
        
        person_data = generate_person_dict()
        begin_date = random_date(
            datetime(2010, 1, 1),
            datetime(2020, 1, 1)
        )
        
        # Party record
        parties.append({
            'party_id': party_id,
            'party_name': person_data['full_legal_name'],
            'party_type_code': 'PERSON',
            'begin_date': begin_date,
            'end_date': None,
        })
        
        # Person record
        persons.append({
            'person_id': person_id,
            'party_id': party_id,
            **person_data,
        })
        
        if i % 500 == 0:
            print_progress(i, DATA_VOLUMES['persons'], 'Persons')
    
    print_progress(DATA_VOLUMES['persons'], DATA_VOLUMES['persons'], 'Persons')
    
    # 2. Generate Organizations
    print("\n\n2. Generating Organizations...")
    org_types = ['CORPORATION', 'LLC', 'PARTNERSHIP', 'SOLE_PROPRIETOR', 'NON_PROFIT']
    industry_codes = ['RETAIL', 'MANUFACTURING', 'SERVICES', 'CONSTRUCTION', 
                     'HEALTHCARE', 'TECHNOLOGY', 'FINANCE', 'EDUCATION']
    
    for i in range(1, DATA_VOLUMES['organizations'] + 1):
        party_id = id_gen.next_id('party')
        org_id = id_gen.next_id('organization')
        
        org_name = fake.company()
        begin_date = random_date(
            datetime(2000, 1, 1),
            datetime(2020, 1, 1)
        )
        
        # Party record
        parties.append({
            'party_id': party_id,
            'party_name': org_name,
            'party_type_code': 'ORGANIZATION',
            'begin_date': begin_date,
            'end_date': None,
        })
        
        # Organization record
        organizations.append({
            'organization_id': org_id,
            'party_id': party_id,
            'organization_type_code': random.choice(org_types),
            'organization_name': org_name,
            'alternate_name': None,
            'acronym_name': None,
            'industry_type_code': random.choice(industry_codes),
            'industry_code': random.choice(industry_codes),
            'dun_and_bradstreet_id': None,
            'organization_description': fake.catch_phrase(),
        })
        
        if i % 100 == 0:
            print_progress(i, DATA_VOLUMES['organizations'], 'Organizations')
    
    print_progress(DATA_VOLUMES['organizations'], DATA_VOLUMES['organizations'], 'Organizations')
    
    # 3. Generate Households
    print("\n\n3. Generating Households...")
    for i in range(1, DATA_VOLUMES['households'] + 1):
        party_id = id_gen.next_id('party')
        grouping_id = id_gen.next_id('grouping')
        household_id = id_gen.next_id('household')
        
        household_name = f"Household {i}"
        begin_date = random_date(
            datetime(2010, 1, 1),
            datetime(2020, 1, 1)
        )
        
        # Party record
        parties.append({
            'party_id': party_id,
            'party_name': household_name,
            'party_type_code': 'GROUPING',
            'begin_date': begin_date,
            'end_date': None,
        })
        
        # Grouping record
        groupings.append({
            'grouping_id': grouping_id,
            'party_id': party_id,
            'grouping_name': household_name,
        })
        
        # Household record
        households.append({
            'household_id': household_id,
            'grouping_id': grouping_id,
        })
        
        if i % 300 == 0:
            print_progress(i, DATA_VOLUMES['households'], 'Households')
    
    print_progress(DATA_VOLUMES['households'], DATA_VOLUMES['households'], 'Households')
    
    # 4. Generate Professional Groups
    print("\n\n4. Generating Professional Groups...")
    for i in range(1, DATA_VOLUMES['professional_groups'] + 1):
        party_id = id_gen.next_id('party')
        grouping_id = id_gen.next_id('grouping')
        
        group_name = f"{fake.company()} Group"
        begin_date = random_date(
            datetime(2000, 1, 1),
            datetime(2020, 1, 1)
        )
        
        # Party record
        parties.append({
            'party_id': party_id,
            'party_name': group_name,
            'party_type_code': 'GROUPING',
            'begin_date': begin_date,
            'end_date': None,
        })
        
        # Grouping record
        groupings.append({
            'grouping_id': grouping_id,
            'party_id': party_id,
            'grouping_name': group_name,
        })
        
        if i % 10 == 0:
            print_progress(i, DATA_VOLUMES['professional_groups'], 'Professional Groups')
    
    print_progress(DATA_VOLUMES['professional_groups'], DATA_VOLUMES['professional_groups'], 
                   'Professional Groups')
    
    # Save to tables
    print("\n\nSaving to Databricks tables...")
    
    df_party = create_dataframe(parties, 
                                ['party_id', 'party_name', 'party_type_code', 
                                 'begin_date', 'end_date'])
    save_to_table(spark, df_party, 'party', catalog, schema)
    
    df_person = create_dataframe(persons,
                                 ['person_id', 'party_id', 'prefix_name', 'first_name',
                                  'middle_name', 'last_name', 'suffix_name', 'full_legal_name',
                                  'nickname', 'birth_date', 'birth_place_name', 'gender_code'])
    save_to_table(spark, df_person, 'person', catalog, schema)
    
    df_org = create_dataframe(organizations,
                              ['organization_id', 'party_id', 'organization_type_code',
                               'organization_name', 'alternate_name', 'acronym_name',
                               'industry_type_code', 'industry_code', 'dun_and_bradstreet_id',
                               'organization_description'])
    save_to_table(spark, df_org, 'organization', catalog, schema)
    
    df_grouping = create_dataframe(groupings,
                                   ['grouping_id', 'party_id', 'grouping_name'])
    save_to_table(spark, df_grouping, 'grouping', catalog, schema)
    
    df_household = create_dataframe(households,
                                    ['household_id', 'grouping_id'])
    save_to_table(spark, df_household, 'household', catalog, schema)
    
    print("\n" + "=" * 60)
    print("Party Data Generation Complete!")
    print(f"  Parties: {len(parties)}")
    print(f"  Persons: {len(persons)}")
    print(f"  Organizations: {len(organizations)}")
    print(f"  Groupings: {len(groupings)}")
    print(f"  Households: {len(households)}")
    print("=" * 60)

# COMMAND ----------

if __name__ == "__main__":
    spark = SparkSession.builder \
        .appName("PCDM Party Data Generator") \
        .getOrCreate()
    
    try:
        generate_party_data(spark)
    except Exception as e:
        print(f"\nError: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        spark.stop()
