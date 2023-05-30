--Were the stores run by the given manager profitable in the given year?

CREATE OR ALTER FUNCTION profitableManager(@manager VARCHAR(40), @year INT)
    RETURNS INT AS
BEGIN
    DECLARE @netProfit DECIMAL(15, 2);
    SET @netProfit = (SELECT SUM(ss_net_profit)
                        FROM store,
                             store_sales_history,
                             date_dim
                       WHERE ss_sold_date_sk = d_date_sk
                         AND d_year = @year
                         AND s_manager = @manager
                         AND s_store_sk = ss_store_sk);
    IF (@netProfit > 0)
        RETURN 1;
    RETURN 0;
END
GO

--invocation query
SELECT s_manager
  FROM store
 WHERE dbo.profitableManager(s_manager, 2001) <= 0;
GO