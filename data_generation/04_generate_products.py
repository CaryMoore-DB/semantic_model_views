"""
04 - Generate Product Data for PCDM
Creates: line_of_business, product, company
"""
import sys
from pyspark.sql import SparkSession
from config import *
from utils import *

def generate_product_data(spark):
    """Generate product and line of business data"""
    catalog = DATABASE_CONFIG['catalog']
    schema = DATABASE_CONFIG['schema']
    
    print("=" * 60)
    print("Generating Product Data")
    print("=" * 60)
    
    lines_of_business = []
    products = []
    companies = []
    
    # 1. Generate Lines of Business
    print("\n1. Generating Lines of Business...")
    for i, (lob_name, lob_group, lob_desc) in enumerate(LINES_OF_BUSINESS, 1):
        # Map to LOB group
        if lob_group == 'Personal Lines':
            lob_group_id = 1
            insurance_class_id = 1
        elif lob_group == 'Commercial Lines':
            lob_group_id = 2
            insurance_class_id = 2
        else:
            lob_group_id = 3
            insurance_class_id = 3
        
        lines_of_business.append({
            'line_of_business_id': i,
            'line_of_business_name': lob_name,
            'line_of_business_description': lob_desc,
            'line_of_business_code': i * 100,
            'line_of_business_group_id': lob_group_id,
            'insurance_class_id': insurance_class_id,
        })
    
    print(f"✓ Generated {len(lines_of_business)} lines of business")
    
    # 2. Generate Companies
    print("\n2. Generating Companies...")
    company_names = [
        "State Auto Insurance",
        "American Family Insurance",
        "Liberty Mutual",
        "Travelers Insurance",
        "Nationwide Insurance",
        "Progressive Insurance",
        "GEICO",
        "Allstate Insurance",
        "Farmers Insurance",
        "USAA",
    ]
    
    for i, company_name in enumerate(company_names, 1):
        companies.append({
            'company_id': i,
            'company_code': i * 1000,
            'company_name': company_name,
            'company_description': f"{company_name} Company",
        })
    
    print(f"✓ Generated {len(companies)} companies")
    
    # 3. Generate Products
    print("\n3. Generating Products...")
    product_templates = {
        'Personal Auto': ['Standard Auto', 'Preferred Auto', 'Non-Standard Auto'],
        'Homeowners': ['HO-3 Special Form', 'HO-5 Comprehensive', 'HO-6 Condo'],
        'Commercial Auto': ['Business Auto', 'Commercial Truck', 'Fleet Auto'],
        'Commercial Property': ['BOP', 'Commercial Building', 'Business Property'],
        'Workers Compensation': ['Standard WC', 'WC w/ Deductible', 'Large Deductible WC'],
        'General Liability': ['Standard GL', 'GL w/ Products', 'Contractors GL'],
    }
    
    product_id = 1
    for lob_id, lob_name, lob_desc in LINES_OF_BUSINESS:
        # Get product templates for this LOB
        if lob_name in product_templates:
            templates = product_templates[lob_name]
        else:
            templates = ['Standard', 'Enhanced']
        
        for template in templates:
            products.append({
                'product_id': product_id,
                'line_of_business_id': lob_id,
                'licensed_product_name': f"{lob_name} - {template}",
                'product_description': f"{template} product for {lob_name}",
            })
            product_id += 1
    
    print(f"✓ Generated {len(products)} products")
    
    # Save to tables
    print("\n\nSaving to Databricks tables...")
    
    df_lob = create_dataframe(lines_of_business,
                              ['line_of_business_id', 'line_of_business_name',
                               'line_of_business_description', 'line_of_business_code',
                               'line_of_business_group_id', 'insurance_class_id'])
    save_to_table(spark, df_lob, 'line_of_business', catalog, schema)
    
    df_company = create_dataframe(companies,
                                  ['company_id', 'company_code', 'company_name',
                                   'company_description'])
    save_to_table(spark, df_company, 'company', catalog, schema)
    
    df_product = create_dataframe(products,
                                  ['product_id', 'line_of_business_id',
                                   'licensed_product_name', 'product_description'])
    save_to_table(spark, df_product, 'product', catalog, schema)
    
    print("\n" + "=" * 60)
    print("Product Data Generation Complete!")
    print(f"  Lines of Business: {len(lines_of_business)}")
    print(f"  Companies: {len(companies)}")
    print(f"  Products: {len(products)}")
    print("=" * 60)


if __name__ == "__main__":
    spark = SparkSession.builder \
        .appName("PCDM Product Data Generator") \
        .getOrCreate()
    
    try:
        generate_product_data(spark)
    except Exception as e:
        print(f"\nError: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        spark.stop()
