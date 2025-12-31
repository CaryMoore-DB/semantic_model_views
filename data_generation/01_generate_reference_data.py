"""
01 - Generate Reference Data for PCDM
Creates: states, party_roles, coverage_types, coverage_parts, coverage_groups
"""
import sys
from pyspark.sql import SparkSession
from config import *
from utils import *

def generate_reference_data(spark):
    """Generate all reference/lookup data"""
    catalog = DATABASE_CONFIG['catalog']
    schema = DATABASE_CONFIG['schema']
    
    print("=" * 60)
    print("Generating Reference Data")
    print("=" * 60)
    
    # 1. States
    print("\n1. Generating States...")
    states_data = []
    for state_code, state_name in US_STATES:
        states_data.append({
            'state_code': state_code,
            'state_name': state_name,
        })
    
    df_states = create_dataframe(states_data, ['state_code', 'state_name'])
    save_to_table(spark, df_states, 'state', catalog, schema)
    
    # 2. Party Roles
    print("\n2. Generating Party Roles...")
    party_roles_data = []
    for role_code, role_name, role_desc in PARTY_ROLES:
        party_roles_data.append({
            'party_role_code': role_code,
            'party_role_name': role_name,
            'party_role_description': role_desc,
        })
    
    df_party_roles = create_dataframe(party_roles_data, 
                                       ['party_role_code', 'party_role_name', 'party_role_description'])
    save_to_table(spark, df_party_roles, 'party_role', catalog, schema)
    
    # 3. Coverage Parts
    print("\n3. Generating Coverage Parts...")
    coverage_parts_data = []
    coverage_part_names = ['Auto', 'Property', 'Liability', 'Medical', 'Professional',
                          'Cyber', 'Crime', 'Inland Marine', 'Ocean Marine', 'Workers Comp']
    
    for i, name in enumerate(coverage_part_names, 1):
        coverage_parts_data.append({
            'coverage_part_code': i,
            'coverage_part_name': name,
        })
    
    df_coverage_parts = create_dataframe(coverage_parts_data, 
                                          ['coverage_part_code', 'coverage_part_name'])
    save_to_table(spark, df_coverage_parts, 'coverage_part', catalog, schema)
    
    # 4. Coverage Groups
    print("\n4. Generating Coverage Groups...")
    coverage_groups_data = []
    coverage_group_names = [
        ('First Party', 'Coverage for insured\'s own property/injuries'),
        ('Third Party', 'Coverage for others\' property/injuries'),
        ('Excess', 'Excess/umbrella coverage'),
        ('Package', 'Package policy coverage'),
    ]
    
    for i, (name, desc) in enumerate(coverage_group_names, 1):
        coverage_groups_data.append({
            'coverage_group_id': i,
            'coverage_group_name': name,
            'coverage_group_description': desc,
        })
    
    df_coverage_groups = create_dataframe(coverage_groups_data,
                                           ['coverage_group_id', 'coverage_group_name', 
                                            'coverage_group_description'])
    save_to_table(spark, df_coverage_groups, 'coverage_group', catalog, schema)
    
    # 5. Coverage Types
    print("\n5. Generating Coverage Types...")
    coverage_types_data = []
    for i, (name, part, desc) in enumerate(COVERAGE_TYPES, 1):
        coverage_types_data.append({
            'coverage_type_id': i,
            'coverage_type_name': name,
            'coverage_type_description': desc,
        })
    
    df_coverage_types = create_dataframe(coverage_types_data,
                                          ['coverage_type_id', 'coverage_type_name', 
                                           'coverage_type_description'])
    save_to_table(spark, df_coverage_types, 'coverage_type', catalog, schema)
    
    # 6. Coverage Limit Types
    print("\n6. Generating Coverage Limit Types...")
    limit_types_data = [
        (1, 'Per Occurrence', 'Limit per occurrence'),
        (2, 'Per Person', 'Limit per person'),
        (3, 'Aggregate', 'Aggregate limit'),
        (4, 'Per Claim', 'Limit per claim'),
        (5, 'Annual', 'Annual aggregate limit'),
    ]
    
    coverage_limit_types_data = []
    for limit_id, name, desc in limit_types_data:
        coverage_limit_types_data.append({
            'coverage_limit_type_id': limit_id,
            'coverage_limit_name': name,
            'coverage_limit_description': desc,
        })
    
    df_limit_types = create_dataframe(coverage_limit_types_data,
                                       ['coverage_limit_type_id', 'coverage_limit_name',
                                        'coverage_limit_description'])
    save_to_table(spark, df_limit_types, 'coverage_limit_type', catalog, schema)
    
    # 7. Coverage (combining coverage types with parts and groups)
    print("\n7. Generating Coverages...")
    coverages_data = []
    for i, (name, part, desc) in enumerate(COVERAGE_TYPES, 1):
        # Map coverage part name to coverage_part_code
        part_code = coverage_part_names.index(part) + 1 if part in coverage_part_names else 1
        # Assign coverage group (simplified)
        group_id = 1 if 'Liability' not in name else 2
        
        coverages_data.append({
            'coverage_id': i,
            'coverage_part_code': part_code,
            'coverage_type_id': i,
            'coverage_name': name,
            'coverage_description': desc,
            'coverage_group_id': group_id,
        })
    
    df_coverages = create_dataframe(coverages_data,
                                     ['coverage_id', 'coverage_part_code', 'coverage_type_id',
                                      'coverage_name', 'coverage_description', 'coverage_group_id'])
    save_to_table(spark, df_coverages, 'coverage', catalog, schema)
    
    # 8. Insurance Classes
    print("\n8. Generating Insurance Classes...")
    insurance_classes_data = [
        (1, 'Personal Lines', 'Individual/family insurance'),
        (2, 'Commercial Lines', 'Business insurance'),
        (3, 'Specialty Lines', 'Specialty insurance products'),
    ]
    
    classes_data = []
    for class_id, name, desc in insurance_classes_data:
        classes_data.append({
            'insurance_class_id': class_id,
            'insurance_class_name': name,
            'insurance_class_description': desc,
        })
    
    df_classes = create_dataframe(classes_data,
                                   ['insurance_class_id', 'insurance_class_name',
                                    'insurance_class_description'])
    save_to_table(spark, df_classes, 'insurance_class', catalog, schema)
    
    # 9. Line of Business Groups
    print("\n9. Generating Line of Business Groups...")
    lob_groups_data = [
        (1, 'Personal Lines', 'Personal insurance products'),
        (2, 'Commercial Lines', 'Commercial insurance products'),
        (3, 'Specialty Lines', 'Specialty insurance products'),
    ]
    
    lob_groups = []
    for group_id, name, desc in lob_groups_data:
        lob_groups.append({
            'line_of_business_group_id': group_id,
            'line_of_business_group_name': name,
            'line_of_business_group_description': desc,
        })
    
    df_lob_groups = create_dataframe(lob_groups,
                                      ['line_of_business_group_id', 'line_of_business_group_name',
                                       'line_of_business_group_description'])
    save_to_table(spark, df_lob_groups, 'line_of_business_group', catalog, schema)
    
    # 10. Staff Classifications
    print("\n10. Generating Staff Classifications...")
    staff_class_data = [
        (1, 'Underwriter', 'Underwriting staff'),
        (2, 'Claims Adjuster', 'Claims handling staff'),
        (3, 'Agent', 'Agent/broker'),
        (4, 'Manager', 'Management staff'),
    ]
    
    staff_classes = []
    for code, name, desc in staff_class_data:
        staff_classes.append({
            'staff_classification_code': code,
            'staff_classification_name': name,
            'staff_classification_description': desc,
        })
    
    df_staff = create_dataframe(staff_classes,
                                 ['staff_classification_code', 'staff_classification_name',
                                  'staff_classification_description'])
    save_to_table(spark, df_staff, 'staff_classification', catalog, schema)
    
    print("\n" + "=" * 60)
    print("Reference Data Generation Complete!")
    print("=" * 60)


if __name__ == "__main__":
    spark = SparkSession.builder \
        .appName("PCDM Reference Data Generator") \
        .getOrCreate()
    
    try:
        generate_reference_data(spark)
    except Exception as e:
        print(f"\nError: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        spark.stop()
