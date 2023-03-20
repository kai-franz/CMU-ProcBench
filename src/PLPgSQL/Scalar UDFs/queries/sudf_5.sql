SELECT t.depcount
     , morningtoeveratio(t.depcount)
FROM (SELECT DISTINCT cd_dep_count AS depcount
      FROM customer_demographics) AS t;