CREATE OR REPLACE FUNCTION maxpurchasechannel_batch(ckey_batch integer[]
                                                  , fromdatesk_batch integer[]
                                                  , todatesk_batch integer[])
RETURNS varchar(50)[] LANGUAGE plpgsql
AS $$    
    DECLARE
        numsalesfromstore INT[];
        numsalesfromcatalog INT[];
        numsalesfromweb INT[];
        maxchannel VARCHAR(50)[];
        ret_vals varchar[];
        returned BOOL[];
    BEGIN
        CREATE TEMPORARY TABLE temp (
            ckey integer
          , fromdatesk integer
          , todatesk integer
          , temp_key serial PRIMARY KEY
        ) ON COMMIT DROP;
        INSERT INTO temp 
        SELECT *
        FROM unnest(ckey_batch, fromdatesk_batch, todatesk_batch);
        SELECT array_agg(agg_0 ORDER BY temp_key NULLS LAST)
        INTO numsalesfromstore
        
        FROM (SELECT temp_key
                   , ((SELECT count(*) AS agg_0
                       FROM store_sales_history
                       WHERE (ss_customer_sk = ckey)
                         AND (ss_sold_date_sk >= fromdatesk)
                         AND (ss_sold_date_sk <= todatesk))) AS agg_0
              FROM temp) AS dt0;
        SELECT array_agg(agg_0 ORDER BY temp_key NULLS LAST)
        INTO numsalesfromcatalog
        
        FROM (SELECT temp_key
                   , ((SELECT count(*) AS agg_0
                       FROM catalog_sales_history
                       WHERE (cs_bill_customer_sk = ckey)
                         AND (cs_sold_date_sk >= fromdatesk)
                         AND (cs_sold_date_sk <= todatesk))) AS agg_0
              FROM temp) AS dt0;
        SELECT array_agg(agg_0 ORDER BY temp_key NULLS LAST)
        INTO numsalesfromweb
        
        FROM (SELECT temp_key
                   , ((SELECT count(*) AS agg_0
                       FROM web_sales_history
                       WHERE (ws_bill_customer_sk = ckey)
                         AND (ws_sold_date_sk >= fromdatesk)
                         AND (ws_sold_date_sk <= todatesk))) AS agg_0
              FROM temp) AS dt0;
        FOR i IN ARRAY_LOWER(ckey_batch, 1)..ARRAY_UPPER(ckey_batch, 1) LOOP
            IF ((numsalesfromstore)[i] > (numsalesfromcatalog)[i]) THEN
                maxchannel[i] := ('Store');
                IF ((numsalesfromweb)[i] > (numsalesfromstore)[i]) THEN
                    maxchannel[i] := ('Web');
                END IF;
            ELSE
                maxchannel[i] := ('Catalog');
                IF ((numsalesfromweb)[i] > (numsalesfromcatalog)[i]) THEN
                    maxchannel[i] := ('Web');
                END IF;
            END IF;
        END LOOP;
        FOR i IN ARRAY_LOWER(ckey_batch, 1)..ARRAY_UPPER(ckey_batch, 1) LOOP
            IF returned[i] IS NULL THEN
                ret_vals[i] := ((maxchannel)[i]);
                returned[i] := TRUE;
            END IF;
        END LOOP;
        RETURN ret_vals;
    END;$$;


SELECT unnest(c_customer_sk_batch) AS c_customer_sk
     , unnest(maxpurchasechannel_batch(c_customer_sk_batch, "2451545_batch", "2459215_batch")) AS maxpurchasechannel
FROM (SELECT array_agg(c_customer_sk ORDER BY c_customer_sk
                                            , 2451545
                                            , 2459215) AS c_customer_sk_batch
           , array_agg(2451545 ORDER BY c_customer_sk
                                      , 2451545
                                      , 2459215) AS "2451545_batch"
           , array_agg(2459215 ORDER BY c_customer_sk
                                      , 2451545
                                      , 2459215) AS "2459215_batch"
      FROM (SELECT c_customer_sk
            FROM customer) AS dt1) AS dt2