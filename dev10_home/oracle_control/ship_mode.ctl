LOAD DATA
INFILE '/home/oracle/data/ship_mode.dat'
INTO TABLE ship_mode
FIELDS TERMINATED BY '|'
TRAILING NULLCOLS
(
    sm_ship_mode_sk,
    sm_ship_mode_id,
    sm_type,
    sm_code,
    sm_carrier,
    sm_contract
)