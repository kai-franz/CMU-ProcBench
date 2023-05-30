--Compute the total discount on web sales of items from a given manufacturer for
--sales whose discount exceeded 30% over the average discount of items from that manufacturer.

CREATE OR ALTER FUNCTION totalDiscount(@manufacture_id INT)
    RETURNS DECIMAL(15, 2)
AS
BEGIN
    DECLARE @avg DECIMAL(15, 2);
    DECLARE @s DECIMAL(15, 2);
    SET @avg = (SELECT AVG(ws_ext_discount_amt)
                  FROM web_sales_history,
                       item
                 WHERE ws_item_sk = i_item_sk
                   AND i_manufact_id = @manufacture_id);

    SET @s = (SELECT SUM(ws_ext_discount_amt)
                FROM web_sales_history,
                     item
               WHERE ws_item_sk = i_item_sk
                 AND i_manufact_id = @manufacture_id
                 AND ws_ext_discount_amt > 1.3 * @avg);
    RETURN @s;
END
GO

SELECT DISTINCT i_manufact_id, dbo.totalDiscount(i_manufact_id) AS totalDisc
  FROM item;