# Databricks notebook source

# COMMAND ----------

"""
02b - Generate Party Relationship Data for PCDM
Creates: party_relationship linking policy holders to groups
"""

# COMMAND ----------

from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, IntegerType, StringType, DateType
from config import *
from utils import save_to_table_with_schema, random_date, id_gen
import random

# COMMAND ----------

def generate_party_relationships(spark):
    """Generate party relationships - primarily linking persons to group organizations"""
    catalog = DATABASE_CONFIG['catalog']
    schema = DATABASE_CONFIG['schema']
    
    print("=" * 60)
    print("Generating Party Relationship Data")
    print("=" * 60)
    
    # Load existing parties to get persons and groupings
    df_party = spark.read.table(f"{catalog}.{schema}.party")
    df_grouping = spark.read.table(f"{catalog}.{schema}.grouping")
    
    # Get person parties (potential group members)
    person_parties = df_party.filter("party_type_code = 'PERSON'").select("party_id").collect()
    person_party_ids = [row.party_id for row in person_parties]
    
    # Get grouping parties (groups that persons can belong to)
    grouping_records = df_grouping.select("party_id").collect()
    grouping_party_ids = [row.party_id for row in grouping_records]
    
    print(f"\nFound {len(person_party_ids)} person parties")
    print(f"Found {len(grouping_party_ids)} grouping parties")
    
    party_relationships = []
    
    # Decide how many persons should be in groups (e.g., 30% of persons)
    num_persons_in_groups = int(len(person_party_ids) * DATA_VOLUMES['party_relationship_percentage'])
    
    print(f"\nAssigning {num_persons_in_groups} persons to groups...")
    
    # Randomly assign persons to groups
    selected_persons = random.sample(person_party_ids, num_persons_in_groups)
    
    for person_id in selected_persons:
        # Randomly select a group for this person
        group_id = random.choice(grouping_party_ids)
        
        rel_id = id_gen.next_id('party_relationship')
        
        party_relationships.append({
            'party_relationship_id': rel_id,
            'party_id': person_id,  # Person who is member
            'related_party_id': group_id,  # Group they belong to
            'relationship_type_code': 'MEMBER_OF',  # Person is member of group
            'begin_date': random_date(
                DATE_RANGES['policy_start_date'].date(),
                DATE_RANGES['policy_end_date'].date()
            ),
            'end_date': None  # Active relationship
        })
    
    # 2. Save party_relationship table
    print(f"\n2. Saving party_relationship table ({len(party_relationships)} records)...")
    
    # Define explicit schema to avoid type inference issues
    schema_party_relationship = StructType([
        StructField("party_relationship_id", IntegerType(), False),
        StructField("party_id", IntegerType(), True),
        StructField("related_party_id", IntegerType(), True),
        StructField("relationship_type_code", StringType(), True),
        StructField("begin_date", DateType(), True),
        StructField("end_date", DateType(), True)
    ])
    
    save_to_table_with_schema(spark, party_relationships, 'party_relationship', catalog, schema, schema_party_relationship)
    
    print("\n" + "=" * 60)
    print("Party Relationship Generation Complete!")
    print("=" * 60)

# COMMAND ----------

# Run the generation
spark = SparkSession.builder.getOrCreate()
generate_party_relationships(spark)

print("\n✓ Party relationship generation complete")
