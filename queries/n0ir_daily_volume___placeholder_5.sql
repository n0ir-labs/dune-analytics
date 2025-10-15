-- part of a query repo
-- query name: n0ir Daily Volume
-- query link: https://dune.com/queries/placeholder_5


WITH daily_data AS (
    SELECT
        DATE_TRUNC('day', evt_block_time) AS date,
        CAST(bytea2numeric(substring(data, 129, 32)) AS DOUBLE) / 1e6 AS usdc_amount,
        '0x' || encode(substring(topic1, 13, 20), 'hex') AS user_address
    FROM base.logs
    WHERE contract_address = 0x7c4b58b87D72A2F44baAf9A08F333BE562595540
      AND topic0 = 0x9d8c09d6a3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8  -- PositionCreated
)
SELECT
    date,
    SUM(usdc_amount) AS daily_volume_usdc,
    COUNT(*) AS positions_created,
    COUNT(DISTINCT user_address) AS daily_active_users
FROM daily_data
GROUP BY 1
ORDER BY 1 DESC
