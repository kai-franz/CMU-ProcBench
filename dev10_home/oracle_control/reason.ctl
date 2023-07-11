LOAD DATA
INFILE '/home/oracle/data/reason.dat'
INTO TABLE reason
FIELDS TERMINATED BY '|'
TRAILING NULLCOLS
(
    r_reason_sk,
    r_reason_id,
    r_reason_desc
)