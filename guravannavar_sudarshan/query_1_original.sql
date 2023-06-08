CREATE OR ALTER FUNCTION count_offers(@itemcode INT, @amount FLOAT, @curcode CHAR(3)) RETURNS INT
AS
BEGIN
    DECLARE
        @amount_usd FLOAT;
    IF (@curcode = 'USD')
        BEGIN
            SET @amount_usd = @amount;
        END
    ELSE
        BEGIN
            SET @amount_usd = @amount * (SELECT exchrate
                                           FROM curexch
                                          WHERE ccode = @curcode);
        END

    RETURN (SELECT COUNT(*)
              FROM buyoffers
             WHERE itemid = @itemcode
               AND price >= @amount_usd);
END
GO

SELECT orderid
  FROM sellorders
 WHERE mkt = 'XNSE'
   AND dbo.count_offers(itemcode, amount, curcode) > 0;
