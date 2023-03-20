
SELECT DISTINCT item.i_manufact_id,
                CASE WHEN item.i_manufact_id IS NOT NULL THEN SUM(ws_ext_discount_amt) END AS totalDisc
  FROM web_sales_history
           LEFT OUTER JOIN item
           LEFT OUTER JOIN (SELECT i_manufact_id, AVG(ws_ext_discount_amt) AS avgDisc
                              FROM web_sales_history,
                                   item
                             WHERE ws_item_sk = i_item_sk
                             GROUP BY i_manufact_id) AS average
                           ON item.i_manufact_id = average.i_manufact_id
                           ON web_sales_history.ws_item_sk = item.i_item_sk
 WHERE average.avgDisc IS NULL
    OR ws_ext_discount_amt > 1.3 * average.avgDisc
 GROUP BY item.i_manufact_id;
