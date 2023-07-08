DROP TABLE IF EXISTS state;
CREATE TEMPORARY TABLE state
(
    reason_desc  CHAR(100),
    multiplicity INT,
    result       CHAR(100),
    returned     BOOLEAN DEFAULT FALSE
);

INSERT INTO state(multiplicity)
SELECT 1;

UPDATE state
   SET reason_desc = (SELECT dt1.r_reason_desc
                        FROM (SELECT r_reason_desc, COUNT(*) AS cnt
                                FROM catalog_returns_history,
                                     reason
                               WHERE cr_reason_sk = r_reason_sk
                               GROUP BY r_reason_id, r_reason_desc) dt1
                       WHERE dt1.cnt = (SELECT MAX(cnt)
                                          FROM (SELECT COUNT(*) AS cnt
                                                  FROM catalog_returns_history,
                                                       reason
                                                 WHERE cr_reason_sk = r_reason_sk
                                                 GROUP BY r_reason_id, r_reason_desc) dt2))
 WHERE NOT returned;

UPDATE state
   SET result   = reason_desc,
       returned = TRUE
 WHERE NOT returned;

SELECT s.result
  FROM state AS s, LATERAL UNNEST(GENERATE_SERIES(1, s.multiplicity));
