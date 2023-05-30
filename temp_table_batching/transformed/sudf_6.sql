CREATE TABLE #temp
(
    manufacture_id int,
    average decimal(15,2),
    addition decimal(15,2)
);

INSERT INTO #temp (manufacture_id)
SELECT DISTINCT i_manufact_id
            FROM item;


UPDATE #temp
   SET average = (SELECT avg(ws_ext_discount_amt) AS agg_0
                       FROM web_sales_history, item
                       WHERE (ws_item_sk = i_item_sk)
                         AND (i_manufact_id = manufacture_id));
UPDATE #temp
   SET addition = (SELECT sum(ws_ext_discount_amt) AS agg_0
                       FROM web_sales_history, item
                       WHERE (ws_item_sk = i_item_sk)
                         AND (i_manufact_id = manufacture_id)
                         AND (ws_ext_discount_amt > ((1.3 * average))))

SELECT manufacture_id, addition from #temp;

DROP TABLE #temp;
