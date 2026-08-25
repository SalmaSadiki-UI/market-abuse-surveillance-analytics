-- Market Abuse Surveillance Analytics
-- 03_surveillance_detection.sql
-- Purpose: identify large, short-lived orders as surveillance candidates.

-- Large and rapidly deleted orders
WITH order_lifetimes AS (
    SELECT
        new_order.order_id,
        new_order.size,
        new_order.direction,
        new_order.price_raw / 10000.0 AS price,
        delete_event.event_time - new_order.event_time AS seconds_to_delete
    FROM AAPL_messages AS new_order
    JOIN AAPL_messages AS delete_event
        ON new_order.order_id = delete_event.order_id
    WHERE new_order.event_type = 1
      AND delete_event.event_type = 3
      AND delete_event.event_time > new_order.event_time
)
SELECT *
FROM order_lifetimes
WHERE seconds_to_delete < 0.1
ORDER BY size DESC
LIMIT 30;

-- Combined surveillance threshold
WITH order_lifetimes AS (
    SELECT
        new_order.order_id,
        new_order.size,
        new_order.direction,
        new_order.price_raw / 10000.0 AS price,
        delete_event.event_time - new_order.event_time AS seconds_to_delete
    FROM AAPL_messages AS new_order
    JOIN AAPL_messages AS delete_event
        ON new_order.order_id = delete_event.order_id
    WHERE new_order.event_type = 1
      AND delete_event.event_type = 3
      AND delete_event.event_time > new_order.event_time
)
SELECT
    order_id,
    size,
    direction,
    price,
    seconds_to_delete
FROM order_lifetimes
WHERE size >= 1000
  AND seconds_to_delete < 0.1
ORDER BY size DESC, seconds_to_delete ASC;
