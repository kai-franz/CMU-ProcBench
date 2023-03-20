
select ca_state, d_year, d_qoy, sum(cs_net_paid_inc_ship_tax)
from customer_address,
     date_dim,
     catalog_sales_history,
     customer
where d_year in (1998, 1999, 2000)
  and ca_state is not NULL
  and cs_bill_customer_sk = c_customer_sk
  and c_current_addr_sk = ca_address_sk
  and cs_net_paid_inc_ship_tax >= 1000
  and d_date_sk = cs_sold_date_sk
group by ca_state, d_year, d_qoy
order by ca_state, d_year, d_qoy;