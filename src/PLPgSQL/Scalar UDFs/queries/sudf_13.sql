SELECT c_customer_sk
     , maxpurchasechannel(c_customer_sk
                        , (SELECT min(d_date_sk)
                           FROM date_dim
                           WHERE d_year = 2000)
                        , (SELECT max(d_date_sk)
                           FROM date_dim
                           WHERE d_year = 2020)) AS channel
FROM customer;