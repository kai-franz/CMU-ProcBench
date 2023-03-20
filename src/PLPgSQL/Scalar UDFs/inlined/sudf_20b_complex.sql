
select maxsoldItem
from (select ss_item_sk as maxSoldItem
      from (select ss_item_sk, sum(cnt) totalCnt
            from (select ss_item_sk, count(*) cnt
                  from store_sales_history
                  group by ss_item_sk
                  union all
                  select cs_item_sk, count(*) cnt
                  from catalog_sales_history
                  group by cs_item_sk
                  union all
                  select ws_item_sk, count(*) cnt
                  from web_sales_history
                  group by ws_item_sk) t1
            group by ss_item_sk) t2
      order by totalCnt desc) t3
where (SELECT (CASE
                   WHEN (E1.cnt1 > 0 and E2.cnt2 > 0) then (select i_manufact from item where i_item_sk = maxsoldItem)
                   ELSE 'outdated item'
    END)
       FROM (select count(*) as cnt1
             from store_sales_history,
                  date_dim
             where ss_item_sk = maxsoldItem
               and d_date_sk = ss_sold_date_sk
               and d_year = 2003) AS E1,
            (select count(*) as cnt2
             from catalog_sales_history,
                  date_dim
             where cs_item_sk = maxsoldItem
               and d_date_sk = cs_sold_date_sk
               and d_year = 2003) AS E2)
          = 'oughtn st';
        