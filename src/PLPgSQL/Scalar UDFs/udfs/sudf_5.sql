CREATE OR REPLACE FUNCTION morningtoeveratio(dep integer)
RETURNS double precision
LANGUAGE plpgsql
AS $$
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