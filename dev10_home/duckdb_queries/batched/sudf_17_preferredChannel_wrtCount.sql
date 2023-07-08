DROP TABLE IF EXISTS state;
CREATE TEMPORARY TABLE state
(
    cust_key     INT,
    numweb       INT,
    numstore     INT,
    numcat       INT,
    p0           BOOLEAN,
    p1           BOOLEAN,
    p2           BOOLEAN,
    multiplicity INT,
    result       VARCHAR(50),
    returned     BOOLEAN DEFAULT FALSE
);
INSERT INTO state(cust_key, multiplicity)
SELECT t.c_customer_sk, COUNT(*)
  FROM (SELECT c_customer_sk FROM customer) t
 GROUP BY t.c_customer_sk;

UPDATE state
   SET numweb = 0
 WHERE NOT returned;

UPDATE state
   SET numstore = 0
 WHERE NOT returned;

UPDATE state
   SET numcat = 0
 WHERE NOT returned;

UPDATE state
   SET numweb = (SELECT COUNT(*) FROM web_sales_history WHERE ws_bill_customer_sk = cust_key)
 WHERE NOT returned;

UPDATE state
   SET numstore = (SELECT COUNT(*) FROM store_sales_history WHERE ss_customer_sk = cust_key)
 WHERE NOT returned;

UPDATE state
   SET numcat = (SELECT COUNT(*) FROM catalog_sales_history WHERE cs_bill_customer_sk = cust_key)
 WHERE NOT returned;

UPDATE state
   SET p0 = COALESCE(numweb >= numstore AND numweb >= numcat, FALSE)
 WHERE NOT returned;

UPDATE state
   SET result   = 'web',
       returned = TRUE
 WHERE p0
   AND NOT returned;

UPDATE state
   SET p1 = COALESCE(numstore >= numweb AND numstore >= numcat, FALSE)
 WHERE NOT returned;

UPDATE state
   SET result   = 'store',
       returned = TRUE
 WHERE p1
   AND NOT returned;

UPDATE state
   SET p2 = COALESCE(numcat >= numstore AND numcat >= numweb, FALSE)
 WHERE NOT returned;

UPDATE state
   SET result   = 'Catalog',
       returned = TRUE
 WHERE p2
   AND NOT returned;

UPDATE state
   SET result   = 'Logical error',
       returned = TRUE
 WHERE NOT returned;

SELECT s.cust_key, s.result
  FROM state AS s, LATERAL UNNEST(GENERATE_SERIES(1, s.multiplicity));

