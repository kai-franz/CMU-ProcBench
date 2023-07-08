SELECT s_store_sk
  FROM store
 WHERE (SELECT _10.retval
          FROM (SELECT (SELECT MIN(c_current_hdemo_sk)
                          FROM (SELECT c_current_hdemo_sk
                                  FROM store_sales_history,
                                       customer
                                 WHERE ss_store_sk = s_store_sk
                                   AND c_customer_sk = ss_customer_sk
                                 GROUP BY ss_customer_sk, c_current_hdemo_sk
                                HAVING COUNT(*) = (SELECT MAX(cnt)
                                                     FROM (SELECT COUNT(*) AS cnt
                                                             FROM store_sales_history,
                                                                  customer
                                                            WHERE ss_store_sk = s_store_sk
                                                              AND c_customer_sk = ss_customer_sk
                                                            GROUP BY ss_customer_sk, c_current_hdemo_sk
                                                           HAVING ss_customer_sk IS NOT NULL) tbl)) demo)) AS _1(hhdemo),
               LATERAL (SELECT hd_income_band_sk
                          FROM household_demographics
                         WHERE hd_demo_sk = _1.hhdemo) AS _2(incomeband),
               LATERAL (SELECT CASE
                                   WHEN (incomeband >= 0 AND incomeband <= 3) THEN 'low'
                                   ELSE (SELECT _3.retval
                                           FROM (SELECT CASE
                                                            WHEN (incomeband >= 4 AND incomeband <= 7)
                                                                THEN 'lowerMiddle'
                                                            ELSE (SELECT _4.retval
                                                                    FROM (SELECT CASE
                                                                                     WHEN (incomeband >= 8 AND incomeband <= 11)
                                                                                         THEN 'upperMiddle'
                                                                                     ELSE (SELECT _5.retval
                                                                                             FROM (SELECT CASE
                                                                                                              WHEN (incomeband >= 12 AND incomeband <= 16)
                                                                                                                  THEN 'high'
                                                                                                              ELSE (SELECT _6.retval
                                                                                                                      FROM (SELECT CASE WHEN (incomeband >= 17 AND incomeband <= 20) THEN 'affluent' END) AS _6(retval)) END) _5(retval)) END) AS _4(retval)) END) AS _3(retval))
                                   END) AS _10(retval)) = 'lowerMiddle'
 ORDER BY s_store_sk;