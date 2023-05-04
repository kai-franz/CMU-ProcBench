import itertools
from pglast import ast, parse_sql
from pglast.enums import ConstrType
from pglast.visitors import Visitor


class Table:
    def __init__(self, name, cols: dict, primary_key: str = None):
        self.name = name
        self.cols = cols
        self.primary_key = primary_key


class Schema:
    """
    Represents the schema of the database.
    """

    def __init__(self, schema_file):
        self.tables = {}
        with open(schema_file, "r") as f:
            schema_ast = parse_sql(f.read())
        for raw_stmt in schema_ast:
            stmt = raw_stmt.stmt
            if not isinstance(stmt, ast.CreateStmt):
                continue
            self.add_table_from_ast(stmt)

    def add_table(self, name, cols: dict, primary_key: str = None):
        self.tables[name] = Table(name, cols, primary_key)

    def add_table_from_ast(self, table_ast: ast.CreateStmt):
        name = table_ast.relation.relname
        cols = {}
        primary_key = None
        for col in table_ast.tableElts:
            if isinstance(col, ast.ColumnDef):
                cols[col.colname] = col
                if col.constraints:
                    for constraint in col.constraints:
                        assert isinstance(constraint, ast.Constraint)
                        if constraint.contype == ConstrType.CONSTR_PRIMARY:
                            assert primary_key is None
                            primary_key = col.colname
        self.add_table(name, cols, primary_key=primary_key)

    def get_columns_for_table(self, table):
        return set(self.tables[table].cols.keys())

    def get_columns(self, tables):
        columns = set()
        for table in tables:
            columns = columns.union(self.get_columns_for_table(table))
        return columns

    def get_primary_key(self, table):
        return self.tables[table].primary_key


class ProcBenchSchema(Schema):
    def __init__(self):
        super().__init__("./schema.sql")


class ColumnRefFinder(Visitor):
    def __init__(self):
        self.cols = set()

    def visit_ColumnRef(self, ancestors, node):
        self.cols.add(node.fields[-1].val)

schema = ProcBenchSchema()
query = """
SELECT COUNT(*)
  INTO numSalesFromStore
  FROM store_sales_history
 WHERE ss_customer_sk = 1
   AND ss_sold_date_sk >= 2451545
   AND ss_sold_date_sk <= 2459215;"""

query_ast = parse_sql(query)[0].stmt
column_ref_finder = ColumnRefFinder()
column_ref_finder(query_ast)
print(column_ref_finder.cols)
create_index_statements = []
drop_index_statements = []
for table_name, table in schema.tables.items():
    cols = []
    for col in table.cols.keys():
        if col in column_ref_finder.cols:
            cols.append(col)
    for n in range(1, len(cols) + 1):
        for subset in itertools.combinations(cols, n):
            for i, permutation in enumerate(itertools.permutations(subset)):
                if len(permutation) == 0:
                    continue
                index_id = f"{table_name}_{'_'.join(permutation)}_idx"
                if len(index_id) > 63:
                    tokens = index_id.split("_")
                    index_id = "_".join(token[0] for token in tokens)
                create_index_statements.append(f"CREATE INDEX IF NOT EXISTS {index_id} ON {table_name} (" + ', '.join(permutation) + ");")
                drop_index_statements.append(f"DROP INDEX IF EXISTS {index_id};")


print("\n".join(create_index_statements))
print("\n\n\n")
print("\n".join(drop_index_statements))


