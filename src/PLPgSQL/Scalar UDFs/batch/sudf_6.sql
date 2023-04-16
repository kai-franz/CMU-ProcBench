CREATE OR REPLACE FUNCTION totaldiscount_batch(manufacture_id_batch integer[])
RETURNS numeric[] LANGUAGE plpgsql
AS $$    
    DECLARE
        average DECIMAL[];
        addition DECIMAL[];
        ret_vals numeric[];
        returned BOOL[];
    BEGIN
        CREATE TABLE temp (
            manufacture_id integer
          , temp_key serial PRIMARY KEY
        );
        INSERT INTO temp 
        SELECT *
        FROM unnest(manufacture_id_batch);
        SELECT array_agg(agg_0 ORDER BY temp_key4 NULLS LAST)
        INTO average
        
        FROM (SELECT avg(ws_ext_discount_amt) AS agg_0
                   , temp_key4
              FROM ((SELECT temp_key AS temp_key4
                          , manufacture_id AS manufacture_id4
                     FROM temp AS temp4) AS t5
                    LEFT JOIN(web_sales_history AS web_sales_history1
                              CROSS JOIN item AS item1) AS join5
                       ON (i_manufact_id = manufacture_id4)) AS join6
              WHERE ws_item_sk = i_item_sk
              GROUP BY temp_key4) AS t6;
        SELECT array_agg(agg_0 ORDER BY temp_key5 NULLS LAST)
        INTO addition
        
        FROM (SELECT sum(ws_ext_discount_amt) AS agg_0
                   , temp_key5
              FROM ((SELECT temp_key AS temp_key5
                          , manufacture_id AS manufacture_id5
                     FROM temp AS temp5) AS t7
                    LEFT JOIN(web_sales_history AS web_sales_history2
                              CROSS JOIN item AS item2) AS join7
                       ON (i_manufact_id = manufacture_id5)) AS join8
              WHERE (ws_item_sk = i_item_sk)
                AND (ws_ext_discount_amt > ((1.3 * average)))
              GROUP BY temp_key5) AS t8;
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
                          , totaldiscount(i_manufact_id) AS totaldisc
            FROM item) AS dt1) AS dt2

select * from temp;

explain SELECT avg(ws_ext_discount_amt) AS agg_0
                   , temp_key4
              FROM ((SELECT temp_key AS temp_key4
                          , manufacture_id AS manufacture_id4
                     FROM temp AS temp4) AS t5
                    LEFT JOIN(web_sales_history AS web_sales_history1
                              CROSS JOIN item AS item1) AS join5
                       ON (i_manufact_id = manufacture_id4)) AS join6
              WHERE ws_item_sk = i_item_sk
              GROUP BY temp_key4