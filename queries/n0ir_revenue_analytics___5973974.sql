-- part of a query repo
-- query name: n0ir Revenue Analytics
-- query link: https://dune.com/queries/placeholder_10


-- Revenue metrics with context - fees + AERO in one view
WITH daily_fees AS (
    SELECT
        DATE_TRUNC('day', block_time) AS date,
        SUM(bytearray_to_uint256(data) / 1e6) AS fees_usdc
    FROM base.logs
    WHERE contract_address = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913
      AND topic0 = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
      AND bytearray_substring(topic1, 13, 20) IN (0x7c4b58b87D72A2F44baAf9A08F333BE562595540, 0x0ee44295f4335256D2cE1123E5Bc277Fa36aB140)
      AND bytearray_substring(topic2, 13, 20) IN (0xEC5E6F3bBCBFfA2a758A76Bc4fd6a504FD3E7262, 0xfd75350a7e2c4914908ff7e3082c45af5762f5fe)
    GROUP BY 1
),
daily_aero AS (
    SELECT
        DATE_TRUNC('day', block_time) AS date,
        SUM(bytearray_to_uint256(data) / 1e18) AS aero_earned
    FROM base.logs
    WHERE contract_address = 0x940181a94A35A4569E4529A3CDfB74e38FD98631
      AND topic0 = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
      AND bytearray_substring(topic2, 13, 20) IN (0x7c4b58b87D72A2F44baAf9A08F333BE562595540, 0x0ee44295f4335256D2cE1123E5Bc277Fa36aB140)
    GROUP BY 1
),
daily_volume AS (
    SELECT
        DATE_TRUNC('day', block_time) AS date,
        SUM(bytearray_to_uint256(bytearray_substring(data, 33, 32)) / 1e6) AS volume_usdc
    FROM base.logs
    WHERE contract_address IN (0x7c4b58b87D72A2F44baAf9A08F333BE562595540, 0x0ee44295f4335256D2cE1123E5Bc277Fa36aB140)
      AND topic0 = 0x22c1b606e32c54081d4813a6daf0b6ab4522b84a2829c0dfa181ac6f12c62b7c
    GROUP BY 1
)
SELECT
    COALESCE(f.date, a.date, v.date) AS date,
    COALESCE(f.fees_usdc, 0) AS daily_fees_usdc,
    COALESCE(a.aero_earned, 0) AS daily_aero_earned,
    COALESCE(v.volume_usdc, 0) AS daily_volume_usdc,

    -- Cumulative
    SUM(COALESCE(f.fees_usdc, 0)) OVER (ORDER BY COALESCE(f.date, a.date, v.date)) AS cumulative_fees_usdc,
    SUM(COALESCE(a.aero_earned, 0)) OVER (ORDER BY COALESCE(f.date, a.date, v.date)) AS cumulative_aero_earned,

    -- Ratios
    CASE WHEN COALESCE(v.volume_usdc, 0) > 0
         THEN (COALESCE(f.fees_usdc, 0) / v.volume_usdc) * 100
         ELSE 0 END AS fee_rate_percent
FROM daily_fees f
FULL OUTER JOIN daily_aero a ON f.date = a.date
FULL OUTER JOIN daily_volume v ON COALESCE(f.date, a.date) = v.date
ORDER BY date DESC
