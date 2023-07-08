
SELECT c_customer_sk,
       (SELECT _8.retval
          FROM (SELECT 0 AS numweb) AS _1(numweb),
               LATERAL (SELECT 0 AS numstore) AS _2(numstore),
               LATERAL (SELECT 0 AS numcat) AS _3(numcat),
               LATERAL (SELECT (SELECT COUNT(*)
                                  FROM web_sales_history
                                 WHERE ws_bill_customer_sk = c_customer_sk) AS numweb) AS _4(numweb),
               LATERAL (SELECT (SELECT COUNT(*)
                                  FROM store_sales_history
                                 WHERE ss_customer_sk = c_customer_sk) AS numstore) AS _5(numstore),
               LATERAL (SELECT (SELECT COUNT(*)
                                  FROM catalog_sales_history
                                 WHERE cs_bill_customer_sk = c_customer_sk) AS numcat) AS _6(numcat),
               LATERAL (SELECT CASE
                                   WHEN (_4.numweb >= _5.numstore AND _4.numweb >= _6.numcat) THEN 'web'
                                   ELSE (SELECT _7.retval
                                           FROM (SELECT CASE
                                                            WHEN (_5.numstore >= _4.numweb AND _5.numstore >= _6.numcat)
                                                                THEN 'store'
                                                            ELSE (SELECT _8.retval
                                                                    FROM (SELECT CASE
                                                                                     WHEN (_6.numcat >= _5.numstore AND _6.numcat >= _4.numweb)
                                                                                         THEN 'Catalog'
                                                                                     ELSE 'Logical Error' END) AS _8(retval)) END) AS _7(retval))
                                   END) AS _8(retval))
  FROM customer;
