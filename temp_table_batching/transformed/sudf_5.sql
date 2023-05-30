CREATE TABLE #temp
(
    dep         INT,
    morningsale INT,
    eveningsale INT,
    ratio       FLOAT
);

INSERT INTO #temp (dep)
SELECT t.depcount
  FROM (SELECT DISTINCT cd_dep_count AS depcount
          FROM customer_demographics) AS t


UPDATE #temp
   SET morningsale = (SELECT COUNT(*)
                        FROM web_sales_history,
                             time_dim,
                             customer_demographics
                       WHERE ws_sold_time_sk = t_time_sk
                         AND ws_bill_customer_sk = cd_demo_sk
                         AND t_hour >= 8
                         AND t_hour <= 9
                         AND cd_dep_count = dep);
UPDATE #temp
   SET eveningsale = ((SELECT COUNT(*) AS agg_0
                         FROM web_sales_history,
                              time_dim,
                              customer_demographics
                        WHERE (ws_sold_time_sk = t_time_sk)
                          AND (ws_bill_customer_sk = cd_demo_sk)
                          AND (t_hour >= 19)
                          AND (t_hour <= 20)
                          AND (cd_dep_count = dep)));
UPDATE #temp
   SET ratio = CAST(morningSale AS FLOAT) / CAST(eveningSale AS FLOAT);

SELECT dep, ratio
  FROM #temp;

DROP TABLE #temp;