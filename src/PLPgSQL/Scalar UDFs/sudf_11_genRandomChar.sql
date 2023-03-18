--Pick a random character from a given list of characters. This is called from stored procedure proc_24_CreateRandomString

CREATE OR REPLACE FUNCTION genRandomChar(chars VARCHAR, rand FLOAT)
    RETURNS CHAR
    LANGUAGE plpgsql
AS
$$
DECLARE
    rslt        CHAR(1) := NULL;
    resultIndex INT     := NULL;
BEGIN
    IF chars IS NULL THEN
        rslt := NULL;
    ELSIF LENGTH(chars) = 0 THEN
        rslt := NULL;
    ELSE
        resultIndex := genRandomInt(1, LENGTH(chars), rand);
        rslt := SUBSTR(chars, resultIndex, 1);
    END IF;
    RETURN rslt;
END;
$$;
