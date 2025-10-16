-- part of a query repo
-- query name: n0ir Overview Stats
-- query link: https://dune.com/queries/placeholder_8


-- Single row with all key metrics for dashboard header cards
WITH all_positions AS (
    SELECT
        bytearray_to_uint256(topic2) AS token_id,
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
closed_positions AS (
    SELECT bytearray_to_uint256(topic2) AS token_id
    FROM base.logs
    WHERE contract_address IN (
        0x7c4b58b87D72A2F44baAf9A08F333BE562595540,
        0x0ee44295f4335256D2cE1123E5Bc277Fa36aB140
    )
      AND topic0 = 0xfc4e6ac706594637404ad0c7694a5353537a522cc0cf04a16ca51a228b0f2bd4
),
total_fees AS (
    SELECT SUM(bytearray_to_uint256(data) / 1e6) AS total_fees
    FROM base.logs
    WHERE contract_address = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913
      AND topic0 = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
      AND bytearray_substring(topic1, 13, 20) IN (0x7c4b58b87D72A2F44baAf9A08F333BE562595540, 0x0ee44295f4335256D2cE1123E5Bc277Fa36aB140)
      AND bytearray_substring(topic2, 13, 20) IN (0xEC5E6F3bBCBFfA2a758A76Bc4fd6a504FD3E7262, 0xfd75350a7e2c4914908ff7e3082c45af5762f5fe)
),
total_aero AS (
    SELECT SUM(bytearray_to_uint256(data) / 1e18) AS total_aero
    FROM base.logs
    WHERE contract_address = 0x940181a94A35A4569E4529A3CDfB74e38FD98631
      AND topic0 = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
      AND bytearray_substring(topic2, 13, 20) IN (0x7c4b58b87D72A2F44baAf9A08F333BE562595540, 0x0ee44295f4335256D2cE1123E5Bc277Fa36aB140)
)
SELECT
    -- User metrics
    COUNT(DISTINCT CASE WHEN p.contract_address = 0x7c4b58b87D72A2F44baAf9A08F333BE562595540 THEN p.user_address END) AS unique_users,

    -- Position metrics
    COUNT(*) AS total_positions_created,
    COUNT(CASE WHEN c.token_id IS NULL THEN 1 END) AS active_positions,

    -- TVL metrics
    SUM(CASE WHEN c.token_id IS NULL THEN p.usdc_invested ELSE 0 END) AS active_tvl_usdc,
    SUM(p.usdc_invested) AS total_volume_usdc,

    -- Revenue metrics
    COALESCE((SELECT total_fees FROM total_fees), 0) AS total_protocol_fees_usdc,
    COALESCE((SELECT total_aero FROM total_aero), 0) AS total_aero_rewards
FROM all_positions p
LEFT JOIN closed_positions c ON p.token_id = c.token_id
