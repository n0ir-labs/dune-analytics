-- part of a query repo
-- query name: n0ir Protocol Fees Collected
-- query link: https://dune.com/queries/placeholder_3


-- Track USDC transfers to protocol treasury from LiquidityManager
-- Transfer(address indexed from, address indexed to, uint256 value)
SELECT
    DATE_TRUNC('day', block_time) AS date,
    SUM(bytearray_to_uint256(data) / 1e6) AS fees_collected_usdc,
    COUNT(*) AS fee_transaction_count
FROM base.logs
WHERE contract_address = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913  -- USDC
  AND topic0 = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef  -- Transfer event
  AND bytearray_substring(topic1, 13, 20) IN (
      0x7c4b58b87D72A2F44baAf9A08F333BE562595540,  -- Current proxy
      0x0ee44295f4335256D2cE1123E5Bc277Fa36aB140   -- Old contract
  )
  AND bytearray_substring(topic2, 13, 20) IN (
      0xEC5E6F3bBCBFfA2a758A76Bc4fd6a504FD3E7262,  -- Current treasury
      0xfd75350a7e2c4914908ff7e3082c45af5762f5fe   -- Old treasury
  )
GROUP BY 1
ORDER BY 1 DESC
