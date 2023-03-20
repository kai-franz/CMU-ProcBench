CREATE OR REPLACE FUNCTION maxpurchasechannel(ckey integer
                                            , fromdatesk integer
                                            , todatesk integer)
RETURNS varchar(50)
LANGUAGE plpgsql
AS $$
DECLARE
    numSalesFromStore   INT;
    numSalesFromCatalog INT;
    numSalesFromWeb     INT;
    maxChannel          VARCHAR(50);
BEGIN
    SELECT COUNT(*)
      INTO numSalesFromStore
      FROM store_sales_history
     WHERE ss_customer_sk = ckey
       AND ss_sold_date_sk >= fromDateSk
       AND ss_sold_date_sk <= toDateSk;

    SELECT COUNT(*)
      INTO numSalesFromCatalog
      FROM catalog_sales_history
     WHERE cs_bill_customer_sk = ckey
       AND cs_sold_date_sk >= fromDateSk
       AND cs_sold_date_sk <= toDateSk;

    SELECT COUNT(*)
      INTO numSalesFromWeb
      FROM web_sales_history
     WHERE ws_bill_customer_sk = ckey
       AND ws_sold_date_sk >= fromDateSk
       AND ws_sold_date_sk <= toDateSk;

    IF (numSalesFromStore > numSalesFromCatalog) THEN
        maxChannel := 'Store';
        IF (numSalesfromWeb > numSalesFromStore) THEN
            maxChannel := 'Web';
        END IF;
    ELSE
        maxChannel := 'Catalog';
        IF (numSalesfromWeb > numSalesFromCatalog) THEN
            maxChannel := 'Web';
        END IF;
    END IF;

    RETURN maxChannel;
END;
$$;