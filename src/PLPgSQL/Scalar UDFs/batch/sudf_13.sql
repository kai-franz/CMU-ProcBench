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
        SELECT array_agg(agg_0 ORDER BY temp_key9 NULLS LAST)
        INTO numsalesfromstore
        
        FROM (SELECT count(temp_key9) AS agg_0
                   , temp_key9
              FROM ((SELECT todatesk AS todatesk9
                          , fromdatesk AS fromdatesk9
                          , temp_key AS temp_key9
                          , ckey AS ckey9
                     FROM temp AS temp9) AS t14
                    LEFT JOIN store_sales_history AS store_sales_history1 ON (ss_sold_date_sk <= todatesk9)
                                                                         AND (ss_sold_date_sk >= fromdatesk9)
                                                                         AND (ss_customer_sk = ckey9)) AS join13
              GROUP BY temp_key9) AS t15;
        SELECT array_agg(agg_0 ORDER BY temp_key10 NULLS LAST)
        INTO numsalesfromcatalog
        
        FROM (SELECT count(temp_key10) AS agg_0
                   , temp_key10
              FROM ((SELECT todatesk AS todatesk10
                          , fromdatesk AS fromdatesk10
                          , temp_key AS temp_key10
                          , ckey AS ckey10
                     FROM temp AS temp10) AS t16
                    LEFT JOIN catalog_sales_history AS catalog_sales_history2 ON (cs_sold_date_sk <= todatesk10)
                                                                             AND (cs_sold_date_sk >= fromdatesk10)
                                                                             AND (cs_bill_customer_sk = ckey10)) AS join14
              GROUP BY temp_key10) AS t17;
        SELECT array_agg(agg_0 ORDER BY temp_key11 NULLS LAST)
        INTO numsalesfromweb
        
        FROM (SELECT count(temp_key11) AS agg_0
                   , temp_key11
              FROM ((SELECT todatesk AS todatesk11
                          , fromdatesk AS fromdatesk11
                          , temp_key AS temp_key11
                          , ckey AS ckey11
                     FROM temp AS temp11) AS t18
                    LEFT JOIN web_sales_history AS web_sales_history5 ON (ws_sold_date_sk <= todatesk11)
                                                                     AND (ws_sold_date_sk >= fromdatesk11)
                                                                     AND (ws_bill_customer_sk = ckey11)) AS join15
              GROUP BY temp_key11) AS t19;
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