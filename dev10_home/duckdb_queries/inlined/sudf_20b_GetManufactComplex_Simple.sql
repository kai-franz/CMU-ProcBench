
SELECT ws_item_sk
  FROM (SELECT ws_item_sk, COUNT(*) cnt FROM web_sales GROUP BY ws_item_sk ORDER BY cnt DESC, ws_item_sk LIMIT 25000) t1
 WHERE (SELECT _4.retval
          FROM (SELECT '' AS man) AS _1(man),
               LATERAL (SELECT COUNT(*)
                          FROM store_sales_history,
                               date_dim
                         WHERE ss_item_sk = ws_item_sk
                           AND d_date_sk = ss_sold_date_sk
                           AND d_year = 2003) AS _2(cnt1),
               LATERAL (SELECT COUNT(*)
                          FROM catalog_sales_history,
                               date_dim
                         WHERE cs_item_sk = ws_item_sk
                           AND d_date_sk = cs_sold_date_sk
                           AND d_year = 2003) AS _3(cnt2),
               LATERAL (SELECT CASE
                                   WHEN _2.cnt1 > 0 AND _3.cnt2 > 0
                                       THEN (SELECT i_manufact FROM item WHERE i_item_sk = ws_item_sk)
                                   ELSE (SELECT 'outdated item') END) AS _4(retval)) = 'oughtn st';

