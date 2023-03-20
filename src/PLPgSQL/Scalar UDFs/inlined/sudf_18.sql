
            SELECT c_customer_sk, (SELECT (CASE WHEN (E1.numWeb >= E2.numStore and E1.numWeb >= E3.numCat) THEN 'Web'
             WHEN (E2.numStore >= E1.numWeb and E2.numStore >= E3.numCat) THEN 'Store'
             WHEN (E3.numCat >= E2.numStore and E3.numCat >= E1.numWeb) THEN 'Catalog'
             ELSE 'Logical Error'
         END) FROM
    (SELECT SUM(ws_net_paid_inc_ship_tax) AS numWeb FROM web_sales_history WHERE ws_bill_customer_sk = c_customer_sk
      AND EXISTS (select * from web_sales_history where ws_bill_customer_sk = c_customer_sk)) AS E1,
    (SELECT SUM(ss_net_paid_inc_tax) AS numStore FROM store_sales_history WHERE ss_customer_sk = c_customer_sk
      AND EXISTS (select * from store_sales_history where ss_customer_sk = c_customer_sk)) AS E2,
    (SELECT sum(cs_net_paid_inc_ship_tax) AS numCat FROM catalog_sales_history WHERE cs_bill_customer_sk = c_customer_sk
     AND EXISTS (select * from catalog_sales_history where cs_bill_customer_sk = c_customer_sk)) AS E3)
 FROM customer;
            