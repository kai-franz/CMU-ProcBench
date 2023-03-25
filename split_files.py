# Splits a file containing a UDF and a query into two files, one containing the UDFs and one containing the queries.
# Usage:   python split_files.py <input_dir> <query_output_dir> <udf_output_dir>

import os
import sys
import tqdm
import natsort
from pglast import parse_sql, ast
from pglast.stream import IndentedStream

input_dir = sys.argv[1]
query_output_dir = sys.argv[2]
udf_output_dir = sys.argv[3]

all_input_files = os.listdir(input_dir)

# If set to True, all files in the input directory will be processed.
# If set to False, only the files with the specified UDFs will be processed.
USE_ALL_FILES = True
enabled_udfs = [1, 5, 6, 7, 12, 13]

if USE_ALL_FILES:
    # Process all files in the input directory.
    # The file prefix is the first two parts of the file name, e.g. sudf_1_totalLargePurchases.sql -> sudf_1
    expanded_files = [f for f in all_input_files if f.endswith(".sql")]
    file_prefixes = ["_".join(expanded_file.split("_")[:2]) + ".sql" for expanded_file in expanded_files]
else:
    # Only process the files with the specified UDFs (in enabled_udfs)
    file_prefixes = [f"sudf_{udf}_" for udf in enabled_udfs]
    # match the file prefixes with the actual file names, e.g. sudf_1 -> sudf_1_totalLargePurchases.sql
    expanded_files = []
    for file_prefix in file_prefixes:
        for f in all_input_files:
            if f.startswith(file_prefix):
                expanded_files.append(f)
                break

file_pairs = natsort.natsorted(zip(file_prefixes, expanded_files), key=lambda f_tuple: f_tuple[1])

for file_prefix, expanded_file in tqdm.tqdm(file_pairs):
    with open(f"{input_dir}/{expanded_file}", 'r') as input_file:
        sql = input_file.read()
    root = parse_sql(sql)

    # The parser returns a list of statements, which can be either queries or UDFs.
    # Separate them into two lists.
    input_queries = [raw_stmt for raw_stmt in root if isinstance(raw_stmt.stmt, ast.SelectStmt)]
    input_udfs = [raw_stmt for raw_stmt in root if isinstance(raw_stmt.stmt, ast.CreateFunctionStmt)]

    # Check that there are no unexpected statements in the file.
    assert len(input_queries) + len(input_udfs) == len(root), \
        f"Expected {len(root)} statements, got {len(input_queries)} queries, {len(input_udfs)} UDFs in {file_prefix}"

    # Check that there are no unexpected queries in the file.
    assert len(input_queries) <= 2, f"Expected 0, 1, or 2 queries, got {len(input_queries)} in {file_prefix}"

    # Write all of the UDFs to the UDF output file.
    with open(f"{udf_output_dir}/{file_prefix}", 'w') as udf_out_file:
        for input_udf in input_udfs:
            udf_out_file.write(IndentedStream()(input_udf.stmt) + ";")

    if len(input_queries) == 1:
        """ If there is only one query, we just write it to the output file,
        # which has the name of the file prefix, e.g. sudf_1.sql. """
        query_out_file = open(f"{query_output_dir}/{file_prefix}", 'w')
        query_out_file.write(IndentedStream()(input_queries[0].stmt) + ";")
        query_out_file.close()

    elif len(input_queries) == 2:
        """ There is one UDF and two calls to the UDF in the file.
        # The first one is the "complex" query, the second one is the "simple" query.
        # We write the "complex" query to a file named <file_prefix>_complex.sql,
        # and the "simple" query to a file named <file_prefix>_simple.sql. """
        output_file_name = file_prefix.split(".")[0]
        with open(f"{query_output_dir}/{output_file_name}_simple.sql", 'w') as simple_file, \
                open(f"{query_output_dir}/{output_file_name}_complex.sql", 'w') as complex_file:

            complex_file.write(IndentedStream()(input_queries[0].stmt) + ";")
            simple_file.write(IndentedStream()(input_queries[1].stmt) + ";")
