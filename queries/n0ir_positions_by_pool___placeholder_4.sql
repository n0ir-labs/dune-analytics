-- part of a query repo
-- query name: n0ir Positions by Pool
-- query link: https://dune.com/queries/placeholder_4


WITH position_data AS (
    SELECT
        '0x' || encode(substring(topic3, 13, 20), 'hex') AS pool_address,
        bytea2numeric(substring(data, 129, 32)) / 1e6 AS usdc_invested
    FROM base.logs
    WHERE contract_address = 0x7c4b58b87D72A2F44baAf9A08F333BE562595540
      AND topic0 = 0x9d8c09d6a3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8  -- PositionCreated
)
SELECT
    pool_address,
    CASE
        WHEN pool_address = '0xb2cc224c1c9fee385f8ad6a55b4d94e92359dc59' THEN 'WETH/USDC'
        WHEN pool_address = '0x4e962bb3889bf030368f56810a9c96b83cb3e778' THEN 'USDC/cbBTC'
        WHEN pool_address = '0xbe00ff35af70e8415d0eb605a286d8a45466a4c1' THEN 'AERO/USDC'
        WHEN pool_address = '0xe846373c1a92b167b4e9cd5d8e4d6b1db9e90ec7' THEN 'EURC/USDC'
        WHEN pool_address = '0x7501bc8bb51616f79bfa524e464fb7b41f0b10fb' THEN 'msUSD/USDC'
        WHEN pool_address = '0x363d1607b8da83d6b6ea76d017ceecf1316bb08a' THEN 'cbBTC/cbDOGE'
        ELSE 'Other'
    END AS pool_name,
    COUNT(*) AS position_count,
    SUM(usdc_invested) AS total_volume_usdc,
    AVG(usdc_invested) AS avg_position_size_usdc
FROM position_data
GROUP BY 1, 2
ORDER BY 4 DESC
