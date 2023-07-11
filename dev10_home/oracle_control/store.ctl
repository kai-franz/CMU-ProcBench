LOAD DATA
INFILE '/home/oracle/data/store.dat'
INTO TABLE store
FIELDS TERMINATED BY '|'
TRAILING NULLCOLS
(
    s_store_sk,
    s_store_id,
    s_rec_start_date DATE 'YYYY-MM-DD',
    s_rec_end_date DATE 'YYYY-MM-DD',
    s_closed_date_sk,
    s_store_name,
    s_number_employees,
    s_floor_space,
    s_hours,
    s_manager,
    s_market_id,
    s_geography_class,
    s_market_desc,
    s_market_manager,
    s_division_id,
    s_division_name,
    s_company_id,
    s_company_name,
    s_street_number,
    s_street_name,
    s_street_type,
    s_suite_number,
    s_city,
    s_county,
    s_state,
    s_zip,
    s_country,
    s_gmt_offset,
    s_tax_precentage
)