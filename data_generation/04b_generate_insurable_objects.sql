# Databricks notebook source

# COMMAND ----------

"""
04b - Generate Insurable Objects for PCDM
Creates: insurable_object, vehicle, structure, commercial_structure, residential_structure
Links policy_coverage_detail to insurable objects
"""

# COMMAND ----------

from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, IntegerType, StringType, DateType
from config import *
from utils import *
import random

# COMMAND ----------

def generate_insurable_objects(spark):
    """Generate insurable objects (vehicles and structures) and link to policy coverage"""
    catalog = DATABASE_CONFIG['catalog']
    schema = DATABASE_CONFIG['schema']
    
    print("=" * 60)
    print("Generating Insurable Objects")
    print("=" * 60)
    
    # Load existing data
    print("\nLoading existing data...")
    df_pcd = spark.read.table(f"{catalog}.{schema}.policy_coverage_detail")
    df_coverage = spark.read.table(f"{catalog}.{schema}.coverage")
    df_geo_loc = spark.read.table(f"{catalog}.{schema}.geographic_location")
    
    # Get data
    pcd_records = df_pcd.select("policy_coverage_detail_id", "coverage_id", "effective_date").collect()
    coverage_dict = {row.coverage_id: row.coverage_name for row in df_coverage.collect()}
    geo_locations = [row.geographic_location_id for row in df_geo_loc.collect()]
    
    print(f"Found {len(pcd_records)} policy coverage details")
    print(f"Found {len(coverage_dict)} coverage types")
    print(f"Found {len(geo_locations)} geographic locations")
    
    insurable_objects = []
    vehicles = []
    structures = []
    commercial_structures = []
    residential_structures = []
    pcd_updates = []  # To update policy_coverage_detail with insurable_object_id
    
    # 1. Generate insurable objects for relevant coverages
    print("\n1. Generating insurable objects...")
    
    for pcd in pcd_records:
        pcd_id = pcd.policy_coverage_detail_id
        coverage_id = pcd.coverage_id
        coverage_name = coverage_dict.get(coverage_id, '')
        effective_date = pcd.effective_date
        
        insurable_object_id = None
        
        # Determine if this coverage needs an insurable object
        if 'Auto' in coverage_name or 'Vehicle' in coverage_name or 'Collision' in coverage_name or 'Comprehensive' in coverage_name:
            # Create a vehicle
            insurable_object_id = id_gen.next_id('insurable_object')
            vehicle_id = id_gen.next_id('vehicle')
            
            geo_loc_id = random.choice(geo_locations)
            
            insurable_objects.append({
                'insurable_object_id': insurable_object_id,
                'insurable_object_type_code': 'VEHICLE',
                'geographic_location_id': geo_loc_id
            })
            
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
            
        elif 'Property' in coverage_name or 'Dwelling' in coverage_name or 'Building' in coverage_name:
            # Create a structure
            insurable_object_id = id_gen.next_id('insurable_object')
            structure_id = id_gen.next_id('structure')
            
            geo_loc_id = random.choice(geo_locations)
            
            insurable_objects.append({
                'insurable_object_id': insurable_object_id,
                'insurable_object_type_code': 'STRUCTURE',
                'geographic_location_id': geo_loc_id
            })
            
            structures.append({
                'structure_id': structure_id,
                'insurable_object_id': insurable_object_id,
                'structure_type_code': random.choice(['SINGLE_FAMILY', 'MULTI_FAMILY', 'COMMERCIAL']),
            })
            
            # Determine if commercial or residential
            if 'Commercial' in coverage_name:
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
        
        # Track update for policy_coverage_detail
        if insurable_object_id:
            pcd_updates.append({
                'policy_coverage_detail_id': pcd_id,
                'insurable_object_id': insurable_object_id
            })
    
    # 2. Save tables
    print(f"\n2. Saving insurable_object table ({len(insurable_objects)} records)...")
    if insurable_objects:
        schema_insurable_object = StructType([
            StructField("insurable_object_id", IntegerType(), False),
            StructField("insurable_object_type_code", StringType(), True),
            StructField("geographic_location_id", IntegerType(), True)
        ])
        df_insurable_object = spark.createDataFrame(insurable_objects, schema=schema_insurable_object)
        df_insurable_object.write.mode("overwrite").saveAsTable(f"{catalog}.{schema}.insurable_object")
        print(f"   ✓ Saved {len(insurable_objects)} insurable objects")
    
    print(f"\n3. Saving vehicle table ({len(vehicles)} records)...")
    if vehicles:
        schema_vehicle = StructType([
            StructField("vehicle_id", IntegerType(), False),
            StructField("insurable_object_id", IntegerType(), True),
            StructField("vehicle_make_name", StringType(), True),
            StructField("vehicle_model_name", StringType(), True),
            StructField("vehicle_model_year", IntegerType(), True),
            StructField("vehicle_identification_number", StringType(), True),
            StructField("vehicle_type_code", StringType(), True)
        ])
        df_vehicle = spark.createDataFrame(vehicles, schema=schema_vehicle)
        df_vehicle.write.mode("overwrite").saveAsTable(f"{catalog}.{schema}.vehicle")
        print(f"   ✓ Saved {len(vehicles)} vehicles")
    
    print(f"\n4. Saving structure table ({len(structures)} records)...")
    if structures:
        schema_structure = StructType([
            StructField("structure_id", IntegerType(), False),
            StructField("insurable_object_id", IntegerType(), True),
            StructField("structure_type_code", StringType(), True)
        ])
        df_structure = spark.createDataFrame(structures, schema=schema_structure)
        df_structure.write.mode("overwrite").saveAsTable(f"{catalog}.{schema}.structure")
        print(f"   ✓ Saved {len(structures)} structures")
    
    print(f"\n5. Saving commercial_structure table ({len(commercial_structures)} records)...")
    if commercial_structures:
        schema_commercial_structure = StructType([
            StructField("commercial_structure_id", IntegerType(), False),
            StructField("structure_id", IntegerType(), True),
            StructField("business_type_code", StringType(), True)
        ])
        df_commercial_structure = spark.createDataFrame(commercial_structures, schema=schema_commercial_structure)
        df_commercial_structure.write.mode("overwrite").saveAsTable(f"{catalog}.{schema}.commercial_structure")
        print(f"   ✓ Saved {len(commercial_structures)} commercial structures")
    
    print(f"\n6. Saving residential_structure table ({len(residential_structures)} records)...")
    if residential_structures:
        schema_residential_structure = StructType([
            StructField("residential_structure_id", IntegerType(), False),
            StructField("structure_id", IntegerType(), True),
            StructField("occupancy_type_code", StringType(), True)
        ])
        df_residential_structure = spark.createDataFrame(residential_structures, schema=schema_residential_structure)
        df_residential_structure.write.mode("overwrite").saveAsTable(f"{catalog}.{schema}.residential_structure")
        print(f"   ✓ Saved {len(residential_structures)} residential structures")
    
    # 7. Update policy_coverage_detail with insurable_object_id
    print(f"\n7. Updating policy_coverage_detail with insurable_object_id ({len(pcd_updates)} records)...")
    if pcd_updates:
        # Create a temp table with updates
        schema_pcd_update = StructType([
            StructField("policy_coverage_detail_id", IntegerType(), False),
            StructField("insurable_object_id", IntegerType(), True)
        ])
        df_pcd_updates = spark.createDataFrame(pcd_updates, schema=schema_pcd_update)
        df_pcd_updates.createOrReplaceTempView("pcd_updates_temp")
        
        # Merge updates back to policy_coverage_detail
        spark.sql(f"""
            MERGE INTO {catalog}.{schema}.policy_coverage_detail AS target
            USING pcd_updates_temp AS source
            ON target.policy_coverage_detail_id = source.policy_coverage_detail_id
            WHEN MATCHED THEN UPDATE SET
                target.insurable_object_id = source.insurable_object_id
        """)
        print(f"   ✓ Updated {len(pcd_updates)} policy coverage details")
    
    print("\n" + "=" * 60)
    print("Insurable Objects Generation Complete!")
    print(f"  Insurable Objects: {len(insurable_objects)}")
    print(f"  Vehicles: {len(vehicles)}")
    print(f"  Structures: {len(structures)}")
    print(f"  Commercial Structures: {len(commercial_structures)}")
    print(f"  Residential Structures: {len(residential_structures)}")
    print("=" * 60)

# COMMAND ----------

# Run the generation
spark = SparkSession.builder.getOrCreate()
generate_insurable_objects(spark)

print("\n✓ Insurable objects generation complete")
