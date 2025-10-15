-- part of a query repo
-- query name: n0ir Protocol Fees Collected
-- query link: https://dune.com/queries/placeholder_3


SELECT
    DATE_TRUNC('day', block_time) AS date,
    SUM(value / 1e6) AS fees_collected_usdc,
    COUNT(*) AS fee_transaction_count
FROM base.transactions
WHERE to = 0xEC5E6F3bBCBFfA2a758A76Bc4fd6a504FD3E7262  -- PROTOCOL_TREASURY
  AND "from" = 0x7c4b58b87D72A2F44baAf9A08F333BE562595540  -- LiquidityManager Proxy
  AND value > 0
GROUP BY 1
ORDER BY 1 DESC
