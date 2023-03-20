
          SELECT r_reason_desc AS ans
            FROM (SELECT r_reason_id, r_reason_desc, COUNT(*) AS cnt
                    FROM catalog_returns_history,
                         reason
                   WHERE cr_reason_sk = r_reason_sk
                   GROUP BY r_reason_id, r_reason_desc) dt1
           WHERE dt1.cnt = (SELECT MAX(cnt)
                              FROM (SELECT r_reason_id, r_reason_desc, COUNT(*) AS cnt
                                      FROM catalog_returns_history,
                                           reason
                                     WHERE cr_reason_sk = r_reason_sk
                                     GROUP BY r_reason_id, r_reason_desc) dt2);
        