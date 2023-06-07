CREATE TABLE sellorders
(
    orderid  INT PRIMARY KEY,
    mkt      CHAR(4),
    itemcode INT,
    amount   FLOAT,
    curcode  CHAR(3)
)

CREATE TABLE buyoffers
(
    itemid INT,
    price  FLOAT
)

CREATE TABLE curexch
(
    ccode    CHAR(3),
    exchrate FLOAT
)

