--Compute the total discount on web sales of items from a given manufacturer for
--sales whose discount exceeded 30% over the average discount of items from that manufacturer.

create or replace function totalDiscount (manufacture_id int)
returns decimal 
language plpgsql
as
$$
declare
average decimal;
addition decimal;
begin
	select avg(ws_ext_discount_amt) into average from web_sales_history, item 
				where ws_item_sk = i_item_sk and i_manufact_id = manufacture_id;

	select sum(ws_ext_discount_amt) into addition from web_sales_history, item 
					where ws_item_sk = i_item_sk and i_manufact_id = manufacture_id and
					ws_ext_discount_amt>1.3*average;
	return addition;	
end;
$$;

select distinct i_manufact_id, totalDiscount(i_manufact_id) as totalDisc from item;