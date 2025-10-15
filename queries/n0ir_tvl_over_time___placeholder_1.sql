-- part of a query repo
-- query name: n0ir TVL Over Time
-- query link: https://dune.com/queries/placeholder_1


WITH deposits AS (
    SELECT
        DATE_TRUNC('day', block_time) AS date,
        SUM(bytea2numeric(substring(data, 129, 32)) / 1e6) AS deposits_usdc
    FROM base.logs
    WHERE contract_address = 0x7c4b58b87D72A2F44baAf9A08F333BE562595540
      AND topic0 = 0x9d8c09d6a3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8  -- PositionCreated event signature
    GROUP BY 1
),
withdrawals AS (
    SELECT
        DATE_TRUNC('day', block_time) AS date,
        SUM(bytea2numeric(substring(data, 33, 32)) / 1e6) AS withdrawals_usdc
    FROM base.logs
    WHERE contract_address = 0x7c4b58b87D72A2F44baAf9A08F333BE562595540
      AND topic0 = 0x7d8c09d6a3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8  -- PositionClosed event signature
    GROUP BY 1
)
SELECT
    COALESCE(d.date, w.date) AS date,
    SUM(COALESCE(d.deposits_usdc, 0) - COALESCE(w.withdrawals_usdc, 0))
        OVER (ORDER BY COALESCE(d.date, w.date)) AS tvl_usdc
FROM deposits d
FULL OUTER JOIN withdrawals w ON d.date = w.date
ORDER BY date DESC
