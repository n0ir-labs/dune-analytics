-- part of a query repo
-- query name: n0ir AERO Rewards Earned
-- query link: https://dune.com/queries/placeholder_7


-- Track AERO token transfers to users from gauge contracts
-- When rewards are claimed, AERO is transferred from gauge to LiquidityManager, then to users
-- Transfer(address indexed from, address indexed to, uint256 value)

WITH aero_transfers AS (
    SELECT
        block_time,
        bytearray_substring(topic2, 13, 20) AS recipient,
        bytearray_to_uint256(data) / 1e18 AS aero_amount
    FROM base.logs
    WHERE contract_address = 0x940181a94A35A4569E4529A3CDfB74e38FD98631  -- AERO token
      AND topic0 = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef  -- Transfer event
      -- AERO sent TO the LiquidityManager (rewards claimed from gauges)
      AND bytearray_substring(topic2, 13, 20) = 0x7c4b58b87D72A2F44baAf9A08F333BE562595540
)
SELECT
    DATE_TRUNC('day', block_time) AS date,
    SUM(aero_amount) AS daily_aero_rewards,
    COUNT(*) AS reward_claim_count,
    SUM(SUM(aero_amount)) OVER (ORDER BY DATE_TRUNC('day', block_time)) AS cumulative_aero_rewards
FROM aero_transfers
GROUP BY 1
ORDER BY 1 DESC
