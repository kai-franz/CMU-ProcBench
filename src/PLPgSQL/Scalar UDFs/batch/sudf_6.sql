CREATE OR REPLACE FUNCTION totaldiscount_batch(manufacture_id_batch INTEGER[])
    RETURNS NUMERIC[]
    LANGUAGE plpgsql
AS
$$
DECLARE
    average  DECIMAL[];
    addition DECIMAL[];
    ret_vals NUMERIC[];
    returned BOOL[];
BEGIN
    CREATE TEMPORARY TABLE temp
    (
        manufacture_id INTEGER,
        average_scalar DECIMAL,
        temp_key       SERIAL PRIMARY KEY
    ) ON COMMIT DROP;
    INSERT INTO temp
    SELECT *
      FROM UNNEST(manufacture_id_batch);
    SELECT ARRAY_AGG(agg_0 ORDER BY temp_key1 NULLS LAST)
      INTO average

      FROM (SELECT AVG(ws_ext_discount_amt) AS agg_0
                 , temp_key1
              FROM ((SELECT manufacture_id AS manufacture_id1
                          , average_scalar AS average_scalar1
                          , temp_key       AS temp_key1
                       FROM temp AS temp1) AS t1
                  LEFT JOIN (web_sales_history AS web_sales_history1
                      CROSS JOIN item AS item1) AS join1
                    ON (i_manufact_id = manufacture_id1)) AS join2
             WHERE ws_item_sk = i_item_sk
             GROUP BY temp_key1) AS t2;
    UPDATE temp
       SET average_scalar = average_var
      FROM UNNEST(average) WITH ORDINALITY AS average_array(average_var, average_key)
     WHERE average_key = temp_key;
    SELECT ARRAY_AGG(agg_0 ORDER BY temp_key2 NULLS LAST)
      INTO addition

      FROM (SELECT SUM(ws_ext_discount_amt) AS agg_0
                 , temp_key2
              FROM ((SELECT manufacture_id AS manufacture_id2
                          , average_scalar AS average_scalar2
                          , temp_key       AS temp_key2
                       FROM temp AS temp2) AS t3
                  LEFT JOIN (web_sales_history AS web_sales_history2
                      CROSS JOIN item AS item2) AS join3
                    ON (ws_ext_discount_amt > ((1.3 * average_scalar2)))
                        AND (i_manufact_id = manufacture_id2)) AS join4
             WHERE ws_item_sk = i_item_sk
             GROUP BY temp_key2) AS t4;
    FOR i IN ARRAY_LOWER(manufacture_id_batch, 1)..ARRAY_UPPER(manufacture_id_batch, 1)
        LOOP
            IF returned[i] IS NULL THEN
                ret_vals[i] := ((addition)[i]);
                returned[i] := TRUE;
            END IF;
        END LOOP;
    RETURN ret_vals;
END;
$$;


SELECT UNNEST(i_manufact_id_batch)                      AS i_manufact_id
     , UNNEST(totaldiscount_batch(i_manufact_id_batch)) AS totaldiscount
  FROM (SELECT ARRAY_AGG(i_manufact_id ORDER BY i_manufact_id) AS i_manufact_id_batch
          FROM (SELECT DISTINCT i_manufact_id
                              , totaldiscount(i_manufact_id) AS totaldisc
                  FROM item) AS dt1) AS dt2