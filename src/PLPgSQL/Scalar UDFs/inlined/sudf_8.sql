
            SELECT E1.i_class
            FROM
            (
                SELECT i_class, COUNT(*) AS cnt
                 FROM   catalog_returns, item
                 WHERE  i_item_sk = cr_item_sk
                 GROUP BY i_class) as E1
            ORDER BY E1.cnt DESC
            LIMIT 1;
          