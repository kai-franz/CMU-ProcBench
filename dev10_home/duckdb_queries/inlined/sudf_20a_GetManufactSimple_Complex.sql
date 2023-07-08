SELECT maxsolditem
  FROM (SELECT ss_item_sk AS maxsolditem
          FROM (SELECT ss_item_sk, SUM(cnt) totalcnt
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
         ORDER BY totalcnt DESC, ss_item_sk
         LIMIT 25000) t3
 WHERE (SELECT _1.retval
          FROM (SELECT i_manufact FROM item WHERE i_item_sk = maxsolditem) AS _1(retval)) = 'oughtn st';