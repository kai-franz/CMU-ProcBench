# Generates the data for tables from "Rewriting Procedures for Batched Bindings"
# by Guravannar and Sudarshan: http://www.vldb.org/pvldb/vol1/1453975.pdf
#
# Generates the buyoffers, sellorders, and curexch tables.
# Each table is written to a CSV file with headers.
#
# Data is mostly random except for the following:
# 1. Exchange codes (mkt column in the sellorders table) are ISO 10383 market identifier codes (MIC).
# 2. Currency codes are ISO 4217 currency codes.
import duckdb


def load_exchange_table(con):
    """
    Load the CSV file listing ISO 10383 market identifier codes (MIC) into a table called exchanges.
    The file is available at https://www.iso20022.org/market-identifier-codes
    """
    con.sql('DROP TABLE IF EXISTS exchanges')
    exchange = con.sql('CREATE TABLE exchanges AS SELECT * FROM read_csv("exchanges.csv",header=TRUE,auto_detect=TRUE)')
    con.sql('ALTER TABLE exchanges RENAME "ISO MIC" TO "iso_mic"')


def load_currency_table(con):
    """
    Load the CSV file listing ISO 4217 currency codes into a table called currencies.
    The file is available at https://datahub.io/core/currency-codes
    """
    con.sql('DROP TABLE IF EXISTS currencies')
    currencies = con.sql("""
CREATE TABLE currencies AS 
SELECT * 
  FROM read_csv("currencies.csv",header=TRUE,auto_detect=TRUE) 
 WHERE length("AlphabeticCode") > 0""")


def generate_sellorders(con):
    con.sql('DROP TABLE IF EXISTS sellorders')

    con.sql("""
CREATE TABLE sellorders
(
    orderid  INT PRIMARY KEY,
    mkt      CHAR(4),
    itemcode INT,
    amount   FLOAT,
    curcode  CHAR(3)
)""")

    con.sql('DROP SEQUENCE IF EXISTS serial')
    con.sql('CREATE SEQUENCE serial START 1')

    con.sql("""
INSERT INTO sellorders (orderid, mkt, itemcode, amount, curcode)
SELECT nextval('serial'), iso_mic, random() * 10000, random() * 100, AlphabeticCode 
  FROM exchanges, currencies 
 USING SAMPLE reservoir (100000 ROWS) REPEATABLE (1)""")

    # Print out the contents of the sellorders table
    # con.sql("SELECT * FROM sellorders").show()

    # copy the sellorders table to a CSV file
    con.sql("COPY (SELECT * FROM sellorders) TO 'sellorders.csv' (HEADER)")


def generate_buyoffers(con):
    con.sql('DROP TABLE IF EXISTS buyoffers')

    con.sql("""
CREATE TABLE buyoffers AS 
SELECT CAST(random() * 10000 AS INT) AS itemid, 
       random() * 100 AS price 
  FROM range(100000)""")

    # Copy the buyoffers table to a CSV file
    con.sql("COPY (SELECT * FROM buyoffers) TO 'buyoffers.csv' (HEADER)")


def generate_curexch(con):
    con.sql('DROP TABLE IF EXISTS curexch')

    con.sql("""
CREATE TABLE curexch AS 
SELECT AlphabeticCode AS ccode, 
       (CASE WHEN ccode = 'USD' THEN 1.0 ELSE random() * 100 END) AS price 
  FROM currencies
 WHERE ccode != ''""")

    # Copy the curexch table to a CSV file
    con.sql("COPY (SELECT * FROM curexch) TO 'curexch.csv' (HEADER)")


if __name__ == "__main__":
    con = duckdb.connect('file.db')
    load_exchange_table(con)
    load_currency_table(con)
    generate_sellorders(con)
    generate_buyoffers(con)
    generate_curexch(con)
