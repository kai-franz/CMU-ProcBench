
            SELECT c_customer_sk,
               CASE
                   WHEN (numWeb >= numStore AND numWeb >= numCat) THEN 'web'
                   ELSE
                       (CASE
                            WHEN (numStore >= numWeb AND numStore >= numCat) THEN 'store'
                            ELSE
                                (CASE
                                     WHEN (numCat >= numStore AND numCat >= numWeb) THEN 'Catalog'
                                     ELSE 'Logical error' END) END)
                   END
                   AS preferredChannel
          FROM (customer LEFT OUTER JOIN
              (SELECT ss_customer_sk, COUNT(*) AS numStore
                 FROM store_sales_history AS ss_history
                GROUP BY ss_customer_sk) AS e1
                  LEFT OUTER JOIN
                  (SELECT cs_bill_customer_sk, COUNT(*) AS numCat
                     FROM catalog_sales_history AS cs_history
                    GROUP BY cs_bill_customer_sk) AS e2
                      LEFT OUTER JOIN
                      (SELECT ws_bill_customer_sk, COUNT(*) AS numWeb
                         FROM web_sales_history AS ws_history
                        GROUP BY ws_bill_customer_sk) AS e3
                      ON cs_bill_customer_sk = ws_bill_customer_sk
                  ON ss_customer_sk = cs_bill_customer_sk
                ON c_customer_sk = ss_customer_sk);
        