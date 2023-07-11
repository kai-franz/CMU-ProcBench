LOAD DATA
INFILE '/home/oracle/data/customer_demographics.dat'
INTO TABLE customer_demographics
FIELDS TERMINATED BY '|'
TRAILING NULLCOLS
(
    cd_demo_sk,
    cd_gender,
    cd_marital_status,
    cd_education_status,
    cd_purchase_estimate,
    cd_credit_rating,
    cd_dep_count,
    cd_dep_employed_count,
    cd_dep_college_count
)