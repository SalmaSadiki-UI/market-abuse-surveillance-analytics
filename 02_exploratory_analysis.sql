-- Market Abuse Surveillance Analytics
-- 02_exploratory_analysis.sql
-- Purpose: understand event mix, cancellation behaviour and order-size baselines.

-- Event distribution
SELECT
    event_type,
    COUNT(*) AS total_events
FROM AAPL_messages
GROUP BY event_type
ORDER BY event_type;

-- Event-level deletion share by side
SELECT
    direction,
    COUNT(*) AS total_events,
    SUM(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS deletions,
    ROUND(
        100.0 * SUM(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS deletion_rate_pct
FROM AAPL_messages
GROUP BY direction;

-- Order lifetime: new order to full delete
SELECT
    new_order.order_id,
    new_order.direction,
    new_order.size,
    new_order.price_raw / 10000.0 AS price,
    (delete_event.event_time - new_order.event_time) AS seconds_to_delete
FROM AAPL_messages AS new_order
JOIN AAPL_messages AS delete_event
    ON new_order.order_id = delete_event.order_id
WHERE new_order.event_type = 1
  AND delete_event.event_type = 3
  AND delete_event.event_time > new_order.event_time
ORDER BY seconds_to_delete ASC
LIMIT 30;

-- Lifetime distribution
WITH order_lifetimes AS (
    SELECT
        new_order.order_id,
        delete_event.event_time - new_order.event_time AS seconds_to_delete
    FROM AAPL_messages AS new_order
    JOIN AAPL_messages AS delete_event
        ON new_order.order_id = delete_event.order_id
    WHERE new_order.event_type = 1
      AND delete_event.event_type = 3
      AND delete_event.event_time > new_order.event_time
)
SELECT
    COUNT(*) AS deleted_orders,
    SUM(CASE WHEN seconds_to_delete < 1 THEN 1 ELSE 0 END) AS under_1_second,
    SUM(CASE WHEN seconds_to_delete < 0.1 THEN 1 ELSE 0 END) AS under_100ms,
    SUM(CASE WHEN seconds_to_delete < 0.01 THEN 1 ELSE 0 END) AS under_10ms,
    SUM(CASE WHEN seconds_to_delete < 0.001 THEN 1 ELSE 0 END) AS under_1ms
FROM order_lifetimes;

-- New-order size baseline
SELECT
    COUNT(*) AS total_new_orders,
    ROUND(AVG(size), 2) AS average_order_size,
    MAX(size) AS largest_order,
    SUM(CASE WHEN size >= 1000 THEN 1 ELSE 0 END) AS orders_1000_plus,
    SUM(CASE WHEN size >= 2000 THEN 1 ELSE 0 END) AS orders_2000_plus,
    SUM(CASE WHEN size >= 5000 THEN 1 ELSE 0 END) AS orders_5000_plus
FROM AAPL_messages
WHERE event_type = 1;
