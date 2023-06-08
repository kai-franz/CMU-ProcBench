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

EXCHANGE_RATE_RANGE = 10
PRICE_RANGE = 10
NUM_ITEMS = 1000

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

    # Use 'serial' sequence to generate primary keys
    con.sql('DROP SEQUENCE IF EXISTS serial')
    con.sql('CREATE SEQUENCE serial START 1')

#     con.sql("""
# INSERT INTO sellorders (orderid, mkt, itemcode, amount, curcode)
# SELECT nextval('serial'), iso_mic, random() * 10000, random() * 100, AlphabeticCode
#   FROM exchanges, currencies
#  USING SAMPLE reservoir (1000000 ROWS) REPEATABLE (1)""")



    con.sql(f"""
INSERT INTO sellorders (orderid, mkt, itemcode, amount, curcode)
  WITH numbered_codes AS (SELECT AlphabeticCode AS cur_code, ROW_NUMBER() OVER () AS id FROM currencies),
       numbered_mics AS (SELECT iso_mic, ROW_NUMBER() OVER () AS id FROM exchanges),
       random_vals AS (SELECT nextval('serial')                             AS orderid,
                              CAST(ceil(random() * {NUM_ITEMS}) AS INT) AS itemcode,
                              random() * {PRICE_RANGE} AS amount, cast(ceil(random() * (SELECT MAX (id) FROM numbered_codes)) AS INT) AS random_id, cast(ceil(random() * (SELECT MAX (id) FROM numbered_mics)) AS INT) AS random_mic
                         FROM RANGE (100000))
SELECT orderid, iso_mic, itemcode, amount, cur_code
  FROM random_vals
           JOIN numbered_codes ON random_vals.random_id = numbered_codes.id
           JOIN numbered_mics ON random_vals.random_mic = numbered_mics.id""")

    # Print out the contents of the sellorders table
    # con.sql("SELECT * FROM sellorders").show()

    # copy the sellorders table to a CSV file
    con.sql("COPY (SELECT * FROM sellorders) TO 'sellorders.csv' (HEADER)")


def generate_buyoffers(con):
    con.sql('DROP TABLE IF EXISTS buyoffers')

    con.sql(f"""
CREATE TABLE buyoffers AS 
SELECT CAST(ceil(random() * {NUM_ITEMS}) AS INT) AS itemid, 
       random() * {PRICE_RANGE} AS price 
  FROM range(100000)""")

    # Copy the buyoffers table to a CSV file
    con.sql("COPY (SELECT * FROM buyoffers) TO 'buyoffers.csv' (HEADER)")


def generate_curexch(con):
    con.sql('DROP TABLE IF EXISTS curexch')

    con.sql(f"""
CREATE TABLE curexch AS 
WITH codes AS (SELECT DISTINCT AlphabeticCode FROM currencies)
SELECT AlphabeticCode AS ccode, 
       (CASE WHEN ccode = 'USD' THEN 1.0 ELSE random() * {EXCHANGE_RATE_RANGE} END) AS price 
  FROM codes
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
