DROP TABLE IF EXISTS state;
CREATE TEMPORARY TABLE state
(
    itm          INT,
    multiplicity INT,
    result       CHAR(50),
    returned     BOOLEAN DEFAULT FALSE
);

INSERT INTO state(itm, multiplicity)
SELECT t1.ws_item_sk, COUNT(*) AS multiplicity
  FROM (SELECT ws_item_sk, COUNT(*) cnt FROM web_sales GROUP BY ws_item_sk ORDER BY cnt DESC, ws_item_sk LIMIT 25000) t1
 GROUP BY t1.ws_item_sk;

UPDATE state
   SET result   = (SELECT i_manufact FROM item WHERE i_item_sk = itm),
       returned = TRUE
 WHERE NOT returned;

SELECT s.itm
  FROM state AS s, LATERAL UNNEST(GENERATE_SERIES(1, s.multiplicity))
 WHERE s.result = 'oughtn st';
