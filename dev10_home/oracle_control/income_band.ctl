LOAD DATA
INFILE '/home/oracle/data/income_band.dat'
INTO TABLE income_band
FIELDS TERMINATED BY '|'
TRAILING NULLCOLS
(
    ib_income_band_sk,
    ib_lower_bound,
    ib_upper_bound
)