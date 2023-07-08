SELECT c_customer_sk,
       (SELECT _6.retval
          FROM (SELECT (SELECT COUNT(*)
                          FROM store_sales_history
                         WHERE ss_customer_sk = c_customer_sk
                           AND ss_sold_date_sk >= 2451545
                           AND ss_sold_date_sk <= 2459215)) AS _1(numsalesfromstore),
               LATERAL (SELECT (SELECT COUNT(*)
                                  FROM catalog_sales_history
                                 WHERE cs_bill_customer_sk = c_customer_sk
                                   AND cs_sold_date_sk >= 2451545
                                   AND cs_sold_date_sk <= 2459215)) AS _2(numsalesfromcatalog),
               LATERAL (SELECT (SELECT COUNT(*)
                                  FROM web_sales_history
                                 WHERE ws_bill_customer_sk = c_customer_sk
                                   AND ws_sold_date_sk >= 2451545
                                   AND ws_sold_date_sk <= 2459215)) AS _3(numsalesfromweb),
               LATERAL (SELECT CASE
                                   WHEN _1.numsalesfromstore > _2.numsalesfromcatalog THEN (SELECT _4.retval
                                                                                              FROM (SELECT CASE
                                                                                                               WHEN _3.numsalesfromweb > _1.numsalesfromstore
                                                                                                                   THEN 'Web'
                                                                                                               ELSE 'Store' END) AS _4(retval))
                                   ELSE (SELECT _5.retval
                                           FROM (SELECT CASE
                                                            WHEN _3.numsalesfromweb > _2.numsalesfromcatalog THEN 'Web'
                                                            ELSE 'Catalog' END) AS _5(retval)) END) AS _6(retval)) AS channel
  FROM customer;