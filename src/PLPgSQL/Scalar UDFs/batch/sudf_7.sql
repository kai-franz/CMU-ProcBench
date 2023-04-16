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
        netprofit := (SELECT array_agg(agg_0 ORDER BY temp_key1 NULLS LAST)
        FROM (SELECT sum(ss_net_profit) AS agg_0
                   , temp_key1
              FROM ((SELECT yr AS yr1
                          , manager AS manager1
                          , temp_key AS temp_key1
                     FROM temp AS temp1) AS t1
                    LEFT JOIN((store AS store1
                               CROSS JOIN store_sales_history AS store_sales_history1) AS join1
                              CROSS JOIN date_dim AS date_dim1) AS join2
                       ON (s_manager = manager1)
                      AND (d_year = yr1)) AS join3
              WHERE (ss_sold_date_sk = d_date_sk)
                AND (s_store_sk = ss_store_sk)
              GROUP BY temp_key1) AS t2);
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
FROM (SELECT unnest(s_manager_batch) AS s_manager
           , unnest(profitablemanager_batch(s_manager_batch, "2001_batch")) AS profitablemanager
      FROM (SELECT array_agg(s_manager ORDER BY s_manager
                                              , 2001) AS s_manager_batch
                 , array_agg(2001 ORDER BY s_manager
                                         , 2001) AS "2001_batch"
            FROM (SELECT s_manager
                       , profitablemanager(s_manager, 2001)
                  FROM store) AS dt1) AS dt2) AS dt3
WHERE profitablemanager <= 0