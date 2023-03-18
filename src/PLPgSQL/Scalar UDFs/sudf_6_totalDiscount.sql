--Compute the total discount on web sales of items from a given manufacturer for
--sales whose discount exceeded 30% over the average discount of items from that manufacturer.

CREATE OR REPLACE FUNCTION totalDiscount(manufacture_id INT)
    RETURNS DECIMAL
    LANGUAGE plpgsql
AS
$$
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

SELECT DISTINCT i_manufact_id, totalDiscount(i_manufact_id) AS totalDisc
  FROM item;