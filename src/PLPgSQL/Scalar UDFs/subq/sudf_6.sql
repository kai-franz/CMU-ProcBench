CREATE OR REPLACE FUNCTION totaldiscount_batch(manufacture_id_batch integer[])
RETURNS numeric[] LANGUAGE plpgsql
AS $$    
    DECLARE
        average DECIMAL[];
        addition DECIMAL[];
        ret_vals numeric[];
        returned BOOL[];
    BEGIN
        CREATE TEMPORARY TABLE temp (
            manufacture_id integer
          , average_scalar decimal
          , temp_key serial PRIMARY KEY
        ) ON COMMIT DROP;
        INSERT INTO temp 
        SELECT *
        FROM unnest(manufacture_id_batch);
        SELECT array_agg(agg_0 ORDER BY temp_key NULLS LAST)
        INTO average
        
        FROM (SELECT temp_key
                   , ((SELECT avg(ws_ext_discount_amt) AS agg_0
                       FROM web_sales_history, item
                       WHERE (ws_item_sk = i_item_sk)
                         AND (i_manufact_id = manufacture_id))) AS agg_0
              FROM temp) AS dt0;
            UPDATE temp
            SET average_scalar = average_var
            FROM unnest(average) WITH ORDINALITY AS average_array(average_var, average_key)
            WHERE average_key = temp_key;
        SELECT array_agg(agg_0 ORDER BY temp_key NULLS LAST)
        INTO addition
        
        FROM (SELECT temp_key
                   , ((SELECT sum(ws_ext_discount_amt) AS agg_0
                       FROM web_sales_history, item
                       WHERE (ws_item_sk = i_item_sk)
                         AND (i_manufact_id = manufacture_id)
                         AND (ws_ext_discount_amt > ((1.3 * average_scalar))))) AS agg_0
              FROM temp) AS dt0;
        FOR i IN ARRAY_LOWER(manufacture_id_batch, 1)..ARRAY_UPPER(manufacture_id_batch, 1) LOOP
            IF returned[i] IS NULL THEN
                ret_vals[i] := ((addition)[i]);
                returned[i] := TRUE;
            END IF;
        END LOOP;
        RETURN ret_vals;
    END;$$;


SELECT unnest(i_manufact_id_batch) AS i_manufact_id
     , unnest(totaldiscount_batch(i_manufact_id_batch)) AS totaldiscount
FROM (SELECT array_agg(i_manufact_id ORDER BY i_manufact_id) AS i_manufact_id_batch
      FROM (SELECT DISTINCT i_manufact_id
            FROM item) AS dt1) AS dt2