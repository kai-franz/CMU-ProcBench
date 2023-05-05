CREATE TABLE #temp
(
    ckey                INTEGER,
    numSalesFromStore   INTEGER,
    numSalesFromCatalog INTEGER,
    numSalesFromWeb     INTEGER,
    maxChannel          VARCHAR(50),
    return_val          VARCHAR(50),
    p1                  BIT,
    p2                  BIT,
    p3                  BIT,
);

INSERT INTO #temp (ckey)
SELECT c_customer_sk
  FROM customer;

UPDATE #temp
   SET numSalesFromStore = (SELECT COUNT(*)
                              FROM store_sales_history
                             WHERE ss_customer_sk = ckey
                               AND ss_sold_date_sk >= 2451545
                               AND ss_sold_date_sk <= 2459215);

UPDATE #temp
   SET numSalesFromCatalog = (SELECT COUNT(*)
                                FROM catalog_sales_history
                               WHERE cs_bill_customer_sk = ckey
                                 AND cs_sold_date_sk >= 2451545
                                 AND cs_sold_date_sk <= 2459215);

UPDATE #temp
   SET numSalesFromWeb = (SELECT COUNT(*)
                            FROM web_sales_history
                           WHERE ws_bill_customer_sk = ckey
                             AND ws_sold_date_sk >= 2451545
                             AND ws_sold_date_sk <= 2459215)


UPDATE #temp
   SET p1 = CASE WHEN numSalesFromStore > numSalesFromCatalog THEN 1 ELSE 0 END;

UPDATE #temp
   SET maxChannel = 'Store'
 WHERE p1 = 1;

UPDATE #temp
   SET p2 = CASE WHEN numSalesFromWeb > numSalesFromStore THEN 1 ELSE 0 END
 WHERE p1 = 1;

UPDATE #temp
   SET maxChannel = 'Web'
 WHERE p1 = 1
   AND p2 = 1;

UPDATE #temp
   SET maxChannel = 'Catalog'
 WHERE p1 = 0;

UPDATE #temp
   SET p3 = CASE WHEN numSalesFromWeb > numSalesFromCatalog THEN 1 ELSE 0 END
 WHERE p1 = 0;

UPDATE #temp
   SET maxChannel = 'Web'
 WHERE p1 = 0
   AND p3 = 1;

UPDATE #temp
   SET return_val = maxChannel;

SELECT ckey, return_val
  FROM #temp;

DROP TABLE #temp;