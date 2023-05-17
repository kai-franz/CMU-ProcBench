CREATE OR REPLACE FUNCTION getManufact_simple(itm INT)
    RETURNS CHAR(50)
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN (SELECT i_manufact FROM item WHERE i_item_sk = itm);
END;
$$;

--Simple Calling Query
SELECT ws_item_sk
  FROM (SELECT ws_item_sk, COUNT(*) cnt FROM web_sales GROUP BY ws_item_sk ORDER BY cnt LIMIT 25000) t1
 WHERE getManufact_simple(ws_item_sk) = 'oughtn st';