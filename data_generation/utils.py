"""
Utility functions for PCDM data generation
"""
import random
from datetime import datetime, timedelta
from faker import Faker
import pandas as pd
import numpy as np

fake = Faker()
Faker.seed(42)
random.seed(42)
np.random.seed(42)


def random_date(start_date, end_date):
    """Generate a random date between start_date and end_date"""
    time_between = end_date - start_date
    days_between = time_between.days
    random_days = random.randrange(days_between)
    return start_date + timedelta(days=random_days)


def random_amount(min_amount, max_amount, distribution='uniform'):
    """Generate a random amount with specified distribution"""
    if distribution == 'uniform':
        return round(random.uniform(min_amount, max_amount), 2)
    elif distribution == 'normal':
        mean = (min_amount + max_amount) / 2
        std = (max_amount - min_amount) / 6
        amount = np.random.normal(mean, std)
        return round(max(min_amount, min(max_amount, amount)), 2)
    elif distribution == 'exponential':
        # Right-skewed distribution for claims
        scale = (max_amount - min_amount) / 3
        amount = np.random.exponential(scale) + min_amount
        return round(min(max_amount, amount), 2)


def weighted_choice(choices, weights):
    """Select from choices with given weights"""
    return random.choices(choices, weights=weights, k=1)[0]


def generate_vin():
    """Generate a fake VIN number"""
    chars = 'ABCDEFGHJKLMNPRSTUVWXYZ0123456789'
    return ''.join(random.choices(chars, k=17))


def generate_phone():
    """Generate a US phone number"""
    area_code = random.randint(200, 999)
    exchange = random.randint(200, 999)
    number = random.randint(1000, 9999)
    return f"{area_code}{exchange}{number}"


def generate_claim_number():
    """Generate a claim number"""
    year = random.randint(20, 25)
    return f"CLM-{year}{random.randint(100000, 999999)}"


def generate_policy_number():
    """Generate a policy number"""
    prefix = random.choice(['PA', 'HO', 'CA', 'WC', 'GL'])
    return f"{prefix}-{random.randint(1000000, 9999999)}"


def add_days(date, days):
    """Add days to a date"""
    if date is None:
        return None
    return date + timedelta(days=days)


def select_severity():
    """Select claim severity with probability distribution"""
    return weighted_choice(
        ['low', 'medium', 'high', 'severe'],
        [0.50, 0.30, 0.15, 0.05]  # 50% low, 30% medium, 15% high, 5% severe
    )


def should_claim_close(days_open):
    """Determine if claim should be closed based on days open"""
    if days_open < 30:
        return random.random() < 0.10
    elif days_open < 60:
        return random.random() < 0.30
    elif days_open < 90:
        return random.random() < 0.50
    elif days_open < 180:
        return random.random() < 0.70
    else:
        return random.random() < 0.90


def generate_address_dict():
    """Generate a complete address dictionary"""
    return {
        'line_1_address': fake.street_address(),
        'line_2_address': fake.secondary_address() if random.random() < 0.2 else None,
        'municipality_name': fake.city(),
        'postal_code': fake.zipcode(),
    }


def generate_person_dict():
    """Generate a complete person dictionary"""
    gender = random.choice(['M', 'F'])
    if gender == 'M':
        first_name = fake.first_name_male()
    else:
        first_name = fake.first_name_female()
    
    last_name = fake.last_name()
    
    return {
        'prefix_name': random.choice(['Mr.', 'Ms.', 'Mrs.', 'Dr.']) if random.random() < 0.3 else None,
        'first_name': first_name,
        'middle_name': fake.first_name() if random.random() < 0.5 else None,
        'last_name': last_name,
        'suffix_name': random.choice(['Jr.', 'Sr.', 'III']) if random.random() < 0.05 else None,
        'full_legal_name': f"{first_name} {last_name}",
        'birth_date': fake.date_of_birth(minimum_age=18, maximum_age=90),
        'gender_code': gender,
    }


def create_dataframe(data_list, columns):
    """Create a pandas DataFrame from a list of dictionaries"""
    if not data_list:
        return pd.DataFrame(columns=columns)
    return pd.DataFrame(data_list)


def save_to_table(spark, df, table_name, catalog, schema, mode='overwrite'):
    """Save pandas DataFrame to Databricks table"""
    spark_df = spark.createDataFrame(df)
    full_table_name = f"{catalog}.{schema}.{table_name}"
    spark_df.write.mode(mode).saveAsTable(full_table_name)
    print(f"✓ Saved {len(df)} records to {full_table_name}")
    return spark_df


def print_progress(current, total, prefix='Progress'):
    """Print progress bar"""
    percent = int((current / total) * 100)
    bar_length = 50
    filled = int(bar_length * current / total)
    bar = '█' * filled + '-' * (bar_length - filled)
    print(f'\r{prefix}: |{bar}| {percent}% ({current}/{total})', end='', flush=True)
    if current == total:
        print()  # New line when complete


class IDGenerator:
    """Simple ID generator that maintains state"""
    def __init__(self):
        self.counters = {}
    
    def next_id(self, entity_type):
        """Get next ID for entity type"""
        if entity_type not in self.counters:
            self.counters[entity_type] = 1
        current_id = self.counters[entity_type]
        self.counters[entity_type] += 1
        return current_id
    
    def get_current_id(self, entity_type):
        """Get current ID (without incrementing)"""
        return self.counters.get(entity_type, 0)


# Global ID generator instance
id_gen = IDGenerator()


def reset_id_generator():
    """Reset all ID counters"""
    global id_gen
    id_gen = IDGenerator()
