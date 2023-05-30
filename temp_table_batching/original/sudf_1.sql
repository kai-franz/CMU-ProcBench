--Report the total catalog sales for customers from a given state who made purchases of 
-- more than a given amount in a given year and quarter.

CREATE OR ALTER FUNCTION totalLargePurchases(@givenState CHAR(2), @amount DECIMAL(7, 2), @ yr INT, @ qtr INT)
    RETURNS DECIMAL(15, 2)
AS
BEGIN
    RETURN
        (SELECT SUM(cs_net_paid_inc_ship_tax)
           FROM catalog_sales_history,
                customer,
                customer_address,
                date_dim
          WHERE cs_bill_customer_sk = c_customer_sk
            AND c_current_addr_sk = ca_address_sk
            AND d_date_sk = cs_sold_date_sk
            AND ca_state = @givenState
            AND cs_net_paid_inc_ship_tax >= @amount
            AND d_year = @yr
            AND d_qoy = @qtr)
END
GO


--invocation query
SELECT ca_state, d_year, d_qoy, dbo.totalLargePurchases(ca_state, 1000, d_year, d_qoy)
  FROM customer_address,
       date_dim
 WHERE d_year IN (1998, 1999, 2000)
   AND ca_state IS NOT NULL
 GROUP BY ca_state, d_year, d_qoy
 ORDER BY ca_state, d_year, d_qoy;