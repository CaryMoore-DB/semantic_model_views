# Databricks notebook source

# COMMAND ----------

"""
03 - Generate Geographic Location Data for PCDM
Creates: location_address, geographic_location
"""

# COMMAND ----------

from pyspark.sql import SparkSession
from config import *
from utils import *

# COMMAND ----------

def generate_location_data(spark):
    """Generate location address and geographic location data"""
    catalog = DATABASE_CONFIG['catalog']
    schema = DATABASE_CONFIG['schema']
    
    print("=" * 60)
    print("Generating Location Data")
    print("=" * 60)
    
    # Load states
    states_df = spark.table(f"{catalog}.{schema}.state")
    states = [(row.state_code, row.state_name) for row in states_df.collect()]
    
    location_addresses = []
    geographic_locations = []
    
    # 1. Generate Location Addresses
    print("\n1. Generating Location Addresses...")
    for i in range(1, DATA_VOLUMES['location_addresses'] + 1):
        location_address_id = id_gen.next_id('location_address')
        state_code, state_name = random.choice(states)
        
        location_addresses.append({
            'location_address_id': location_address_id,
            'line_1_address': fake.street_address(),
            'line_2_address': fake.secondary_address() if random.random() < 0.3 else None,
            'municipality_name': fake.city(),
            'state_code': state_code,
            'postal_code': fake.zipcode(),
            'country_code': 'US',
        })
        
        if i % 500 == 0:
            print_progress(i, DATA_VOLUMES['location_addresses'], 'Location Addresses')
    
    print_progress(DATA_VOLUMES['location_addresses'], DATA_VOLUMES['location_addresses'], 
                   'Location Addresses')
    
    # 2. Generate Geographic Locations
    print("\n\n2. Generating Geographic Locations...")
    for i in range(1, DATA_VOLUMES['geographic_locations'] + 1):
        geographic_location_id = id_gen.next_id('geographic_location')
        state_code, state_name = random.choice(states)
        
        # Link to a location address
        location_address = random.choice(location_addresses)
        
        geographic_locations.append({
            'geographic_location_id': geographic_location_id,
            'geographic_location_type_code': random.choice(['RISK', 'PROPERTY', 'OCCURRENCE', 'OFFICE']),
            'location_code': f"LOC{geographic_location_id:06d}",
            'location_name': f"{fake.city()}, {state_code}",
            'location_number': str(geographic_location_id),
            'state_code': state_code,
            'location_address_id': location_address['location_address_id'],
        })
        
        if i % 500 == 0:
            print_progress(i, DATA_VOLUMES['geographic_locations'], 'Geographic Locations')
    
    print_progress(DATA_VOLUMES['geographic_locations'], DATA_VOLUMES['geographic_locations'], 
                   'Geographic Locations')
    
    # Save to tables
    print("\n\nSaving to Databricks tables...")
    
    df_location_address = create_dataframe(location_addresses,
                                           ['location_address_id', 'line_1_address', 'line_2_address',
                                            'municipality_name', 'state_code', 'postal_code', 'country_code'])
    save_to_table(spark, df_location_address, 'location_address', catalog, schema)
    
    df_geographic_location = create_dataframe(geographic_locations,
                                              ['geographic_location_id', 'geographic_location_type_code',
                                               'location_code', 'location_name', 'location_number',
                                               'state_code', 'location_address_id'])
    save_to_table(spark, df_geographic_location, 'geographic_location', catalog, schema)
    
    print("\n" + "=" * 60)
    print("Location Data Generation Complete!")
    print(f"  Location Addresses: {len(location_addresses)}")
    print(f"  Geographic Locations: {len(geographic_locations)}")
    print("=" * 60)

# COMMAND ----------

# Execute the function (Databricks manages the Spark session)
generate_location_data(spark)
