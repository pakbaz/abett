#!/usr/bin/env python

import argparse
import json
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from lib.process_claim import process_claim, get_database_connection


def main():
    # Establish database connection
    db = get_database_connection()

    try:
        # Process each line from STDIN as a claim
        for claim in sys.stdin:
            process_claim(db, claim)
    except Exception as e:
        db.rollback()
        print(f"An error occurred: {e}")
    finally:
        db.close()



if __name__ == '__main__':
    main()
