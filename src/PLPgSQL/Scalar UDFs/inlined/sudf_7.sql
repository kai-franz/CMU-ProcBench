
            SELECT store.s_manager
  FROM store
           LEFT OUTER JOIN (SELECT SUM(ss_net_profit)                                 AS profit,
                                   CASE WHEN SUM(ss_net_profit) > 0 THEN 1 ELSE 0 END AS profitable,
                                   s_manager
                              FROM store
                                       JOIN store_sales_history
                                       JOIN date_dim ON ss_sold_date_sk = d_date_sk ON s_store_sk = ss_store_sk
                             WHERE d_year = 2001
                             GROUP BY s_manager) AS profit
                           ON store.s_manager = profit.s_manager
where profitable is null or profitable <= 0;
          