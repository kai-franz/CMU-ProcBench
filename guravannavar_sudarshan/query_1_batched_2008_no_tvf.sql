DROP FUNCTION IF EXISTS count_offers_batched;
DROP TYPE IF EXISTS countoffers_batched_params;

CREATE TYPE countoffers_batched_params AS TABLE
(
    itemcode INT,
    amount   FLOAT,
    curcode  CHAR(3)
);
GO

DECLARE @r1 countoffers_batched_params;
INSERT INTO @r1
SELECT DISTINCT itemcode, amount, curcode
  FROM sellorders
 WHERE mkt = 'XNSE';

--------------------- BEGIN UDF -----------------------
DECLARE @itemcode INT, @amount FLOAT, @curcode CHAR(3);
DECLARE @r2 TABLE
            (
                itemcode     INT,
                amount       FLOAT,
                curcode      CHAR(3),
                cond1        BIT,
                amount_usd   FLOAT,
                count_offers INT
            );
INSERT INTO @r2 (itemcode, amount, curcode)
SELECT itemcode, amount, curcode
  FROM @r1;

UPDATE @r2
   SET cond1 = IIF((curcode = 'USD'), 1, 0);

UPDATE @r2
   SET amount_usd = amount
 WHERE cond1 = 1;

MERGE INTO @r2 AS tgt
USING (SELECT r.curcode, c.exchrate
         FROM (SELECT DISTINCT curcode FROM @r2 WHERE cond1 = 0) r
                  JOIN curexch c ON r.curcode = c.ccode) AS sq1b
ON tgt.curcode = sq1b.curcode
WHEN MATCHED THEN
    UPDATE
       SET amount_usd = amount * sq1b.exchrate;

MERGE INTO @r2 AS tgt
USING (SELECT r.itemcode,
              r.amount_usd,
              COUNT(b.itemid) AS count_offers
         FROM (SELECT DISTINCT itemcode, amount_usd FROM @r2) r
                  LEFT OUTER JOIN buyoffers b
                                  ON b.itemid = r.itemcode AND b.price >= r.amount_usd
        GROUP BY r.itemcode, r.amount_usd) AS sq2b
ON (tgt.itemcode = sq2b.itemcode AND
    tgt.amount_usd = sq2b.amount_usd)
WHEN MATCHED THEN
    UPDATE
       SET count_offers = sq2b.count_offers;
--------------------- END UDF -----------------------


SELECT orderid
  FROM sellorders so,
       @r2 br
 WHERE so.mkt = 'XNSE'
   AND so.itemcode = br.itemcode
   AND so.amount = br.amount
   AND so.curcode = br.curcode
   AND br.count_offers > 0;
