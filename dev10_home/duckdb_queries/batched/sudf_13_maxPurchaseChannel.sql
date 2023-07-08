DROP TABLE IF EXISTS state;
CREATE TEMPORARY TABLE state
(
    ckey                INT,
    fromdatesk          INT,
    todatesk            INT,
    numsalesfromstore   INT,
    numsalesfromcatalog INT,
    numsalesfromweb     INT,
    maxchannel          VARCHAR(50),
    p0                  BOOLEAN,
    p1                  BOOLEAN,
    p2                  BOOLEAN,
    multiplicity        INT,
    result              VARCHAR(50),
    returned            BOOLEAN DEFAULT FALSE
);
INSERT INTO state(ckey, fromdatesk, todatesk, multiplicity)
SELECT t.c_customer_sk, t.fromdatesk, t.todatesk, COUNT(*)
  FROM (SELECT c_customer_sk, 2451545 AS fromdatesk, 2459215 AS todatesk FROM customer) t
 GROUP BY t.c_customer_sk, t.fromdatesk, t.todatesk;

UPDATE state
   SET numsalesfromstore = (SELECT COUNT(*)
                              FROM store_sales_history
                             WHERE ss_customer_sk = ckey
                               AND ss_sold_date_sk >= fromdatesk
                               AND ss_sold_date_sk <= todatesk)
 WHERE NOT returned;

UPDATE state
   SET numsalesfromcatalog = (SELECT COUNT(*)
                                FROM catalog_sales_history
                               WHERE cs_bill_customer_sk = ckey
                                 AND cs_sold_date_sk >= fromdatesk
                                 AND cs_sold_date_sk <= todatesk)
 WHERE NOT returned;

UPDATE state
   SET numsalesfromweb = (SELECT COUNT(*)
                            FROM web_sales_history
                           WHERE ws_bill_customer_sk = ckey
                             AND ws_sold_date_sk >= fromdatesk
                             AND ws_sold_date_sk <= todatesk)
 WHERE NOT returned;

UPDATE state
   SET p0 = COALESCE(numsalesfromstore > numsalesfromcatalog, FALSE)
 WHERE NOT returned;

UPDATE state
   SET maxchannel = 'Store'
 WHERE p0
   AND NOT returned;

UPDATE state
   SET p1 = COALESCE(numsalesfromweb > numsalesfromstore, FALSE)
 WHERE p0
   AND NOT returned;

UPDATE state
   SET maxchannel = 'Web'
 WHERE p0
   AND p1
   AND NOT returned;

UPDATE state
   SET maxchannel = 'Catalog'
 WHERE NOT p0
   AND NOT returned;

UPDATE state
   SET p2 = COALESCE(numsalesfromweb > numsalesfromcatalog, FALSE)
 WHERE NOT p0
   AND NOT returned;

UPDATE state
   SET maxchannel = 'Web'
 WHERE NOT p0
   AND p2
   AND NOT returned;

UPDATE state
   SET result   = maxchannel,
       returned = TRUE
 WHERE NOT returned;

SELECT s.ckey, s.result AS channel
  FROM state AS s, LATERAL UNNEST(GENERATE_SERIES(1, s.multiplicity));
