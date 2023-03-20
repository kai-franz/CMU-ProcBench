
        SELECT (CASE WHEN E1.ratioWeb >= E2.ratioCatalog AND E1.ratioWeb >= E3.ratioStore THEN 'Web'
             WHEN E2.ratioCatalog >= E1.ratioWeb AND E2.ratioCatalog >= E3.ratioStore THEN 'Catalog'
             WHEN E3.ratioStore >= E2.ratioCatalog AND E1.ratioWeb <= E3.ratioStore THEN 'Store' END)
        FROM
        (SELECT (w1.promoCountWeb :: FLOAT4) / (w2.noPromoCountWeb :: FLOAT4) as ratioWeb
        FROM
       (SELECT SUM(t1.cnt) as promoCountWeb
                        FROM (SELECT ws_item_sk, ws_promo_sk, COUNT(*) AS cnt
                              FROM web_sales_history, promotion, date_dim
                              WHERE ws_sold_date_sk = d_date_sk
                                AND d_year = 2001
                                AND ws_promo_sk = p_promo_sk
                                AND p_channel_email='Y' OR p_channel_catalog='Y' OR p_channel_dmail='Y'
                              GROUP BY ws_item_sk, ws_promo_sk) AS t1) AS w1,

        (SELECT SUM(t1.cnt) as noPromoCountWeb
                          FROM (SELECT ws_item_sk, ws_promo_sk , COUNT(*) AS cnt
                                FROM web_sales_history, promotion, date_dim
                                WHERE ws_sold_date_sk = d_date_sk
                                  AND d_year = 2001
                                  AND ws_promo_sk = p_promo_sk
                                  AND p_channel_email='N' AND p_channel_catalog='N' AND p_channel_dmail='N'
                                GROUP BY ws_item_sk, ws_promo_sk) AS t1) AS w2) AS E1,
        (SELECT (w1.promoCountCatalog :: FLOAT4) / (w2.noPromoCountCatalog :: FLOAT4) AS ratioCatalog
        FROM (SELECT  SUM(t1.cnt) AS promoCountCatalog
                            FROM (SELECT cs_item_sk, cs_promo_sk, COUNT(*) AS cnt
                                  FROM catalog_sales_history, promotion, date_dim
                                  WHERE cs_sold_date_sk = d_date_sk
                                    AND d_year = 2001
                                    AND cs_promo_sk = p_promo_sk
                                    AND p_channel_email='Y' OR p_channel_catalog='Y' OR p_channel_dmail='Y' --or p_channel_tv = 'Y'
                                  GROUP BY cs_item_sk, cs_promo_sk) AS t1) AS w1,
            (SELECT SUM(t1.cnt) AS noPromoCountCatalog
                              FROM (SELECT cs_item_sk, cs_promo_sk, COUNT(*) AS cnt
                                    FROM catalog_sales_history, promotion, date_dim
                                    WHERE cs_sold_date_sk = d_date_sk
                                      AND d_year = 2001
                                      AND cs_promo_sk = p_promo_sk
                                      AND p_channel_email='N' AND p_channel_catalog='N' AND p_channel_dmail='N'
                                    GROUP BY cs_item_sk, cs_promo_sk) AS t1) as w2) AS E2,
        (SELECT (w1.promoCountStore :: FLOAT4) / (noPromoCountStore :: FLOAT4) AS ratioStore
        FROM (SELECT SUM(t1.cnt) AS promoCountStore
                          FROM (SELECT ss_item_sk, ss_promo_sk , COUNT(*) AS cnt
                                FROM store_sales_history, promotion, date_dim
                                WHERE ss_sold_date_sk = d_date_sk
                                  AND d_year = 2001
                                  AND ss_promo_sk = p_promo_sk
                                  AND p_channel_email='Y' OR p_channel_catalog='Y' OR p_channel_dmail='Y'
                                GROUP BY ss_item_sk, ss_promo_sk) AS t1) AS w1,
        (SELECT SUM(t1.cnt) AS noPromoCountStore
                            FROM (SELECT ss_item_sk, ss_promo_sk , COUNT(*) AS cnt
                                  FROM store_sales_history, promotion, date_dim
                                  WHERE ss_sold_date_sk = d_date_sk
                                    AND d_year = 2001
                                    AND ss_promo_sk = p_promo_sk
                                    AND p_channel_email='N' AND p_channel_catalog='N' AND p_channel_dmail='N'
                                  GROUP BY ss_item_sk, ss_promo_sk) AS t1) AS w2) AS E3;
        