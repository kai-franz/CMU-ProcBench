DROP TABLE IF EXISTS state;
CREATE TEMPORARY TABLE state
(
    givenstate    CHAR(2),
    amount        DECIMAL,
    yr            INT,
    qtr           INT,
    largepurchase DECIMAL,
    multiplicity  INT,
    result        DECIMAL,
    returned      BOOLEAN DEFAULT FALSE
);
INSERT INTO state(givenstate, amount, yr, qtr, multiplicity)
SELECT t.givenstate, t.amount, t.yr, t.qtr, COUNT(*) AS multiplicity
  FROM (SELECT ca_state AS givenstate, 1000 AS amount, d_year AS yr, d_qoy AS qtr
          FROM customer_address,
               date_dim
         WHERE d_year IN (1998, 1999, 2000)
           AND ca_state IS NOT NULL
         GROUP BY ca_state, d_year, d_qoy
         ORDER BY ca_state, d_year, d_qoy) t
 GROUP BY t.givenstate, t.amount, t.yr, t.qtr;

UPDATE state
   SET largepurchase = (SELECT SUM(cs_net_paid_inc_ship_tax)
                          FROM catalog_sales_history,
                               customer,
                               customer_address,
                               date_dim
                         WHERE cs_bill_customer_sk = c_customer_sk
                           AND c_current_addr_sk = ca_address_sk
                           AND ca_state = givenstate
                           AND cs_net_paid_inc_ship_tax >= amount
                           AND d_date_sk = cs_sold_date_sk
                           AND d_year = yr
                           AND d_qoy = qtr)
 WHERE NOT returned;

UPDATE state
   SET result   = largepurchase,
       returned = TRUE
 WHERE NOT returned;

SELECT s.givenstate, s.yr, s.qtr, s.result
  FROM state AS s, LATERAL UNNEST(GENERATE_SERIES(1, s.multiplicity));
