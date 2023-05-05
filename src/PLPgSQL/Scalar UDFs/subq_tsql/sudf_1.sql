CREATE TABLE #temp
(
    givenstate    CHAR(2),
    yr            INTEGER,
    qtr           INTEGER,
    largepurchase DECIMAL(17, 2)
);

INSERT INTO #temp (givenstate, yr, qtr)
SELECT ca_state
     , d_year
     , d_qoy
  FROM customer_address,
       date_dim
 WHERE d_year IN (1998, 1999, 2000)
   AND (ca_state IS NOT NULL)
 GROUP BY ca_state, d_year, d_qoy
 ORDER BY ca_state
        , d_year
        , d_qoy;

UPDATE #temp
   SET largepurchase = (SELECT SUM(cs_net_paid_inc_ship_tax) AS agg_0
                          FROM catalog_sales_history,
                               customer,
                               customer_address,
                               date_dim
                         WHERE (cs_bill_customer_sk = c_customer_sk)
                           AND (c_current_addr_sk = ca_address_sk)
                           AND (ca_state = givenstate)
                           AND (cs_net_paid_inc_ship_tax >= 1000)
                           AND (d_date_sk = cs_sold_date_sk)
                           AND (d_year = yr)
                           AND (d_qoy = qtr));

SELECT givenstate, yr, qtr, largepurchase
  FROM #temp;

DROP TABLE #temp;