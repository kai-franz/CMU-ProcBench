SELECT s_manager
FROM store
WHERE profitablemanager(s_manager, 2001) <= 0;