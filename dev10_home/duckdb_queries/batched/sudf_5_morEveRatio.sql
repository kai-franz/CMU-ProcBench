DROP TABLE IF EXISTS state;
CREATE TEMPORARY TABLE state
(
    dep          INT,
    morningsale  INT,
    eveningsale  INT,
    ratio        FLOAT,
    multiplicity INT,
    result       FLOAT,
    returned     BOOLEAN DEFAULT FALSE
);
INSERT INTO state(dep, multiplicity)
SELECT t.depcount, COUNT(*) AS multiplicity
  FROM (SELECT DISTINCT cd_dep_count AS depcount FROM customer_demographics) t
 GROUP BY t.depcount;

UPDATE state
   SET morningsale = (SELECT COUNT(*)
                        FROM web_sales_history,
                             time_dim,
                             customer_demographics
                       WHERE ws_sold_time_sk = t_time_sk
                         AND ws_bill_customer_sk = cd_demo_sk
                         AND t_hour >= 8
                         AND t_hour <= 9
                         AND cd_dep_count = dep)
 WHERE NOT returned;

UPDATE state
   SET eveningsale = (SELECT COUNT(*)
                        FROM web_sales_history,
                             time_dim,
                             customer_demographics
                       WHERE ws_sold_time_sk = t_time_sk
                         AND ws_bill_customer_sk = cd_demo_sk
                         AND t_hour >= 19
                         AND t_hour <= 20
                         AND cd_dep_count = dep)
 WHERE NOT returned;

UPDATE state
   SET ratio = (morningsale::FLOAT) / (eveningsale::FLOAT)
 WHERE NOT returned;


UPDATE state
   SET result   = ratio,
       returned = TRUE
 WHERE NOT returned;

SELECT s.dep, s.result
  FROM state AS s, LATERAL UNNEST(GENERATE_SERIES(1, s.multiplicity));
