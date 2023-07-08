
SELECT _2.retVal
  FROM (SELECT _1.reason_desc FROM (SELECT dt1.r_reason_desc
                     FROM (SELECT r_reason_desc, COUNT(*) AS cnt
                             FROM web_returns_history,
                                  reason
                            WHERE wr_reason_sk = r_reason_sk
                            GROUP BY r_reason_id, r_reason_desc) dt1
                    WHERE dt1.cnt = (SELECT MAX(cnt)
                                       FROM (SELECT COUNT(*) AS cnt
                                               FROM web_returns_history,
                                                    reason
                                              WHERE wr_reason_sk = r_reason_sk
                                              GROUP BY r_reason_id, r_reason_desc) dt2)) AS _1(reason_desc)) AS _2(retVal);
