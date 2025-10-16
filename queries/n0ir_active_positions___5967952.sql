-- part of a query repo
-- query name: n0ir Active Positions
-- query link: https://dune.com/queries/placeholder_6


WITH created AS (
    SELECT
        bytearray_to_uint256(topic2) AS token_id,
        block_time AS created_at,
        bytearray_substring(topic1, 13, 20) AS user_address,
        bytearray_substring(topic3, 13, 20) AS pool_address,
        bytearray_to_uint256(bytearray_substring(data, 33, 32)) / 1e6 AS usdc_invested
    FROM base.logs
    WHERE contract_address IN (
        0x7c4b58b87D72A2F44baAf9A08F333BE562595540,  -- Current proxy
        0x0ee44295f4335256D2cE1123E5Bc277Fa36aB140   -- Old contract
    )
      AND topic0 = 0x22c1b606e32c54081d4813a6daf0b6ab4522b84a2829c0dfa181ac6f12c62b7c  -- PositionCreated
),
closed AS (
    SELECT
        bytearray_to_uint256(topic2) AS token_id,
        block_time AS closed_at
    FROM base.logs
    WHERE contract_address IN (
        0x7c4b58b87D72A2F44baAf9A08F333BE562595540,  -- Current proxy
        0x0ee44295f4335256D2cE1123E5Bc277Fa36aB140   -- Old contract
    )
      AND topic0 = 0xfc4e6ac706594637404ad0c7694a5353537a522cc0cf04a16ca51a228b0f2bd4  -- PositionClosed
)
SELECT
    COUNT(*) AS total_created,
    COUNT(cl.token_id) AS total_closed,
    COUNT(*) - COUNT(cl.token_id) AS currently_active,
    SUM(CASE WHEN cl.token_id IS NULL THEN cr.usdc_invested ELSE 0 END) AS active_tvl_usdc
FROM created cr
LEFT JOIN closed cl ON cr.token_id = cl.token_id
