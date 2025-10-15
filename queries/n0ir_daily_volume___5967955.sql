-- part of a query repo
-- query name: n0ir Daily Volume
-- query link: https://dune.com/queries/placeholder_5


WITH daily_data AS (
    SELECT
        DATE_TRUNC('day', block_time) AS date,
        bytearray_to_uint256(bytearray_substring(data, 129, 32)) / 1e6 AS usdc_amount,
        bytearray_substring(topic1, 13, 20) AS user_address
    FROM base.logs
    WHERE contract_address = 0x7c4b58b87D72A2F44baAf9A08F333BE562595540
      AND topic0 = 0x22c1b606e32c54081d4813a6daf0b6ab4522b84a2829c0dfa181ac6f12c62b7c  -- PositionCreated
)
SELECT
    date,
    SUM(usdc_amount) AS daily_volume_usdc,
    COUNT(*) AS positions_created,
    COUNT(DISTINCT user_address) AS daily_active_users
FROM daily_data
GROUP BY 1
ORDER BY 1 DESC
