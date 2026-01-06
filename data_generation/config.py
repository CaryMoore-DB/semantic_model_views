# Databricks notebook source
"""
Configuration for PCDM Fake Data Generation
"""
from datetime import datetime, timedelta

# Database Configuration
DATABASE_CONFIG = {
    'catalog': 'main',
    'schema': 'pcdm_test',  # Change to your target schema
}

# Data Volume Configuration
DATA_VOLUMES = {
    # Reference data
    'states': 50,
    'coverage_types': 20,
    'coverage_parts': 10,
    'party_roles': 25,
    
    # Party data
    'persons': 5000,
    'organizations': 500,
    'households': 1500,
    'professional_groups': 50,
    
    # Products
    'line_of_business_groups': 5,
    'lines_of_business': 15,
    'products': 30,
    'companies': 10,
    
    # Policies
    'policies': 10000,
    'avg_coverages_per_policy': 3,
    
    # Risks
    'vehicles': 7000,
    'structures': 5000,
    'farm_equipment': 500,
    'workers_comp': 1000,
    
    # Claims
    'occurrences': 3000,
    'catastrophes': 10,
    'claims': 2500,
    'claims_with_litigation': 250,  # 10% of claims
    'claims_with_arbitration': 125,  # 5% of claims
    
    # Attorneys
    'attorneys': 100,
    'law_firms': 30,
    'courts': 50,
}

# Date Ranges
DATE_RANGES = {
    'policy_start_date': datetime(2020, 1, 1),
    'policy_end_date': datetime(2025, 12, 31),
    'occurrence_start_date': datetime(2020, 1, 1),
    'occurrence_end_date': datetime.now(),
    'policy_term_days_min': 180,
    'policy_term_days_max': 365,
}

# Business Rules
BUSINESS_RULES = {
    # Probability of claim given occurrence
    'claim_probability': 0.80,
    
    # Probability of claim having litigation
    'litigation_probability': 0.10,
    
    # Probability of claim having arbitration
    'arbitration_probability': 0.05,
    
    # Probability of catastrophe
    'catastrophe_probability': 0.05,
    
    # Average claim amounts by severity
    'claim_severity': {
        'low': {'min': 500, 'max': 5000},
        'medium': {'min': 5000, 'max': 50000},
        'high': {'min': 50000, 'max': 500000},
        'severe': {'min': 500000, 'max': 5000000},
    },
    
    # Premium ranges by line of business
    'premium_ranges': {
        'Personal Auto': {'min': 500, 'max': 3000},
        'Homeowners': {'min': 800, 'max': 5000},
        'Commercial Auto': {'min': 2000, 'max': 20000},
        'Commercial Property': {'min': 5000, 'max': 100000},
        'Workers Compensation': {'min': 3000, 'max': 50000},
        'General Liability': {'min': 1000, 'max': 25000},
    },
    
    # Claim closure probability by days open
    'claim_closure_probability': {
        30: 0.20,
        60: 0.40,
        90: 0.60,
        180: 0.80,
        365: 0.95,
    },
}

# State Data (US States)
US_STATES = [
    ('AL', 'Alabama'), ('AK', 'Alaska'), ('AZ', 'Arizona'), ('AR', 'Arkansas'),
    ('CA', 'California'), ('CO', 'Colorado'), ('CT', 'Connecticut'), ('DE', 'Delaware'),
    ('FL', 'Florida'), ('GA', 'Georgia'), ('HI', 'Hawaii'), ('ID', 'Idaho'),
    ('IL', 'Illinois'), ('IN', 'Indiana'), ('IA', 'Iowa'), ('KS', 'Kansas'),
    ('KY', 'Kentucky'), ('LA', 'Louisiana'), ('ME', 'Maine'), ('MD', 'Maryland'),
    ('MA', 'Massachusetts'), ('MI', 'Michigan'), ('MN', 'Minnesota'), ('MS', 'Mississippi'),
    ('MO', 'Missouri'), ('MT', 'Montana'), ('NE', 'Nebraska'), ('NV', 'Nevada'),
    ('NH', 'New Hampshire'), ('NJ', 'New Jersey'), ('NM', 'New Mexico'), ('NY', 'New York'),
    ('NC', 'North Carolina'), ('ND', 'North Dakota'), ('OH', 'Ohio'), ('OK', 'Oklahoma'),
    ('OR', 'Oregon'), ('PA', 'Pennsylvania'), ('RI', 'Rhode Island'), ('SC', 'South Carolina'),
    ('SD', 'South Dakota'), ('TN', 'Tennessee'), ('TX', 'Texas'), ('UT', 'Utah'),
    ('VT', 'Vermont'), ('VA', 'Virginia'), ('WA', 'Washington'), ('WV', 'West Virginia'),
    ('WI', 'Wisconsin'), ('WY', 'Wyoming'),
]

# Lines of Business
LINES_OF_BUSINESS = [
    ('Personal Auto', 'Personal Lines', 'Standard personal automobile insurance'),
    ('Homeowners', 'Personal Lines', 'Standard homeowners insurance'),
    ('Renters', 'Personal Lines', 'Renters insurance'),
    ('Personal Umbrella', 'Personal Lines', 'Personal excess liability'),
    ('Motorcycle', 'Personal Lines', 'Motorcycle insurance'),
    ('Boat', 'Personal Lines', 'Watercraft insurance'),
    ('RV', 'Personal Lines', 'Recreational vehicle insurance'),
    ('Commercial Auto', 'Commercial Lines', 'Commercial automobile insurance'),
    ('Commercial Property', 'Commercial Lines', 'Commercial property insurance'),
    ('General Liability', 'Commercial Lines', 'Commercial general liability'),
    ('Workers Compensation', 'Commercial Lines', 'Workers compensation insurance'),
    ('Commercial Umbrella', 'Commercial Lines', 'Commercial excess liability'),
    ('Professional Liability', 'Commercial Lines', 'Errors and omissions insurance'),
    ('Cyber Liability', 'Commercial Lines', 'Cyber insurance'),
    ('Product Liability', 'Commercial Lines', 'Product liability insurance'),
]

# Coverage Types
COVERAGE_TYPES = [
    # Auto coverages
    ('Bodily Injury Liability', 'Auto', 'Coverage for injuries to others'),
    ('Property Damage Liability', 'Auto', 'Coverage for damage to others property'),
    ('Collision', 'Auto', 'Coverage for vehicle collision damage'),
    ('Comprehensive', 'Auto', 'Coverage for non-collision damage'),
    ('Medical Payments', 'Auto', 'Coverage for medical expenses'),
    ('Uninsured Motorist', 'Auto', 'Coverage for uninsured/underinsured motorists'),
    ('Personal Injury Protection', 'Auto', 'No-fault medical coverage'),
    
    # Property coverages
    ('Dwelling', 'Property', 'Coverage for dwelling structure'),
    ('Other Structures', 'Property', 'Coverage for detached structures'),
    ('Personal Property', 'Property', 'Coverage for contents'),
    ('Loss of Use', 'Property', 'Additional living expenses'),
    ('Personal Liability', 'Property', 'Personal liability coverage'),
    ('Medical Payments to Others', 'Property', 'Guest medical payments'),
    
    # Commercial coverages
    ('Building', 'Commercial Property', 'Commercial building coverage'),
    ('Business Personal Property', 'Commercial Property', 'Commercial contents coverage'),
    ('Business Income', 'Commercial Property', 'Income loss coverage'),
    ('General Aggregate', 'General Liability', 'Aggregate liability limit'),
    ('Products/Completed Operations', 'General Liability', 'Product liability'),
    ('Professional Services', 'Professional Liability', 'E&O coverage'),
    ('Cyber Coverage', 'Cyber', 'Data breach and cyber coverage'),
]

# Party Roles
PARTY_ROLES = [
    ('INSURED', 'Insured', 'Primary insured party'),
    ('POLICYHOLDER', 'Policy Holder', 'Policy owner'),
    ('AGENT', 'Agent', 'Insurance agent'),
    ('BROKER', 'Broker', 'Insurance broker'),
    ('CLAIMANT', 'Claimant', 'Person making a claim'),
    ('ATTORNEY', 'Attorney', 'Legal representative'),
    ('ADJUSTER', 'Adjuster', 'Claims adjuster'),
    ('WITNESS', 'Witness', 'Claim witness'),
    ('GROUP', 'Group', 'Group policy holder'),
    ('EMPLOYEE', 'Employee', 'Employee for workers comp'),
]

# Vehicle Makes (sample)
VEHICLE_MAKES = [
    'Toyota', 'Honda', 'Ford', 'Chevrolet', 'Nissan', 'Jeep', 'RAM',
    'GMC', 'Subaru', 'Hyundai', 'Kia', 'Mazda', 'Volkswagen', 'BMW',
    'Mercedes-Benz', 'Audi', 'Lexus', 'Tesla', 'Volvo', 'Dodge'
]

# Catastrophe Types
CATASTROPHE_TYPES = [
    ('HURRICANE', 'Hurricane'),
    ('TORNADO', 'Tornado'),
    ('HAIL', 'Hail Storm'),
    ('FLOOD', 'Flood'),
    ('WILDFIRE', 'Wildfire'),
    ('EARTHQUAKE', 'Earthquake'),
    ('WINTER_STORM', 'Winter Storm'),
    ('WIND', 'Severe Wind'),
]

# Claim Status Codes
CLAIM_STATUS = ['OPEN', 'CLOSED', 'PENDING', 'REOPENED', 'DENIED']

# Policy Status Codes
POLICY_STATUS = ['ACTIVE', 'EXPIRED', 'CANCELLED', 'PENDING']

# Random Seed for Reproducibility
RANDOM_SEED = 42
