--Of the customers who purchased from web in both years 2000 and 2001, find positive increase in spending from one year to the other.

CREATE OR REPLACE FUNCTION increaseInWebSpending(cust_sk INT)
    RETURNS DECIMAL
    LANGUAGE plpgsql
AS
$$
DECLARE
    spending1 DECIMAL;
    spending2 DECIMAL;
    increase  DECIMAL;
BEGIN
    spending1 := 0;
    spending2 := 0;
    increase := 0;

    SELECT SUM(ws_net_paid_inc_ship_tax)
      INTO spending1
      FROM web_sales_history,
           date_dim
     WHERE d_date_sk = ws_sold_date_sk
       AND d_year = 2001
       AND ws_bill_customer_sk = cust_sk;

    SELECT SUM(ws_net_paid_inc_ship_tax)
      INTO spending2
      FROM web_sales_history,
           date_dim
     WHERE d_date_sk = ws_sold_date_sk
       AND d_year = 2000
       AND ws_bill_customer_sk = cust_sk;

    IF (spending1 < spending2) THEN
        RETURN -1;
    ELSE
        increase := spending1 - spending2;
    END IF;
    RETURN increase;

END;
$$;


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
   AND increaseInWebSpending(c_customer_sk) > 0;