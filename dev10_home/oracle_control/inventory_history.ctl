LOAD DATA
INFILE '/home/oracle/data/inventory.dat'
INTO TABLE inventory_history
FIELDS TERMINATED BY '|'
TRAILING NULLCOLS
(
    inv_date_sk,
    inv_item_sk,
    inv_warehouse_sk,
    inv_quantity_on_hand
)