--What is the ratio between the number of items sold over the internet in the morning (8 to 9am) to the number of
--items sold in the evening (7 to 8pm) of customers with a specified number of dependents. 

CREATE OR REPLACE FUNCTION morningToEveRatio(dep INT)
    RETURNS FLOAT
    LANGUAGE plpgsql
AS
$$
DECLARE
    morningSale         INT;
    DECLARE eveningSale INT;
    DECLARE ratio       FLOAT;
BEGIN
    morningSale := (SELECT COUNT(*)
                      FROM web_sales_history,
                           time_dim,
                           customer_demographics
                     WHERE ws_sold_time_sk = t_time_sk
                       AND ws_bill_customer_sk = cd_demo_sk
                       AND t_hour >= 8
                       AND t_hour <= 9
                       AND cd_dep_count = dep);

    eveningSale := (SELECT COUNT(*)
                      FROM web_sales_history,
                           time_dim,
                           customer_demographics
                     WHERE ws_sold_time_sk = t_time_sk
                       AND ws_bill_customer_sk = cd_demo_sk
                       AND t_hour >= 19
                       AND t_hour <= 20
                       AND cd_dep_count = dep);

    ratio := CAST(morningSale AS FLOAT) / CAST(eveningSale AS FLOAT);
    RETURN ratio;
END;
$$;

--invocation query
SELECT t.depCount, morningToEveRatio(t.depCount)
  FROM (SELECT DISTINCT cd_dep_count AS depCount FROM customer_demographics) t;