SELECT c_customer_sk
  FROM customer
 WHERE c_customer_sk IN
       (SELECT ws_bill_customer_sk
          FROM web_sales_history,
               date_dim
         WHERE d_date_sk = ws_sold_date_sk
           AND d_year = 2000

     INTERSECT

        SELECT ws_bill_customer_sk
          FROM web_sales_history,
               date_dim
         WHERE d_date_sk = ws_sold_date_sk
           AND d_year = 2001)
   AND (SELECT _6.retval
          FROM (SELECT 0 AS spending1) AS _1(spending1),
               LATERAL (SELECT 0 AS spending2) AS _2(spending2),
               LATERAL (SELECT 0 AS increase) AS _3(incresase),
               LATERAL (SELECT (SELECT SUM(ws_net_paid_inc_ship_tax)
                                  FROM web_sales_history,
                                       date_dim
                                 WHERE d_date_sk = ws_sold_date_sk
                                   AND d_year = 2001
                                   AND ws_bill_customer_sk = c_customer_sk)) AS _4(spending1),
               LATERAL (SELECT (SELECT SUM(ws_net_paid_inc_ship_tax)
                                  FROM web_sales_history,
                                       date_dim
                                 WHERE d_date_sk = ws_sold_date_sk
                                   AND d_year = 2000
                                   AND ws_bill_customer_sk = c_customer_sk)) AS _5(spending2),
               LATERAL (SELECT CASE
                                   WHEN _4.spending1 < _5.spending2 THEN -1
                                   ELSE _4.spending1 - _5.spending2 END) AS _6(retval)) > 0;