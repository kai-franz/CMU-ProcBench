CREATE OR REPLACE FUNCTION totallargepurchases_batch(givenstate_batch char(2)[]
                                                   , amount_batch numeric[]
                                                   , yr_batch integer[]
                                                   , qtr_batch integer[])
RETURNS numeric[] LANGUAGE plpgsql
AS $$    
    DECLARE
        largepurchase DECIMAL[];
        ret_vals numeric[];
        returned BOOL[];
    BEGIN
        CREATE TEMPORARY TABLE temp (
            givenstate char(2)
          , amount numeric
          , yr integer
          , qtr integer
          , temp_key serial PRIMARY KEY
        ) ON COMMIT DROP;
        INSERT INTO temp 
        SELECT *
        FROM unnest(givenstate_batch, amount_batch, yr_batch, qtr_batch);
        SELECT array_agg(agg_0 ORDER BY temp_key NULLS LAST)
        INTO largepurchase
        
        FROM (SELECT temp_key
                   , ((SELECT sum(cs_net_paid_inc_ship_tax) AS agg_0
                       FROM catalog_sales_history, customer, customer_address, date_dim
                       WHERE (cs_bill_customer_sk = c_customer_sk)
                         AND (c_current_addr_sk = ca_address_sk)
                         AND (ca_state = givenstate)
                         AND (cs_net_paid_inc_ship_tax >= amount)
                         AND (d_date_sk = cs_sold_date_sk)
                         AND (d_year = yr)
                         AND (d_qoy = qtr))) AS agg_0
              FROM temp) AS dt0;
        FOR i IN ARRAY_LOWER(givenstate_batch, 1)..ARRAY_UPPER(givenstate_batch, 1) LOOP
            IF returned[i] IS NULL THEN
                ret_vals[i] := ((largepurchase)[i]);
                returned[i] := TRUE;
            END IF;
        END LOOP;
        RETURN ret_vals;
    END;$$;


SELECT unnest(ca_state_batch) AS ca_state
     , unnest(d_year_batch) AS d_year
     , unnest(d_qoy_batch) AS d_qoy
     , unnest(totallargepurchases_batch(ca_state_batch, "1000_batch", d_year_batch, d_qoy_batch)) AS totallargepurchases
FROM (SELECT array_agg(ca_state ORDER BY ca_state
                                       , 1000
                                       , d_year
                                       , d_qoy) AS ca_state_batch
           , array_agg(1000 ORDER BY ca_state
                                   , 1000
                                   , d_year
                                   , d_qoy) AS "1000_batch"
           , array_agg(d_year ORDER BY ca_state
                                     , 1000
                                     , d_year
                                     , d_qoy) AS d_year_batch
           , array_agg(d_qoy ORDER BY ca_state
                                    , 1000
                                    , d_year
                                    , d_qoy) AS d_qoy_batch
      FROM (SELECT ca_state
                 , d_year
                 , d_qoy
            FROM customer_address, date_dim
            WHERE d_year IN (1998, 1999, 2000)
              AND (ca_state IS NOT NULL)
            GROUP BY ca_state, d_year, d_qoy
            ORDER BY ca_state
                   , d_year
                   , d_qoy) AS dt1) AS dt2