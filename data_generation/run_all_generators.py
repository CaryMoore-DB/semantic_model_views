# Databricks notebook source
"""
Master script to run all PCDM data generation scripts in order
"""
import sys
import subprocess
from datetime import datetime

# List of all generator scripts in execution order
GENERATOR_SCRIPTS = [
    ("01_generate_reference_data.py", "Reference Data (States, Coverages, etc.)"),
    ("02_generate_parties.py", "Party Data (Persons, Organizations, Groups)"),
    ("03_generate_locations.py", "Geographic Locations and Addresses"),
    ("04_generate_products.py", "Products and Lines of Business"),
    ("05_generate_policies.py", "Policies and Coverage Details"),
    ("06_generate_risks.py", "Insurable Objects (Vehicles, Structures)"),
    ("07_generate_premiums.py", "Premium Amounts and Transactions"),
    ("08_generate_occurrences.py", "Occurrences and Events"),
    ("09_generate_claims.py", "Claims"),
    ("10_generate_claim_amounts.py", "Claim Amounts (Payments, Reserves, Recoveries)"),
    ("11_generate_legal_data.py", "Legal Data (Litigation, Attorneys, Courts)"),
]

def run_script(script_name, description):
    """Run a single generator script"""
    print("\n" + "=" * 80)
    print(f"RUNNING: {description}")
    print(f"Script: {script_name}")
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80)
    
    try:
        result = subprocess.run(
            [sys.executable, script_name],
            check=True,
            capture_output=True,
            text=True
        )
        print(result.stdout)
        if result.stderr:
            print("STDERR:", result.stderr)
        print(f"✓ {description} completed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"\n✗ ERROR in {description}")
        print("STDOUT:", e.stdout)
        print("STDERR:", e.stderr)
        return False
    except FileNotFoundError:
        print(f"\n✗ ERROR: Script {script_name} not found")
        return False


def main():
    """Run all generator scripts"""
    print("\n" + "=" * 80)
    print("PCDM FAKE DATA GENERATION - MASTER RUNNER")
    print("=" * 80)
    print(f"Start Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Total Scripts: {len(GENERATOR_SCRIPTS)}")
    print("=" * 80)
    
    start_time = datetime.now()
    completed = 0
    failed = 0
    
    for i, (script, description) in enumerate(GENERATOR_SCRIPTS, 1):
        print(f"\n[{i}/{len(GENERATOR_SCRIPTS)}] Processing: {description}")
        
        success = run_script(script, description)
        
        if success:
            completed += 1
        else:
            failed += 1
            print(f"\n⚠ WARNING: Script {script} failed. Stopping execution.")
            break
    
    end_time = datetime.now()
    duration = end_time - start_time
    
    # Summary
    print("\n" + "=" * 80)
    print("GENERATION SUMMARY")
    print("=" * 80)
    print(f"Start Time: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"End Time: {end_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Duration: {duration}")
    print(f"Completed: {completed}/{len(GENERATOR_SCRIPTS)}")
    print(f"Failed: {failed}/{len(GENERATOR_SCRIPTS)}")
    
    if failed == 0:
        print("\n✓ ALL DATA GENERATION COMPLETED SUCCESSFULLY!")
    else:
        print(f"\n✗ DATA GENERATION INCOMPLETE - {failed} script(s) failed")
        sys.exit(1)
    
    print("=" * 80)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠ Generation interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n✗ Unexpected error: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
