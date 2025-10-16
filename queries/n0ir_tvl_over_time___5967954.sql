-- part of a query repo
-- query name: n0ir TVL Over Time
-- query link: https://dune.com/queries/placeholder_1


WITH deposits AS (
    SELECT
        DATE_TRUNC('day', block_time) AS date,
        SUM(bytearray_to_uint256(bytearray_substring(data, 33, 32)) / 1e6) AS deposits_usdc
    FROM base.logs
    WHERE contract_address IN (
        0x7c4b58b87D72A2F44baAf9A08F333BE562595540,  -- Current proxy
        0x0ee44295f4335256D2cE1123E5Bc277Fa36aB140   -- Old contract
    )
      AND topic0 = 0x22c1b606e32c54081d4813a6daf0b6ab4522b84a2829c0dfa181ac6f12c62b7c  -- PositionCreated
    GROUP BY 1
),
withdrawals AS (
    SELECT
        DATE_TRUNC('day', block_time) AS date,
        SUM(bytearray_to_uint256(bytearray_substring(data, 1, 32)) / 1e6) AS withdrawals_usdc
    FROM base.logs
    WHERE contract_address IN (
        0x7c4b58b87D72A2F44baAf9A08F333BE562595540,  -- Current proxy
        0x0ee44295f4335256D2cE1123E5Bc277Fa36aB140   -- Old contract
    )
      AND topic0 = 0xfc4e6ac706594637404ad0c7694a5353537a522cc0cf04a16ca51a228b0f2bd4  -- PositionClosed
    GROUP BY 1
)
SELECT
    COALESCE(d.date, w.date) AS date,
    SUM(COALESCE(d.deposits_usdc, 0) - COALESCE(w.withdrawals_usdc, 0))
        OVER (ORDER BY COALESCE(d.date, w.date)) AS tvl_usdc
FROM deposits d
FULL OUTER JOIN withdrawals w ON d.date = w.date
ORDER BY date DESC
