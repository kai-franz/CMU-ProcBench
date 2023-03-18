--Generate a random integer between given lower and upper bounds Called from sudf_11_genRandomChar

CREATE OR REPLACE FUNCTION genRandomInt(
    lower INT,
    upper INT,
    rand FLOAT
)
    RETURNS INT
    LANGUAGE plpgsql
AS
$$
DECLARE
    result INT;
    range  INT;
BEGIN
    range := upper - lower + 1;
    result := FLOOR(rand * range + lower);
    RETURN result;
END;
$$

