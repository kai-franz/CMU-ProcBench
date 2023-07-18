DROP TABLE IF EXISTS state;
CREATE TEMPORARY TABLE state
(
    numstates    INT,
    p0           BOOLEAN,
    p1           BOOLEAN,
    p2           BOOLEAN,
    multiplicity INT,
    result       VARCHAR(40),
    returned     BOOLEAN DEFAULT FALSE
);

INSERT INTO state(multiplicity)
SELECT 1 AS multiplicity;

UPDATE state
   SET numstates = 0
 WHERE NOT returned;

UPDATE state
   SET numstates = (SELECT COUNT(*)
                      FROM (SELECT ca_state
                              FROM (SELECT ca_state, SUM(cs_ext_ship_cost) AS sm
                                      FROM catalog_sales_history,
                                           customer_address
                                     WHERE cs_bill_customer_sk = ca_address_sk
                                       AND ca_state IS NOT NULL
                                     GROUP BY ca_state
                                     ORDER BY sm DESC, ca_state
                                     LIMIT 5) t1
                         INTERSECT
                            SELECT ca_state
                              FROM (SELECT ca_state, COUNT(*) AS cnt
                                      FROM customer,
                                           household_demographics,
                                           customer_address
                                     WHERE c_current_hdemo_sk = hd_demo_sk
                                       AND c_current_addr_sk = ca_address_sk
                                       AND hd_income_band_sk >= 15
                                       AND ca_state IS NOT NULL
                                     GROUP BY ca_state
                                     ORDER BY cnt DESC, ca_state
                                     LIMIT 5) t2) t3)
 WHERE NOT returned;

UPDATE state
   SET p0 = COALESCE(numstates >= 4, FALSE)
 WHERE NOT returned;

UPDATE state
   SET result   = 'highly correlated',
       returned = TRUE
 WHERE NOT returned
   AND p0;

UPDATE state
   SET p1 = COALESCE(numstates >= 2 AND numstates <= 3, FALSE)
 WHERE NOT returned;

UPDATE state
   SET result   = 'somewhat correlated',
       returned = TRUE
 WHERE NOT returned
   AND p1;

UPDATE state
   SET p2 = COALESCE(numstates >= 0 AND numstates <= 1, FALSE)
 WHERE NOT returned;

UPDATE state
   SET result   = 'no correlation',
       returned = TRUE
 WHERE NOT returned
   AND p2;

UPDATE state
   SET result   = 'error',
       returned = TRUE
 WHERE NOT returned;

SELECT result
  FROM state AS s, LATERAL UNNEST(GENERATE_SERIES(1, s.multiplicity));
