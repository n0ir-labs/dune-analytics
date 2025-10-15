-- part of a query repo
-- query name: n0ir Active Positions
-- query link: https://dune.com/queries/placeholder_6


WITH created AS (
    SELECT
        bytea2numeric(topic2) AS token_id,
        block_time AS created_at,
        '0x' || encode(substring(topic1, 13, 20), 'hex') AS user_address,
        '0x' || encode(substring(topic3, 13, 20), 'hex') AS pool_address,
        bytea2numeric(substring(data, 129, 32)) / 1e6 AS usdc_invested
    FROM base.logs
    WHERE contract_address = 0x7c4b58b87D72A2F44baAf9A08F333BE562595540
      AND topic0 = 0x9d8c09d6a3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8  -- PositionCreated
),
closed AS (
    SELECT
        bytea2numeric(topic2) AS token_id,
        block_time AS closed_at
    FROM base.logs
    WHERE contract_address = 0x7c4b58b87D72A2F44baAf9A08F333BE562595540
      AND topic0 = 0x7d8c09d6a3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8  -- PositionClosed
)
SELECT
    COUNT(*) AS total_created,
    COUNT(cl.token_id) AS total_closed,
    COUNT(*) - COUNT(cl.token_id) AS currently_active,
    SUM(CASE WHEN cl.token_id IS NULL THEN cr.usdc_invested ELSE 0 END) AS active_tvl_usdc
FROM created cr
LEFT JOIN closed cl ON cr.token_id = cl.token_id
