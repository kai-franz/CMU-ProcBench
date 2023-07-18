SELECT s_manager
  FROM store s1
 WHERE (SELECT _4.retval
          FROM (SELECT (SELECT SUM(ss_net_profit)
                          FROM store s2,
                               store_sales_history,
                               date_dim
                         WHERE ss_sold_date_sk = d_date_sk
                           AND d_year = 2001
                           AND s1.s_manager = s2.s_manager
                           AND s_store_sk = ss_store_sk) AS netprofit) AS _1(netprofit),
               LATERAL (SELECT CASE
                                   WHEN _1.netprofit > 0
                                       THEN (SELECT _2.retval
                                               FROM (SELECT 1) AS _2(retval))
                                   ELSE (SELECT _3.retval
                                           FROM (SELECT 0) AS _3(retval))
                                   END) AS _4(retval)) <= 0;