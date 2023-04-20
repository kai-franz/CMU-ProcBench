CREATE OR REPLACE FUNCTION profitablemanager_batch(manager_batch varchar(40)[]
                                                 , yr_batch integer[])
RETURNS integer[]
AS $$    
    DECLARE
        netprofit DECIMAL(15, 2)[];
        ret_vals int4[];
        returned BOOL[];
    BEGIN
        CREATE TEMPORARY TABLE temp (
            manager varchar(40)
          , yr integer
          , temp_key serial PRIMARY KEY
        ) ON COMMIT DROP;
        INSERT INTO temp 
        SELECT *
        FROM unnest(manager_batch, yr_batch);
        netprofit := (SELECT array_agg(agg_0 ORDER BY temp_key6 NULLS LAST)
        FROM (SELECT sum(ss_net_profit) AS agg_0
                   , temp_key6
              FROM ((SELECT temp_key AS temp_key6
                          , yr AS yr6
                          , manager AS manager6
                     FROM temp AS temp6) AS t11
                    LEFT JOIN((store AS store1
                               CROSS JOIN store_sales_history AS store_sales_history1) AS join15
                              CROSS JOIN date_dim AS date_dim2) AS join16
                       ON (s_manager = manager6)
                      AND (d_year = yr6)) AS join17
              WHERE (ss_sold_date_sk = d_date_sk)
                AND (s_store_sk = ss_store_sk)
              GROUP BY temp_key6) AS t12);
        FOR i IN ARRAY_LOWER(manager_batch, 1)..ARRAY_UPPER(manager_batch, 1) LOOP
            IF ((netprofit)[i] > 0) THEN
                IF returned[i] IS NULL THEN
                    ret_vals[i] := (1);
                    returned[i] := TRUE;
                END IF;
            ELSE
                IF returned[i] IS NULL THEN
                    ret_vals[i] := (0);
                    returned[i] := TRUE;
                END IF;
            END IF;
        END LOOP;
        FOR i IN ARRAY_LOWER(manager_batch, 1)..ARRAY_UPPER(manager_batch, 1) LOOP
        END LOOP;
        RETURN ret_vals;
    END;$$ LANGUAGE plpgsql;


SELECT s_manager
     , profitablemanager
FROM (SELECT unnest(s_manager_batch) AS s_manager
           , unnest(profitablemanager_batch(s_manager_batch, "2001_batch")) AS profitablemanager
      FROM (SELECT array_agg(s_manager ORDER BY s_manager
                                              , 2001) AS s_manager_batch
                 , array_agg(2001 ORDER BY s_manager
                                         , 2001) AS "2001_batch"
            FROM (SELECT s_manager
                  FROM store) AS dt1) AS dt2) AS dt3
WHERE profitablemanager <= 0