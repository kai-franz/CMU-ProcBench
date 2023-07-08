SELECT ws_item_sk
  FROM (SELECT ws_item_sk, COUNT(*) cnt FROM web_sales GROUP BY ws_item_sk ORDER BY cnt DESC, ws_item_sk LIMIT 25000) t1
 WHERE (SELECT _1.retval
          FROM (SELECT i_manufact FROM item WHERE i_item_sk = ws_item_sk) AS _1(retval)) = 'oughtn st';
