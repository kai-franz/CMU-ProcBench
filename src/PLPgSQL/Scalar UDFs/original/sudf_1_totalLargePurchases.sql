--Report the total catalog sales for customers from a given state who made purchases of 
-- more than a given amount for a given year and quarter.

CREATE OR REPLACE FUNCTION totalLargePurchases(givenState CHAR, amount DECIMAL, yr INT, qtr INT)
    RETURNS DECIMAL
    LANGUAGE plpgsql
AS
$$
DECLARE
    largePurchase DECIMAL;
BEGIN
    SELECT SUM(cs_net_paid_inc_ship_tax)
      INTO largePurchase
      FROM catalog_sales_history,
           customer,
           customer_address,
           date_dim
     WHERE cs_bill_customer_sk = c_customer_sk
       AND c_current_addr_sk = ca_address_sk
       AND ca_state = givenState
       AND cs_net_paid_inc_ship_tax >= amount
       AND d_date_sk = cs_sold_date_sk
       AND d_year = yr
       AND d_qoy = qtr;
    RETURN largePurchase;
END;
$$;

--invocation query
SELECT ca_state, d_year, d_qoy, totalLargePurchases(ca_state, 1000, d_year, d_qoy)
  FROM customer_address,
       date_dim
 WHERE d_year IN (1998, 1999, 2000)
   AND ca_state IS NOT NULL
 GROUP BY ca_state, d_year, d_qoy
 ORDER BY ca_state, d_year, d_qoy;