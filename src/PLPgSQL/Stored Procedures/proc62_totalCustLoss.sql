CREATE OR REPLACE FUNCTION custTotalLoss(returnReason CHAR(100))
    RETURNS REFCURSOR
AS
$$
DECLARE
    c3            REFCURSOR := 'mycursor';
    orderNo       INT; item INT;
    reasonSk      INT;
    soldAmt       DECIMAL(7, 2); retCredit DECIMAL(7, 2);
    totalCustLoss DECIMAL(15, 0);
    c1 CURSOR IS (SELECT wr_order_number, wr_item_sk, wr_refunded_cash
                    FROM web_returns
                   WHERE wr_reason_sk = 1);
    c2 CURSOR IS (SELECT cr_order_number, cr_item_sk, cr_refunded_cash
                    FROM catalog_returns
                   WHERE cr_reason_sk = 1);

BEGIN
    totalCustLoss := 0;
    reasonSk := (SELECT r_reason_sk FROM reason WHERE r_reason_desc = returnReason);
    OPEN c1;
    FETCH c1 INTO orderNo, item, retCredit;
    WHILE found
        LOOP
            soldAmt := (SELECT ws_net_paid_inc_ship_tax
                          FROM web_sales
                         WHERE ws_order_number = orderNo
                           AND ws_item_sk = item);
            totalCustLoss := totalCustLoss + soldAmt - retCredit;
            FETCH c1 INTO orderNo, item, retCredit;
        END LOOP;
    CLOSE c1;

    OPEN c2;
    FETCH c2 INTO orderNo, item, retCredit;
    WHILE found
        LOOP
            soldAmt := (SELECT cs_net_paid_inc_ship_tax
                          FROM catalog_sales
                         WHERE cs_order_number = orderNo
                           AND cs_item_sk = item);
            totalCustLoss := totalCustLoss + soldAmt - retCredit;
            FETCH c2 INTO orderNo, item, retCredit;
        END LOOP;
    CLOSE c2;

    OPEN c3 FOR
        SELECT totalCustLoss;
    RETURN c3;
END;
$$
    LANGUAGE plpgsql;