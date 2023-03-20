CREATE OR REPLACE FUNCTION profitablemanager(manager varchar(40)
                                           , yr integer)
RETURNS integer
AS $$
DECLARE
    netProfit DECIMAL(15, 2);
BEGIN
    netProfit := (SELECT SUM(ss_net_profit)
                    FROM store,
                         store_sales_history,
                         date_dim
                   WHERE ss_sold_date_sk = d_date_sk
                     AND d_year = yr
                     AND s_manager = manager
                     AND s_store_sk = ss_store_sk);

    IF netProfit > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END
$$
LANGUAGE plpgsql;