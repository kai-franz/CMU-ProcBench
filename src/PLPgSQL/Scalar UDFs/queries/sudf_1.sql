SELECT ca_state
     , d_year
     , d_qoy
     , totallargepurchases(ca_state, 1000, d_year, d_qoy)
FROM customer_address, date_dim
WHERE d_year IN (1998, 1999, 2000)
  AND ca_state IS NOT NULL
GROUP BY ca_state, d_year, d_qoy
ORDER BY ca_state
       , d_year
       , d_qoy;