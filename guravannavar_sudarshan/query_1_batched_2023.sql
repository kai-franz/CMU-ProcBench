CREATE TABLE #state
(
    orderid      INT,
    itemcode     INT,
    amount       FLOAT,
    curcode      CHAR(3),
    amount_usd   FLOAT,
    count_offers INT,
    p1           BIT
)

INSERT INTO #state (orderid, itemcode, amount, curcode)
SELECT orderid, itemcode, amount, curcode
  FROM sellorders
 WHERE mkt = 'XNSE';

UPDATE #state
   SET p1 = (CASE WHEN curcode = 'USD' THEN 1 ELSE 0 END);

UPDATE #state
   SET amount_usd = amount
 WHERE p1 = 1;

UPDATE #state
   SET amount_usd = amount * (SELECT exchrate FROM curexch WHERE curexch.ccode = #state.curcode)
 WHERE p1 = 0;

UPDATE #state
   SET count_offers = (SELECT COUNT(*)
                         FROM buyoffers
                        WHERE buyoffers.itemid = #state.itemcode
                          AND buyoffers.price >= #state.amount_usd);

SELECT orderid
  FROM #state
 WHERE count_offers > 0;

DROP TABLE #state;
