-- see if there is correlation betwen paying high shipping costs through catalog and 
--having a large number of high income inhabitants (at the state level))

CREATE OR REPLACE FUNCTION wealth_shipCostCorrelation_cat()
    RETURNS VARCHAR(40)
    LANGUAGE plpgsql
AS
$$
DECLARE
    numStates INT;
BEGIN
    numStates := 0;

    numStates := (SELECT COUNT(*)
                    FROM (SELECT ca_state
                            FROM (SELECT ca_state, SUM(cs_ext_ship_cost) AS sm
                                    FROM catalog_sales_history,
                                         customer_address
                                   WHERE cs_bill_customer_sk = ca_address_sk
                                     AND ca_state IS NOT NULL
                                   GROUP BY ca_state
                                   ORDER BY sm DESC
                                   LIMIT 5) t1

                       INTERSECT

                          SELECT ca_state
                            FROM --states wth largest numeber high income people
                                 (SELECT ca_state, COUNT(*) AS cnt
                                    FROM customer,
                                         household_demographics,
                                         customer_address
                                   WHERE c_current_hdemo_sk = hd_demo_sk
                                     AND c_current_addr_sk = ca_address_sk
                                     AND hd_income_band_sk >= 15
                                     AND ca_state IS NOT NULL
                                   GROUP BY ca_state
                                   ORDER BY cnt DESC
                                   LIMIT 5) t2) t3);

    IF (numStates >= 4) THEN
        RETURN 'hihgly correlated';
    END IF;
    IF (numStates >= 2 AND numStates <= 3) THEN
        RETURN 'somewhat correlated';
    END IF;
    IF (numStates >= 0 AND numStates <= 1) THEN
        RETURN 'no correlation';
    END IF;
    RETURN 'error';
END;
$$;

SELECT wealth_shipCostCorrelation_cat()