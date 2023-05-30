CREATE TABLE #temp
(
    manager           VARCHAR(40),
    netprofit         DECIMAL(15, 2),
    profitablemanager INTEGER,
    returned          BIT DEFAULT 0,
    p1                BIT
);

INSERT INTO #temp (manager)
SELECT s_manager
  FROM store;


UPDATE #temp
   SET netprofit = (SELECT SUM(ss_net_profit) AS agg_0
                      FROM store,
                           store_sales_history,
                           date_dim
                     WHERE (ss_sold_date_sk = d_date_sk)
                       AND (d_year = 2001)
                       AND (s_manager = manager)
                       AND (s_store_sk = ss_store_sk));

UPDATE #temp
   SET p1 = CASE WHEN netprofit > 0 THEN 1 ELSE 0 END;

UPDATE #temp
   SET profitablemanager = 1,
       returned          = 1
 WHERE p1 = 1
   AND returned = 0;

UPDATE #temp
   SET profitablemanager = 0,
       returned          = 1
 WHERE p1 = 0
   AND returned = 0;

SELECT manager
  FROM #temp
 WHERE profitablemanager <= 0;

DROP TABLE #temp;