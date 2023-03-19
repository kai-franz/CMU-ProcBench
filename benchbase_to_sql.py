# Takes in a package of BenchBase Java queries and stores them as SQL files in the given location.
# usage:   python benchbase_to_sql.py <input_dir> <output_dir>
# example: python benchbase_to_sql.py procbench/procedures/inline "src/PLPgSQL/Scalar UDFs/inlined"


import os
import sys
import re

input_dir = sys.argv[1]
output_dir = sys.argv[2]

files = os.listdir(input_dir)

for file in files:
    name = os.path.splitext(file)[0]
    input_file = open(f"{input_dir}/{file}", 'r')
    output_file = open(f"{output_dir}/{name}.sql", 'w')

    java_str = input_file.read()
    # The SQL query we want is inside triple quotes
    sql = re.search(r'"""(.*)"""', java_str, re.DOTALL).group(1)
    output_file.write(sql)

    input_file.close()
    output_file.close()
