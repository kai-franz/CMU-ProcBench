CREATE OR REPLACE FUNCTION morningtoeveratio_batch(dep_batch integer[])
RETURNS double precision[] LANGUAGE plpgsql
AS $$    
    DECLARE
        morningsale INT[];
        eveningsale INT[];
        ratio FLOAT[];
        ret_vals float8[];
        returned BOOL[];
    BEGIN
        CREATE TEMPORARY TABLE temp (
            dep integer
          , temp_key serial PRIMARY KEY
        ) ON COMMIT DROP;
        INSERT INTO temp 
        SELECT *
        FROM unnest(dep_batch);
        morningsale := (SELECT array_agg(agg_0 ORDER BY temp_key NULLS LAST)
        FROM (SELECT temp_key
                   , ((SELECT count(*) AS agg_0
                       FROM web_sales_history, time_dim, customer_demographics
                       WHERE (ws_sold_time_sk = t_time_sk)
                         AND (ws_bill_customer_sk = cd_demo_sk)
                         AND (t_hour >= 8)
                         AND (t_hour <= 9)
                         AND (cd_dep_count = dep))) AS agg_0
              FROM temp) AS dt0);
        eveningsale := (SELECT array_agg(agg_0 ORDER BY temp_key NULLS LAST)
        FROM (SELECT temp_key
                   , ((SELECT count(*) AS agg_0
                       FROM web_sales_history, time_dim, customer_demographics
                       WHERE (ws_sold_time_sk = t_time_sk)
                         AND (ws_bill_customer_sk = cd_demo_sk)
                         AND (t_hour >= 19)
                         AND (t_hour <= 20)
                         AND (cd_dep_count = dep))) AS agg_0
              FROM temp) AS dt0);
        FOR i IN ARRAY_LOWER(dep_batch, 1)..ARRAY_UPPER(dep_batch, 1) LOOP
            ratio[i] := (CAST(((morningsale)[i]) AS double precision) / CAST(((eveningsale)[i]) AS double precision));
        END LOOP;
        FOR i IN ARRAY_LOWER(dep_batch, 1)..ARRAY_UPPER(dep_batch, 1) LOOP
            IF returned[i] IS NULL THEN
                ret_vals[i] := ((ratio)[i]);
                returned[i] := TRUE;
            END IF;
        END LOOP;
        RETURN ret_vals;
    END;$$;


SELECT unnest(depcount_batch) AS depcount
     , unnest(morningtoeveratio_batch(depcount_batch)) AS morningtoeveratio
FROM (SELECT array_agg(depcount ORDER BY depcount) AS depcount_batch
      FROM (SELECT t.depcount
            FROM (SELECT DISTINCT cd_dep_count AS depcount
                  FROM customer_demographics) AS t) AS dt1) AS dt2