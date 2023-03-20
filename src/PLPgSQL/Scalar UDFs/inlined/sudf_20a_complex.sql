
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
                    where (select i_manufact from item where i_item_sk = maxSoldItem) = 'oughtn st';
        