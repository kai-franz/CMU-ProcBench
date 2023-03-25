CREATE OR REPLACE FUNCTION getManufact_complex(itm INT)
    RETURNS CHAR(50)
    LANGUAGE plpgsql
AS
$$
DECLARE
    man  CHAR(50);
    cnt1 INT; cnt2 INT;
BEGIN
    man := '';
    -- was this item sold in this year through store or catalog?
    cnt1 := (SELECT COUNT(*)
               FROM store_sales_history,
                    date_dim
              WHERE ss_item_sk = itm
                AND d_date_sk = ss_sold_date_sk
                AND d_year = 2003);
    cnt2 := (SELECT COUNT(*)
               FROM catalog_sales_history,
                    date_dim
              WHERE cs_item_sk = itm
                AND d_date_sk = cs_sold_date_sk
                AND d_year = 2003);
    IF (cnt1 > 0 AND cnt2 > 0) THEN
        man := (SELECT i_manufact FROM item WHERE i_item_sk = itm);
    ELSE
        man := 'outdated item'; --implies that this item is not sold in a recent year at all and is probably outdated
    END IF;
    RETURN man;
END;
$$;

--Complex Calling Query
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
 WHERE getManufact_complex(maxSoldItem) = 'oughtn st';

--Simple Calling Query
SELECT ws_item_sk
  FROM (SELECT ws_item_sk, COUNT(*) cnt FROM web_sales GROUP BY ws_item_sk ORDER BY cnt LIMIT 25000) t1
 WHERE getManufact_complex(ws_item_sk) = 'oughtn st';