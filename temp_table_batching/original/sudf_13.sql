CREATE OR ALTER FUNCTION maxPurchaseChannel(@ckey INT, @fromDateSk INT, @toDateSk INT)
    RETURNS VARCHAR(50) AS
BEGIN
    DECLARE @numSalesFromStore INT;
    DECLARE @numSalesFromCatalog INT;
    DECLARE @numSalesFromWeb INT;
    DECLARE @maxChannel VARCHAR(50);
    SET @numSalesFromStore = (SELECT COUNT(*)
                                FROM store_sales_history
                               WHERE ss_customer_sk = @ckey
                                 AND ss_sold_date_sk >= @fromDateSk
                                 AND ss_sold_date_sk <= @toDateSk);

    SET @numSalesFromCatalog = (SELECT COUNT(*)
                                  FROM catalog_sales_history
                                 WHERE cs_bill_customer_sk = @ckey
                                   AND cs_sold_date_sk >= @fromDateSk
                                   AND cs_sold_date_sk <= @toDateSk);

    SET @numSalesFromWeb = (SELECT COUNT(*)
                              FROM web_sales_history
                             WHERE ws_bill_customer_sk = @ckey
                               AND ws_sold_date_sk >= @fromDateSk
                               AND ws_sold_date_sk <= @toDateSk);

    IF (@numSalesFromStore > @numSalesFromCatalog)
        BEGIN
            SET @maxChannel = 'Store';
            IF (@numSalesfromWeb > @numSalesFromStore)
                BEGIN
                    SET @maxChannel = 'Web';
                END
        END
    ELSE
        BEGIN
            SET @maxChannel = 'Catalog';
            IF (@numSalesfromWeb > @numSalesFromCatalog)
                BEGIN
                    SET @maxChannel = 'Web';
                END
        END

    RETURN @maxChannel;
END
GO

--invocation query
SELECT c_customer_sk, dbo.maxPurchaseChannel(c_customer_sk, 2451545, 2459215) AS channel
  FROM customer
