SELECT ca.ca_state,
       dd.d_year,
       dd.d_qoy,
       (SELECT _2.retval
          FROM (SELECT (SELECT SUM(cs_net_paid_inc_ship_tax)
                          FROM catalog_sales_history,
                               customer,
                               customer_address,
                               date_dim
                         WHERE cs_bill_customer_sk = c_customer_sk
                           AND c_current_addr_sk = ca_address_sk
                           AND ca_state = ca.ca_state
                           AND cs_net_paid_inc_ship_tax >= 1000
                           AND d_date_sk = cs_sold_date_sk
                           AND d_year = dd.d_year
                           AND d_qoy = dd.d_qoy)) AS _1(largepurchase),
               LATERAL (SELECT _1.largepurchase) AS _2(retval))
  FROM customer_address ca,
       date_dim dd
 WHERE d_year IN (1998, 1999, 2000)
   AND ca_state IS NOT NULL
 GROUP BY ca.ca_state, dd.d_year, dd.d_qoy
 ORDER BY ca.ca_state, dd.d_year, dd.d_qoy;
