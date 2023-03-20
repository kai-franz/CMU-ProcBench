SELECT DISTINCT i_manufact_id
              , totaldiscount(i_manufact_id) AS totaldisc
FROM item;