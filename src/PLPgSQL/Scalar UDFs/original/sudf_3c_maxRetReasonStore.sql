----most frequent reason for returns through stores

CREATE OR REPLACE FUNCTION maxReturnReasonStore()
    RETURNS CHAR(100)
    LANGUAGE plpgsql
AS
$$
DECLARE
    reason_desc CHAR(100);
    reason_id   CHAR(16);
BEGIN

    SELECT dt1.r_reason_id, dt1.r_reason_desc
      INTO reason_id, reason_desc
      FROM (SELECT r_reason_id, r_reason_desc, COUNT(*) AS cnt
              FROM store_returns_history,
                   reason
             WHERE sr_reason_sk = r_reason_sk
             GROUP BY r_reason_id, r_reason_desc) dt1
     WHERE dt1.cnt = (SELECT MAX(cnt)
                        FROM (SELECT r_reason_id, r_reason_desc, COUNT(*) AS cnt
                                FROM store_returns_history,
                                     reason
                               WHERE sr_reason_sk = r_reason_sk
                               GROUP BY r_reason_id, r_reason_desc) dt2);
    RETURN reason_desc;
END;
$$;
