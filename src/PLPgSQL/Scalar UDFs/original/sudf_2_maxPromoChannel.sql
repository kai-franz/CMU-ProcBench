CREATE OR REPLACE FUNCTION maxPromoChannel(year INT)
    RETURNS VARCHAR
    LANGUAGE plpgsql
AS
$$
DECLARE
BEGIN
    RETURN promoVsNoPromoItems(year);
END;
$$;

SELECT maxPromoChannel(2001);