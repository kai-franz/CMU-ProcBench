--for all customers, find out the preferred channel wrt number of orders made.

CREATE OR REPLACE FUNCTION preferredChannel_wrtCount(cust_key INT)
    RETURNS VARCHAR(50)
    LANGUAGE plpgsql
AS
$$
DECLARE
    numWeb   INT;
    numStore INT;
    numCat   INT;
BEGIN
    numWeb := 0;
    numStore := 0;
    numCat := 0;
    SELECT COUNT(*) INTO numWeb FROM web_sales_history WHERE ws_bill_customer_sk = cust_key;
    SELECT COUNT(*) INTO numStore FROM store_sales_history WHERE ss_customer_sk = cust_key;
    SELECT COUNT(*) INTO numCat FROM catalog_sales_history WHERE cs_bill_customer_sk = cust_key;
    IF (numWeb >= numStore AND numWeb >= numCat) THEN
        RETURN 'web';
    END IF;
    IF (numStore >= numWeb AND numStore >= numCat) THEN
        RETURN 'store';
    END IF;
    IF (numCat >= numStore AND numCat >= numWeb) THEN
        RETURN 'Catalog';
    END IF;
    RETURN 'Logical error';
END;
$$;

--inovocation query
SELECT c_customer_sk, preferredChannel_wrtCount(c_customer_sk)
  FROM customer;