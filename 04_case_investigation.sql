-- Market Abuse Surveillance Analytics
-- 04_case_investigation.sql
-- Purpose: add order-book context and create a transparent prioritisation score.
-- Important: this is an illustrative surveillance-priority score, not a regulatory risk model.

-- Pre-event best bid / ask context
WITH flagged_orders AS (
    SELECT
        n.rowid AS event_row,
        n.order_id,
        n.event_time,
        n.size,
        n.direction,
        n.price_raw,
        d.event_time - n.event_time AS seconds_to_delete
    FROM AAPL_messages n
    JOIN AAPL_messages d
        ON n.order_id = d.order_id
    WHERE n.event_type = 1
      AND d.event_type = 3
      AND d.event_time > n.event_time
      AND n.size >= 1000
      AND (d.event_time - n.event_time) < 0.1
)
SELECT
    f.order_id,
    f.size,
    CASE WHEN f.direction = 1 THEN 'Buy' ELSE 'Sell' END AS side,
    f.price_raw / 10000.0 AS order_price,
    o.best_bid,
    o.best_ask,
    f.seconds_to_delete
FROM flagged_orders f
JOIN (
    SELECT
        rowid,
        bid_price_1 / 10000.0 AS best_bid,
        ask_price_1 / 10000.0 AS best_ask
    FROM AAPL_orderbook
) o
    ON o.rowid = f.event_row - 1
ORDER BY f.size DESC, f.seconds_to_delete;

-- Order size relative to visible best-side liquidity
WITH flagged_orders AS (
    SELECT
        n.rowid AS event_row,
        n.order_id,
        n.size,
        n.direction,
        n.price_raw,
        d.event_time - n.event_time AS seconds_to_delete
    FROM AAPL_messages n
    JOIN AAPL_messages d
        ON n.order_id = d.order_id
    WHERE n.event_type = 1
      AND d.event_type = 3
      AND d.event_time > n.event_time
      AND n.size >= 1000
      AND (d.event_time - n.event_time) < 0.1
)
SELECT
    f.order_id,
    f.size,
    CASE WHEN f.direction = 1 THEN 'Buy' ELSE 'Sell' END AS side,
    f.price_raw / 10000.0 AS order_price,
    CASE
        WHEN f.direction = 1 THEN o.bid_size_1
        ELSE o.ask_size_1
    END AS visible_size_before,
    ROUND(
        1.0 * f.size /
        CASE
            WHEN f.direction = 1 THEN o.bid_size_1
            ELSE o.ask_size_1
        END,
        2
    ) AS size_multiple,
    f.seconds_to_delete
FROM flagged_orders f
JOIN AAPL_orderbook o
    ON o.rowid = f.event_row - 1
ORDER BY size_multiple DESC;

-- Transparent surveillance-priority score
WITH flagged_orders AS (
    SELECT
        n.rowid AS event_row,
        n.order_id,
        n.size,
        n.direction,
        n.price_raw,
        d.event_time - n.event_time AS seconds_to_delete
    FROM AAPL_messages n
    JOIN AAPL_messages d
        ON n.order_id = d.order_id
    WHERE n.event_type = 1
      AND d.event_type = 3
      AND d.event_time > n.event_time
      AND n.size >= 1000
      AND (d.event_time - n.event_time) < 0.1
)
SELECT
    f.order_id,
    f.size,
    CASE WHEN f.direction = 1 THEN 'Buy' ELSE 'Sell' END AS side,
    f.price_raw / 10000.0 AS order_price,
    ROUND(
        1.0 * f.size /
        CASE
            WHEN f.direction = 1 THEN o.bid_size_1
            ELSE o.ask_size_1
        END,
        2
    ) AS size_multiple,
    f.seconds_to_delete,
    CASE
        WHEN f.size >= 5000 THEN 3
        WHEN f.size >= 2000 THEN 2
        ELSE 1
    END
    +
    CASE
        WHEN f.seconds_to_delete < 0.001 THEN 3
        WHEN f.seconds_to_delete < 0.01 THEN 2
        ELSE 1
    END
    +
    CASE
        WHEN (
            1.0 * f.size /
            CASE
                WHEN f.direction = 1 THEN o.bid_size_1
                ELSE o.ask_size_1
            END
        ) >= 100 THEN 3
        WHEN (
            1.0 * f.size /
            CASE
                WHEN f.direction = 1 THEN o.bid_size_1
                ELSE o.ask_size_1
            END
        ) >= 20 THEN 2
        ELSE 1
    END AS risk_score
FROM flagged_orders f
JOIN AAPL_orderbook o
    ON o.rowid = f.event_row - 1
ORDER BY risk_score DESC, size_multiple DESC;
