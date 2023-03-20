CREATE OR REPLACE FUNCTION totaldiscount(manufacture_id integer)
RETURNS numeric
LANGUAGE plpgsql
AS $$
DECLARE
    average  DECIMAL;
    addition DECIMAL;
BEGIN
    SELECT AVG(ws_ext_discount_amt)
      INTO average
      FROM web_sales_history,
           item
     WHERE ws_item_sk = i_item_sk
       AND i_manufact_id = manufacture_id;

    SELECT SUM(ws_ext_discount_amt)
      INTO addition
      FROM web_sales_history,
           item
     WHERE ws_item_sk = i_item_sk
       AND i_manufact_id = manufacture_id
       AND ws_ext_discount_amt > 1.3 * average;
    RETURN addition;
END;
$$;