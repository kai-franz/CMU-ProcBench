-- Find out the increase in web spending by a given customer from year 2000 to 2001. 

CREATE OR ALTER FUNCTION increaseInWebSpending(@cust_sk INT)
    RETURNS DECIMAL(15, 2)
AS
BEGIN
    DECLARE @spending1 DECIMAL(15, 2)=0;
    DECLARE @spending2 DECIMAL(15, 2)=0;
    DECLARE @increase DECIMAL(15, 2)=0;
    SET @spending1 = (SELECT SUM(ws_net_paid_inc_ship_tax)
                        FROM web_sales_history,
                             date_dim
                       WHERE d_date_sk = ws_sold_date_sk
                         AND d_year = 2001
                         AND ws_bill_customer_sk = @cust_sk);
    SET @spending2 = (SELECT SUM(ws_net_paid_inc_ship_tax)
                        FROM web_sales_history,
                             date_dim
                       WHERE d_date_sk = ws_sold_date_sk
                         AND d_year = 2000
                         AND ws_bill_customer_sk = @cust_sk);
    IF (@spending1 < @spending2)
        RETURN -1;
    ELSE
        SET @increase = @spending1 - @spending2;
    RETURN @increase;

END
GO

--invocation query
SELECT t.ws_bill_customer_sk
  FROM (SELECT ws_bill_customer_sk
          FROM web_sales_history,
               date_dim
         WHERE d_date_sk = ws_sold_date_sk
           AND d_year = 2000
           AND d_moy = 1
           AND ws_bill_customer_sk IS NOT NULL

     INTERSECT

        SELECT ws_bill_customer_sk
          FROM web_sales_history,
               date_dim
         WHERE d_date_sk = ws_sold_date_sk
           AND d_year = 2001
           AND d_moy = 1
           AND ws_bill_customer_sk IS NOT NULL) t
 WHERE dbo.increaseInWebSpending(t.ws_bill_customer_sk) > 0;
