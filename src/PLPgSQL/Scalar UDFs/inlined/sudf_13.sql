  WITH store_sales_count AS (SELECT ss_customer_sk, COUNT(*) AS store_count
                               FROM store_sales_history
                              WHERE ss_sold_date_sk BETWEEN 2451545 AND 2459215
                              GROUP BY ss_customer_sk),
       catalog_sales_count AS (SELECT cs_bill_customer_sk, COUNT(*) AS catalog_count
                                 FROM catalog_sales_history
                                WHERE cs_sold_date_sk BETWEEN 2451545 AND 2459215
                                GROUP BY cs_bill_customer_sk),
       web_sales_count AS (SELECT ws_bill_customer_sk, COUNT(*) AS web_count
                             FROM web_sales_history
                            WHERE ws_sold_date_sk BETWEEN 2451545 AND 2459215
                            GROUP BY ws_bill_customer_sk),
       combined_counts AS (SELECT c_customer_sk,
                                  COALESCE(store_count, 0)   AS store_count,
                                  COALESCE(catalog_count, 0) AS catalog_count,
                                  COALESCE(web_count, 0)     AS web_count
                             FROM customer c
                                      LEFT JOIN store_sales_count s ON c.c_customer_sk = s.ss_customer_sk
                                      LEFT JOIN catalog_sales_count ca ON c.c_customer_sk = ca.cs_bill_customer_sk
                                      LEFT JOIN web_sales_count w ON c.c_customer_sk = w.ws_bill_customer_sk)

SELECT c_customer_sk,
       CASE
           WHEN COALESCE(store_count, 0) > COALESCE(catalog_count, 0) AND
                COALESCE(store_count, 0) >= COALESCE(web_count, 0) THEN 'Store'
           WHEN COALESCE(catalog_count, 0) >= COALESCE(store_count, 0) AND
                COALESCE(catalog_count, 0) >= COALESCE(web_count, 0) THEN 'Catalog'
           WHEN COALESCE(web_count, 0) >= COALESCE(store_count, 0) AND
                COALESCE(web_count, 0) >= COALESCE(catalog_count, 0) THEN 'Web'
           END AS channel
  FROM combined_counts;

