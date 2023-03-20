
          SELECT (CASE
            WHEN COUNT(*) IS NULL OR COUNT(*) <= 1 THEN 'no correlation'
            WHEN COUNT(*) <= 3 THEN 'somewhat correlated'
            ELSE 'hihgly correlated' END)
  FROM (SELECT ca_state
          FROM (SELECT ca_state, SUM(cs_ext_ship_cost) AS sm
                  FROM catalog_sales_history,
                       customer_address
                 WHERE cs_bill_customer_sk = ca_address_sk
                   AND ca_state IS NOT NULL
                 GROUP BY ca_state
                 ORDER BY sm DESC
                 LIMIT 5) t1
     INTERSECT
        SELECT ca_state
          FROM (SELECT ca_state, COUNT(*) AS cnt
                  FROM customer,
                       household_demographics,
                       customer_address
                 WHERE c_current_hdemo_sk = hd_demo_sk
                   AND c_current_addr_sk = ca_address_sk
                   AND hd_income_band_sk >= 15
                   AND ca_state IS NOT NULL
                 GROUP BY ca_state
                 ORDER BY cnt DESC
                 LIMIT 5) t2) t3;
        