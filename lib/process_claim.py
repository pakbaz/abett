from datetime import date
import json
import uuid
import mysql.connector

class InvalidClaimantError(Exception):
    pass


# Function to get database connection
def get_database_connection():
    connection = mysql.connector.connect(
        host="localhost",
        port=13306,
        user="root",
        password="tamagotchi",
        database="claims"
    )
    return connection

# Function to process a claim
def process_claim(db, claim):
    cursor = db.cursor(dictionary=True)
    claim_data = json.loads(claim)
    # Find the claimant_id from employees or dependents
    query = """
    SELECT employee_id AS claimant_id, 'employee' AS claimant_type
    FROM employees
    WHERE ssn_suffix = %(ssn_suffix)s AND last_name = %(last_name)s AND first_name = %(first_name)s AND date_of_birth = %(date_of_birth)s
    UNION
    SELECT dependent_id AS claimant_id, 'dependent' AS claimant_type
    FROM dependents
    WHERE ssn_suffix = %(ssn_suffix)s AND last_name = %(last_name)s AND first_name = %(first_name)s AND date_of_birth = %(date_of_birth)s
    """
    cursor.execute(query, claim_data)
    claimant_info = cursor.fetchone()

    if not claimant_info:
        raise ValueError("No matching claimant found for the claim data provided.")

    claim_id = str(uuid.uuid4())
    # Insert the claim into the claims table
    insert_query = """
    INSERT INTO claims (claim_id, claimant_id, claimant_type, claim_date, claim_amount)
    VALUES (%(claim_id)s, %(claimant_id)s, %(claimant_type)s, %(claim_date)s, %(claim_amount)s)
    """
    claim_data.update(claimant_info)
    claim_data['claim_id'] = claim_id  # Add the generated UUID to the claim data

    cursor.execute(insert_query, claim_data)
    print(f"Claim {claim_id} processed successfully.")
    db.commit()
    cursor.close()
