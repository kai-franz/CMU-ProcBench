CREATE TABLE #temp
(
    cust_sk               INTEGER,
    spending1             DECIMAL(15, 2) DEFAULT 0,
    spending2             DECIMAL(15, 2) DEFAULT 0,
    increase              DECIMAL(15, 2) DEFAULT 0,
    increaseinwebspending DECIMAL(15, 2),
    p1                    BIT,
    returned              BIT            DEFAULT 0
);

INSERT INTO #temp (cust_sk)
SELECT t.ws_bill_customer_sk
  FROM (SELECT ws_bill_customer_sk
          FROM web_sales_history,
               date_dim
         WHERE d_date_sk = ws_sold_date_sk
           AND d_year = 2000

     INTERSECT

        SELECT ws_bill_customer_sk
          FROM web_sales_history,
               date_dim
         WHERE d_date_sk = ws_sold_date_sk
           AND d_year = 2001) t;


UPDATE #temp
   SET spending1 = 0;

UPDATE #temp
   SET spending2 = 0;

UPDATE #temp
   SET increase = 0;

UPDATE #temp
   SET spending1 = (SELECT SUM(ws_net_paid_inc_ship_tax)
                      FROM web_sales_history,
                           date_dim
                     WHERE (d_date_sk = ws_sold_date_sk)
                       AND (d_year = 2001)
                       AND (ws_bill_customer_sk = cust_sk));

UPDATE #temp
   SET spending2 =
           (SELECT SUM(ws_net_paid_inc_ship_tax)
              FROM web_sales_history,
                   date_dim
             WHERE (d_date_sk = ws_sold_date_sk)
               AND (d_year = 2000)
               AND (ws_bill_customer_sk = cust_sk));

UPDATE #temp
   SET p1 = CASE WHEN spending1 < spending2 THEN 1 ELSE 0 END;



UPDATE #temp
   SET increaseinwebspending = -1,
       returned              = 1
 WHERE p1 = 1;

UPDATE #temp
   SET increase = spending1 - spending2
 WHERE p1 = 0;

UPDATE #temp
   SET increaseinwebspending = increase,
       returned              = 1
 WHERE returned = 0;

SELECT cust_sk, increaseinwebspending
  FROM #temp
 WHERE increaseinwebspending > 0;

DROP TABLE #temp;
