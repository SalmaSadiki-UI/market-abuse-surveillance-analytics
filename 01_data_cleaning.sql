-- Market Abuse Surveillance Analytics
-- 01_data_cleaning.sql
-- Purpose: convert raw LOBSTER message fields into human-readable values.

SELECT
    event_time,
    event_type,
    CASE event_type
        WHEN 1 THEN 'New Order'
        WHEN 2 THEN 'Partial Cancel'
        WHEN 3 THEN 'Delete'
        WHEN 4 THEN 'Visible Execution'
        WHEN 5 THEN 'Hidden Execution'
        WHEN 6 THEN 'Cross Trade'
        WHEN 7 THEN 'Trading Halt'
    END AS event_name,
    order_id,
    size,
    price_raw / 10000.0 AS price,
    CASE direction
        WHEN 1 THEN 'Buy'
        WHEN -1 THEN 'Sell'
    END AS side
FROM AAPL_messages
LIMIT 20;
