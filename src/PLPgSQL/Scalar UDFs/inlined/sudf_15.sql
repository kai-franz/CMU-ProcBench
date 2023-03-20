
            select s_store_sk from store where (SELECT (CASE WHEN (E2.incomeband >= 0 and E2.incomeband <= 3) then 'low'
         WHEN (E2.incomeband >= 4 and E2.incomeband <= 7) then 'lowerMiddle'
         WHEN (E2.incomeband >= 8 and E2.incomeband <= 11) then 'upperMiddle'
         WHEN (E2.incomeband >= 12 and E2.incomeband <= 16) then 'high'
         WHEN (E2.incomeband >= 17 and E2.incomeband <= 20) then 'affluent'
         END) as cLevel
    FROM (
    select hd_income_band_sk AS incomeband from household_demographics,
    (select ss_customer_sk AS cust, c_current_hdemo_sk AS hhdemo, count(*) AS cntVar
    from store_sales_history,
         customer
    where ss_store_sk = store.s_store_sk
      and c_customer_sk = ss_customer_sk
    group by ss_customer_sk, c_current_hdemo_sk
    having count(*) = (select max(cnt)
                       from (select ss_customer_sk, c_current_hdemo_sk, count(*) as cnt
                             from store_sales_history,
                                  customer
                             where ss_store_sk = store.s_store_sk
                               and c_customer_sk = ss_customer_sk
                             group by ss_customer_sk, c_current_hdemo_sk
                             having ss_customer_sk IS NOT NULL) tbl)) AS E1
    where hd_demo_sk = hhdemo) AS E2) = 'lowerMiddle' order by s_store_sk;
        