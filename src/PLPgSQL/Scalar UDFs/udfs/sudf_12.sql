CREATE OR REPLACE FUNCTION increaseinwebspending(cust_sk integer)
RETURNS numeric
LANGUAGE plpgsql
AS $$
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