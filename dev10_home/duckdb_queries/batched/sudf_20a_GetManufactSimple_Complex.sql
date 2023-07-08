DROP TABLE IF EXISTS state;
CREATE TEMPORARY TABLE state
(
    itm          INT,
    multiplicity INT,
    result       CHAR(50),
    returned     BOOLEAN DEFAULT FALSE
);

INSERT INTO state(itm, multiplicity)
SELECT t3.maxsolditem, COUNT(*) AS multiplicity
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
 GROUP BY t3.maxsolditem;

UPDATE state
   SET result   = (SELECT i_manufact FROM item WHERE i_item_sk = itm),
       returned = TRUE
 WHERE NOT returned;

SELECT s.itm
  FROM state AS s, LATERAL UNNEST(GENERATE_SERIES(1, s.multiplicity))
 WHERE s.result = 'oughtn st';
