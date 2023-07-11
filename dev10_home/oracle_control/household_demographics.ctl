LOAD DATA
INFILE '/home/oracle/data/household_demographics.dat'
INTO TABLE household_demographics
FIELDS TERMINATED BY '|'
TRAILING NULLCOLS
(
    hd_demo_sk,
    hd_income_band_sk,
    hd_buy_potential,
    hd_dep_count,
    hd_vehicle_count
)