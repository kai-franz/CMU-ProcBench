SELECT DISTINCT i.i_manufact_id,
                (SELECT _3.retval
                   FROM (SELECT (SELECT CAST(AVG(ws_ext_discount_amt) AS DECIMAL(15, 2))
                                   FROM web_sales_history,
                                        item
                                  WHERE ws_item_sk = i_item_sk
                                    AND i_manufact_id = i.i_manufact_id)) AS _1(average),
                        LATERAL (SELECT (SELECT SUM(ws_ext_discount_amt)
                                           FROM web_sales_history,
                                                item
                                          WHERE ws_item_sk = i_item_sk
                                            AND i_manufact_id = i.i_manufact_id
                                            AND ws_ext_discount_amt > 1.3 * _1.average)) AS _2(addition),
                        LATERAL (SELECT _2.addition) AS _3(retval)) AS totaldisc
  FROM item i;