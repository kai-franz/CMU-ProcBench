# Runs the queries in the given directory and stores the results as CSV files in the given location.
# usage:   python get_results.py <input_dir> <output_dir>


import os
import sys
import csv
import psycopg2
import tqdm
import natsort

PG_CONNECTION_STRING = "dbname=benchbase user=admin password=password host=localhost port=5432"

input_dir = sys.argv[1]
output_dir = sys.argv[2]

conn = psycopg2.connect(PG_CONNECTION_STRING)
cur = conn.cursor()

# files = filter(lambda f: f.endswith(".sql"), os.listdir(input_dir))

udfs = [1, 5, 6, 7, 12, 13]
files = [f"sudf_{udf}.sql" for udf in udfs]

files = natsort.natsorted(files)
print(f"Running {len(files)} queries")

for file in tqdm.tqdm(files):
    name = os.path.splitext(file)[0]
    input_file = open(f"{input_dir}/{file}", 'r')
    output_file = open(f"{output_dir}/{name}.csv", 'w')

    sql = input_file.read()
    cur.execute(sql)
    rows = cur.fetchall()
    writer = csv.writer(output_file)
    writer.writerows(rows)

    input_file.close()
    output_file.close()

conn.close()
