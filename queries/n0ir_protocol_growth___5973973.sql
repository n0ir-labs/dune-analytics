-- part of a query repo
-- query name: n0ir Protocol Growth Over Time
-- query link: https://dune.com/queries/placeholder_9


-- Time series showing protocol growth metrics - perfect for multi-line chart
WITH daily_positions AS (
    SELECT
        DATE_TRUNC('day', block_time) AS date,
        bytearray_substring(topic1, 13, 20) AS user_address,
        bytearray_to_uint256(bytearray_substring(data, 33, 32)) / 1e6 AS usdc_invested,
        contract_address
    FROM base.logs
    WHERE contract_address IN (
        0x7c4b58b87D72A2F44baAf9A08F333BE562595540,
        0x0ee44295f4335256D2cE1123E5Bc277Fa36aB140
    )
      AND topic0 = 0x22c1b606e32c54081d4813a6daf0b6ab4522b84a2829c0dfa181ac6f12c62b7c
),
daily_closures AS (
    SELECT
        DATE_TRUNC('day', block_time) AS date,
        bytearray_to_uint256(bytearray_substring(data, 1, 32)) / 1e6 AS usdc_returned
    FROM base.logs
    WHERE contract_address IN (
        0x7c4b58b87D72A2F44baAf9A08F333BE562595540,
        0x0ee44295f4335256D2cE1123E5Bc277Fa36aB140
    )
      AND topic0 = 0xfc4e6ac706594637404ad0c7694a5353537a522cc0cf04a16ca51a228b0f2bd4
)
SELECT
    p.date,
    COUNT(*) AS daily_new_positions,
    SUM(p.usdc_invested) AS daily_volume_usdc,
    COUNT(DISTINCT CASE WHEN p.contract_address = 0x7c4b58b87D72A2F44baAf9A08F333BE562595540 THEN p.user_address END) AS daily_active_users,

    -- Cumulative metrics
    SUM(COUNT(*)) OVER (ORDER BY p.date) AS cumulative_positions,
    SUM(COUNT(DISTINCT CASE WHEN p.contract_address = 0x7c4b58b87D72A2F44baAf9A08F333BE562595540 THEN p.user_address END))
        OVER (ORDER BY p.date) AS cumulative_users,
    SUM(SUM(p.usdc_invested) - COALESCE(SUM(c.usdc_returned), 0))
        OVER (ORDER BY p.date) AS cumulative_tvl_usdc,

    -- Daily stats
    AVG(p.usdc_invested) AS avg_position_size_usdc
FROM daily_positions p
LEFT JOIN daily_closures c ON p.date = c.date
GROUP BY p.date
ORDER BY p.date DESC
