
              SELECT t.depCount, CAST(morning.m_sales AS FLOAT) / CAST(evening.e_sales AS FLOAT) as morningtoeveratio
                 FROM (SELECT DISTINCT cd_dep_count AS depCount FROM customer_demographics) t
                          LEFT OUTER JOIN
                      (SELECT cd_dep_count, COUNT(*) AS m_sales
                         FROM web_sales_history,
                              time_dim,
                              customer_demographics
                        WHERE ws_sold_time_sk = t_time_sk
                          AND ws_bill_customer_sk = cd_demo_sk
                          AND t_hour >= 8
                          AND t_hour <= 9
                        GROUP BY cd_dep_count) AS morning
                          LEFT OUTER JOIN
                      (SELECT cd_dep_count, COUNT(*) AS e_sales
                         FROM web_sales_history,
                              time_dim,
                              customer_demographics
                        WHERE ws_sold_time_sk = t_time_sk
                          AND ws_bill_customer_sk = cd_demo_sk
                          AND t_hour >= 19
                          AND t_hour <= 20
                        GROUP BY cd_dep_count) AS evening
                      ON morning.cd_dep_count = evening.cd_dep_count
                      ON t.depCount = morning.cd_dep_count;
            