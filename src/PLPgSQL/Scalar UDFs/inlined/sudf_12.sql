
SELECT cust_sk, increaseInSpending
  FROM (SELECT t1.cust_sk,
               spending1 - spending2 AS increaseInSpending
          FROM ((SELECT SUM(ws_net_paid_inc_ship_tax) AS spending1, ws_bill_customer_sk AS cust_sk
                   FROM web_sales_history,
                        date_dim
                  WHERE d_date_sk = ws_sold_date_sk
                    AND d_year = 2001
                  GROUP BY ws_bill_customer_sk) t1
              INNER JOIN
              (SELECT SUM(ws_net_paid_inc_ship_tax) AS spending2, ws_bill_customer_sk AS cust_sk
                 FROM web_sales_history,
                      date_dim
                WHERE d_date_sk = ws_sold_date_sk
                  AND d_year = 2000
                GROUP BY ws_bill_customer_sk) t2
                ON t1.cust_sk = t2.cust_sk)
         WHERE t1.cust_sk IN
               (SELECT ws_bill_customer_sk
                  FROM web_sales_history,
                       date_dim
                 WHERE d_date_sk = ws_sold_date_sk
                   AND d_year = 2000
                   AND ws_bill_customer_sk IS NOT NULL
             INTERSECT
                SELECT ws_bill_customer_sk
                  FROM web_sales_history,
                       date_dim
                 WHERE d_date_sk = ws_sold_date_sk
                   AND d_year = 2001
                   AND ws_bill_customer_sk IS NOT NULL)) t3
 WHERE increaseInSpending > 0;
        