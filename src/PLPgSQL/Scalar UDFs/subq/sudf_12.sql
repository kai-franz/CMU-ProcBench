CREATE OR REPLACE FUNCTION increaseinwebspending_batch(cust_sk_batch integer[])
RETURNS numeric[] LANGUAGE plpgsql
AS $$    
    DECLARE
        spending1 DECIMAL[];
        spending2 DECIMAL[];
        increase DECIMAL[];
        ret_vals numeric[];
        returned BOOL[];
    BEGIN
        CREATE TEMPORARY TABLE temp (
            cust_sk integer
          , temp_key serial PRIMARY KEY
        ) ON COMMIT DROP;
        INSERT INTO temp 
        SELECT *
        FROM unnest(cust_sk_batch);
        FOR i IN ARRAY_LOWER(cust_sk_batch, 1)..ARRAY_UPPER(cust_sk_batch, 1) LOOP
            spending1[i] := (0);
        END LOOP;
        FOR i IN ARRAY_LOWER(cust_sk_batch, 1)..ARRAY_UPPER(cust_sk_batch, 1) LOOP
            spending2[i] := (0);
        END LOOP;
        FOR i IN ARRAY_LOWER(cust_sk_batch, 1)..ARRAY_UPPER(cust_sk_batch, 1) LOOP
            increase[i] := (0);
        END LOOP;
        SELECT array_agg(agg_0 ORDER BY temp_key NULLS LAST)
        INTO spending1
        
        FROM (SELECT temp_key
                   , ((SELECT sum(ws_net_paid_inc_ship_tax) AS agg_0
                       FROM web_sales_history, date_dim
                       WHERE (d_date_sk = ws_sold_date_sk)
                         AND (d_year = 2001)
                         AND (ws_bill_customer_sk = cust_sk))) AS agg_0
              FROM temp) AS dt0;
        SELECT array_agg(agg_0 ORDER BY temp_key NULLS LAST)
        INTO spending2
        
        FROM (SELECT temp_key
                   , ((SELECT sum(ws_net_paid_inc_ship_tax) AS agg_0
                       FROM web_sales_history, date_dim
                       WHERE (d_date_sk = ws_sold_date_sk)
                         AND (d_year = 2000)
                         AND (ws_bill_customer_sk = cust_sk))) AS agg_0
              FROM temp) AS dt0;
        FOR i IN ARRAY_LOWER(cust_sk_batch, 1)..ARRAY_UPPER(cust_sk_batch, 1) LOOP
            IF ((spending1)[i] < (spending2)[i]) THEN
                IF returned[i] IS NULL THEN
                    ret_vals[i] := (-1);
                    returned[i] := TRUE;
                END IF;
            ELSE
                increase[i] := ((spending1)[i] - (spending2)[i]);
            END IF;
        END LOOP;
        FOR i IN ARRAY_LOWER(cust_sk_batch, 1)..ARRAY_UPPER(cust_sk_batch, 1) LOOP
            IF returned[i] IS NULL THEN
                ret_vals[i] := ((increase)[i]);
                returned[i] := TRUE;
            END IF;
        END LOOP;
        RETURN ret_vals;
    END;$$;


SELECT c_customer_sk
     , increaseinwebspending
FROM (SELECT unnest(c_customer_sk_batch) AS c_customer_sk
           , unnest(increaseinwebspending_batch(c_customer_sk_batch)) AS increaseinwebspending
      FROM (SELECT array_agg(c_customer_sk ORDER BY c_customer_sk) AS c_customer_sk_batch
            FROM (SELECT c_customer_sk
                  FROM customer
                  WHERE c_customer_sk IN (SELECT ws_bill_customer_sk
                                          FROM web_sales_history, date_dim
                                          WHERE (    (d_date_sk = ws_sold_date_sk)
                                                 AND (d_year = 2000))

                                          INTERSECT

                                          SELECT ws_bill_customer_sk
                                          FROM web_sales_history, date_dim
                                          WHERE (    (d_date_sk = ws_sold_date_sk)
                                                 AND (d_year = 2001)))) AS dt1) AS dt2) AS dt3
WHERE increaseinwebspending > 0