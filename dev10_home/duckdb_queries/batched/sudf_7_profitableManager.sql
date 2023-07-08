DROP TABLE IF EXISTS state;
CREATE TEMPORARY TABLE state
(
    manager      VARCHAR(40),
    yr           INT,
    netprofit    DECIMAL(15, 2),
    p0           BOOLEAN,
    multiplicity INT,
    result       INT,
    returned     BOOLEAN DEFAULT FALSE
);
INSERT INTO state(manager, yr, multiplicity)
SELECT t1.manager, t1.yr, COUNT(*) AS multiplicity
  FROM (SELECT s_manager AS manager, 2001 AS yr FROM store) t1
 GROUP BY t1.manager, t1.yr;

UPDATE state
   SET netprofit = (SELECT SUM(ss_net_profit)
                      FROM store,
                           store_sales_history,
                           date_dim
                     WHERE ss_sold_date_sk = d_date_sk
                       AND d_year = yr
                       AND s_manager = manager
                       AND s_store_sk = ss_store_sk)
 WHERE NOT returned;

UPDATE state
   SET p0 = COALESCE(netprofit > 0, FALSE)
 WHERE NOT returned;

UPDATE state
   SET result   = 1,
       returned = TRUE
 WHERE NOT returned
   AND p0;

UPDATE state
   SET result   = 0,
       returned = TRUE
 WHERE NOT returned
   AND NOT p0 = TRUE;

SELECT manager
  FROM state AS s, LATERAL UNNEST(GENERATE_SERIES(1, s.multiplicity))
 WHERE s.result <= 0;
