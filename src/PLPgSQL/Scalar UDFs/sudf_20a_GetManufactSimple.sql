CREATE OR REPLACE FUNCTION getManufact_simple(itm INT)
    RETURNS CHAR(50)
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN (SELECT i_manufact FROM item WHERE i_item_sk = itm);
END;
$$;


--complex calling query
SELECT maxsoldItem
  FROM (SELECT ss_item_sk AS maxSoldItem
          FROM (SELECT ss_item_sk, SUM(cnt) totalCnt
                  FROM (SELECT ss_item_sk, COUNT(*) cnt
                          FROM store_sales_history
                         GROUP BY ss_item_sk
                         UNION ALL
                        SELECT cs_item_sk, COUNT(*) cnt
                          FROM catalog_sales_history
                         GROUP BY cs_item_sk
                         UNION ALL
                        SELECT ws_item_sk, COUNT(*) cnt
                          FROM web_sales_history
                         GROUP BY ws_item_sk) t1
                 GROUP BY ss_item_sk) t2
         ORDER BY totalCnt DESC
         LIMIT 25000) t3
 WHERE getManufact_simple(maxSoldItem) = 'oughtn st';


--Simple Calling Query
SELECT ws_item_sk
  FROM (SELECT ws_item_sk, COUNT(*) cnt FROM web_sales GROUP BY ws_item_sk ORDER BY cnt LIMIT 25000) t1
 WHERE getManufact_simple(ws_item_sk) = 'oughtn st';