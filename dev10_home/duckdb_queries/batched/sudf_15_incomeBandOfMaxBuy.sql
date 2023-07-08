DROP TABLE IF EXISTS state;
CREATE TEMPORARY TABLE state
(
    storenumber  INT,
    incomeband   INT,
    hhdemo       INT,
    clevel       VARCHAR(50),
    p0           BOOLEAN,
    p1           BOOLEAN,
    p2           BOOLEAN,
    p3           BOOLEAN,
    p4           BOOLEAN,
    multiplicity INT,
    result       VARCHAR(50),
    returned     BOOLEAN DEFAULT FALSE
);
INSERT INTO state(storenumber, multiplicity)
SELECT t.s_store_sk, COUNT(*)
  FROM (SELECT s_store_sk FROM store) t
 GROUP BY t.s_store_sk;

UPDATE state
   SET hhdemo = (SELECT MIN(c_current_hdemo_sk)
                   FROM (SELECT c_current_hdemo_sk
                           FROM store_sales_history,
                                customer
                          WHERE ss_store_sk = storenumber
                            AND c_customer_sk = ss_customer_sk
                          GROUP BY ss_customer_sk, c_current_hdemo_sk
                         HAVING COUNT(*) = (SELECT MAX(cnt)
                                              FROM (SELECT COUNT(*) AS cnt
                                                      FROM store_sales_history,
                                                           customer
                                                     WHERE ss_store_sk = storenumber
                                                       AND c_customer_sk = ss_customer_sk
                                                     GROUP BY ss_customer_sk, c_current_hdemo_sk
                                                    HAVING ss_customer_sk IS NOT NULL) tbl)) demos)
 WHERE NOT returned;

UPDATE state
   SET incomeband = (SELECT hd_income_band_sk FROM household_demographics WHERE hd_demo_sk = hhdemo)
 WHERE NOT returned;

UPDATE state
   SET p0 = COALESCE(incomeband >= 0 AND incomeband <= 3, FALSE)
 WHERE NOT returned;

UPDATE state
   SET clevel = 'low'
 WHERE p0
   AND NOT returned;

UPDATE state
   SET p1 = COALESCE(incomeband >= 4 AND incomeband <= 7, FALSE)
 WHERE NOT returned;

UPDATE state
   SET clevel = 'lowerMiddle'
 WHERE p1
   AND NOT returned;

UPDATE state
   SET p2 = COALESCE(incomeband >= 8 AND incomeband <= 11, FALSE)
 WHERE NOT returned;

UPDATE state
   SET clevel = 'upperMiddle'
 WHERE p2
   AND NOT returned;

UPDATE state
   SET p3 = COALESCE(incomeband >= 12 AND incomeband <= 16, FALSE)
 WHERE NOT returned;

UPDATE state
   SET clevel = 'high'
 WHERE p3
   AND NOT returned;

UPDATE state
   SET p4 = COALESCE(incomeband >= 17 AND incomeband <= 20, FALSE)
 WHERE NOT returned;

UPDATE state
   SET clevel = 'affluent'
 WHERE p4
   AND NOT returned;

UPDATE state
   SET result   = clevel,
       returned = TRUE
 WHERE NOT returned;

SELECT s.storenumber
  FROM state AS s, LATERAL UNNEST(GENERATE_SERIES(1, s.multiplicity))
 WHERE s.result = 'lowerMiddle';

