SELECT _5.retval
  FROM (SELECT 0 AS numstates) _1(numstates),
       LATERAL (SELECT COUNT(*)
                  FROM (SELECT ca_state
                          FROM (SELECT ca_state, SUM(ws_ext_ship_cost) AS sm
                                  FROM web_sales_history,
                                       customer_address
                                 WHERE ws_bill_customer_sk = ca_address_sk
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
                                 LIMIT 5) t2) t3) AS _2(numstates),
       LATERAL (SELECT CASE
                           WHEN (_2.numstates >= 4) THEN 'highly correlated'
                           ELSE (SELECT _3.retval
                                   FROM (SELECT CASE
                                                    WHEN (_2.numstates >= 2 AND _2.numstates <= 3)
                                                        THEN 'somewhat correlated'
                                                    ELSE (SELECT _4.retval
                                                            FROM (SELECT CASE
                                                                             WHEN (_2.numstates >= 0 AND _2.numstates <= 1)
                                                                                 THEN 'no correlation'
                                                                             ELSE 'error' END) AS _4(retval))
                                                    END) AS _3(retval))
                           END) AS _5(retval);