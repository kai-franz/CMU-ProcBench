DROP TABLE IF EXISTS state;
CREATE TEMPORARY TABLE state
(
    manufacture_id INT,
    average        DECIMAL(15, 2),
    addition       DECIMAL(15, 2),
    multiplicity   INT,
    result         DECIMAL(15, 2),
    returned       BOOLEAN DEFAULT FALSE
);
INSERT INTO state(manufacture_id, multiplicity)
SELECT t.id, COUNT(*) AS multiplicity
  FROM (SELECT i_manufact_id AS id FROM item) t
 GROUP BY t.id;

UPDATE state
   SET average = (SELECT AVG(ws_ext_discount_amt)
                    FROM web_sales_history,
                         item
                   WHERE ws_item_sk = i_item_sk
                     AND i_manufact_id = manufacture_id)
 WHERE NOT returned;

UPDATE state
   SET addition = (SELECT SUM(ws_ext_discount_amt)
                     FROM web_sales_history,
                          item
                    WHERE ws_item_sk = i_item_sk
                      AND i_manufact_id = manufacture_id
                      AND ws_ext_discount_amt > 1.3 * average)
 WHERE NOT returned;

UPDATE state
   SET result   = addition,
       returned = TRUE
 WHERE NOT returned;

SELECT DISTINCT s.manufacture_id, s.result AS totaldisc
  FROM state AS s, LATERAL UNNEST(GENERATE_SERIES(1, s.multiplicity));
