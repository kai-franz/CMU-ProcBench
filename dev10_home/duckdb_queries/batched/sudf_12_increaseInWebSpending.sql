DROP TABLE IF EXISTS state;
CREATE TEMPORARY TABLE state
(
    cust_sk      INT,
    spending1    DECIMAL,
    spending2    DECIMAL,
    increase     DECIMAL,
    p0           BOOLEAN,
    multiplicity INT,
    result       DECIMAL,
    returned     BOOLEAN DEFAULT FALSE
);


INSERT INTO state (cust_sk, multiplicity)
SELECT t.c_customer_sk, COUNT(*)
  FROM (SELECT c_customer_sk
          FROM customer
         WHERE c_customer_sk IN
               (SELECT ws_bill_customer_sk
                  FROM web_sales_history,
                       date_dim
                 WHERE d_date_sk = ws_sold_date_sk
                   AND d_year = 2000

             INTERSECT

                SELECT ws_bill_customer_sk
                  FROM web_sales_history,
                       date_dim
                 WHERE d_date_sk = ws_sold_date_sk
                   AND d_year = 2001)) t
 GROUP BY t.c_customer_sk;

UPDATE state
   SET spending1 = 0;

UPDATE state
   SET spending2 = 0;

UPDATE state
   SET increase = 0;

UPDATE state
   SET spending1 = (SELECT SUM(ws_net_paid_inc_ship_tax)
                      FROM web_sales_history,
                           date_dim
                     WHERE d_date_sk = ws_sold_date_sk
                       AND d_year = 2001
                       AND ws_bill_customer_sk = cust_sk)
 WHERE NOT returned;

UPDATE state
   SET spending2 = (SELECT SUM(ws_net_paid_inc_ship_tax)
                      FROM web_sales_history,
                           date_dim
                     WHERE d_date_sk = ws_sold_date_sk
                       AND d_year = 2000
                       AND ws_bill_customer_sk = cust_sk)
 WHERE NOT returned;

UPDATE state
   SET p0 = COALESCE(spending1 < spending2, FALSE)
 WHERE NOT returned;

UPDATE state
   SET result   = -1,
       returned = TRUE
 WHERE NOT returned
   AND p0;

UPDATE state
   SET increase = spending1 - spending2
 WHERE NOT returned
   AND NOT p0;

UPDATE state
   SET result = increase
 WHERE NOT returned;

SELECT s.cust_sk
  FROM state AS s, LATERAL UNNEST(GENERATE_SERIES(1, s.multiplicity))
 WHERE result > 0;
