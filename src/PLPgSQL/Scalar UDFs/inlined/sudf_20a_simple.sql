
            select ws_item_sk
            from (select ws_item_sk, count(*) cnt from web_sales group by ws_item_sk order by cnt) t1
            where (select i_manufact from item where i_item_sk = ws_item_sk) = 'oughtn st';
        