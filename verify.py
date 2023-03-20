# Runs the queries in the given directory and verifies them against the given results.

import os
import sys
import csv
import psycopg2
import natsort
import unittest

PG_CONNECTION_STRING = "dbname=benchbase user=admin password=password host=localhost port=5432"
args = []

def cast_value(value):
    value = str(value)
    if value == 'None':
        value = ""
    return value

class QueryTestCase(unittest.TestCase):
    def setUp(self):
        self.conn = psycopg2.connect(PG_CONNECTION_STRING)
        self.cur = self.conn.cursor()

    def tearDown(self):
        self.conn.close()

    def test_queries(self):
        input_dir = args[1]
        result_dir = args[2]

        files = filter(lambda f: f.endswith(".sql"), os.listdir(input_dir))
        files = natsort.natsorted(files)
        print(f"Verifying {len(files)} queries")

        for file in files:
            name = os.path.splitext(file)[0]
            input_file = open(f"{input_dir}/{file}", 'r')
            print(f"Verifying {name}...")

            sql = input_file.read()
            self.cur.execute(sql)
            rows = list(tuple(cast_value(attr) for attr in row) for row in self.cur.fetchall())
            rows.sort()
            expected_file = open(f"{result_dir}/{name}.csv", 'r')
            expected_reader = csv.reader(expected_file)
            expected_rows = list(tuple(cast_value(attr) for attr in row) for row in expected_reader)
            expected_rows.sort()
            expected_file.close()

            self.assertEqual(len(rows), len(expected_rows), f"Result count for {name} does not match expected result count")
            self.assertEqual(rows, expected_rows, f"Results for {name} do not match expected results")

            input_file.close()


if __name__ == '__main__':
    args = sys.argv.copy()

    unittest.main(argv=[sys.argv[0]])
