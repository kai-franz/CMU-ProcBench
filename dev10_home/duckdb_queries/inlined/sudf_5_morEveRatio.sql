
SELECT t.depcount,
       (SELECT _4.retval
          FROM (SELECT (SELECT COUNT(*)
                          FROM web_sales_history,
                               time_dim,
                               customer_demographics
                         WHERE ws_sold_time_sk = t_time_sk
                           AND ws_bill_customer_sk = cd_demo_sk
                           AND t_hour >= 8
                           AND t_hour <= 9
                           AND cd_dep_count = t.depcount)) AS _1(morningsale),
               LATERAL (SELECT (SELECT COUNT(*)
                                  FROM web_sales_history,
                                       time_dim,
                                       customer_demographics
                                 WHERE ws_sold_time_sk = t_time_sk
                                   AND ws_bill_customer_sk = cd_demo_sk
                                   AND t_hour >= 19
                                   AND t_hour <= 20
                                   AND cd_dep_count = t.depcount)) AS _2(eveningsale),
               LATERAL
                   (SELECT (CAST(_1.morningsale AS FLOAT) / CAST(_2.eveningsale AS FLOAT))) AS _3(ratio),
               LATERAL (SELECT _3.ratio) AS _4(retval))
  FROM (SELECT DISTINCT cd_dep_count AS depcount FROM customer_demographics) t;