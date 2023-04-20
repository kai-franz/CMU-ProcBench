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
        morningsale := (SELECT array_agg(agg_0 ORDER BY temp_key2 NULLS LAST)
        FROM (SELECT count(temp_key2) AS agg_0
                   , temp_key2
              FROM ((SELECT temp_key AS temp_key2
                          , dep AS dep2
                     FROM temp AS temp2) AS t3
                    LEFT JOIN((web_sales_history AS web_sales_history1
                               CROSS JOIN time_dim AS time_dim1) AS join5
                              CROSS JOIN customer_demographics AS customer_demographics1) AS join6
                       ON (cd_dep_count = dep2)) AS join7
              WHERE (ws_sold_time_sk = t_time_sk)
                AND (ws_bill_customer_sk = cd_demo_sk)
                AND (t_hour >= 8)
                AND (t_hour <= 9)
              GROUP BY temp_key2) AS t4);
        eveningsale := (SELECT array_agg(agg_0 ORDER BY temp_key3 NULLS LAST)
        FROM (SELECT count(temp_key3) AS agg_0
                   , temp_key3
              FROM ((SELECT temp_key AS temp_key3
                          , dep AS dep3
                     FROM temp AS temp3) AS t5
                    LEFT JOIN((web_sales_history AS web_sales_history2
                               CROSS JOIN time_dim AS time_dim2) AS join8
                              CROSS JOIN customer_demographics AS customer_demographics2) AS join9
                       ON (cd_dep_count = dep3)) AS join10
              WHERE (ws_sold_time_sk = t_time_sk)
                AND (ws_bill_customer_sk = cd_demo_sk)
                AND (t_hour >= 19)
                AND (t_hour <= 20)
              GROUP BY temp_key3) AS t6);
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