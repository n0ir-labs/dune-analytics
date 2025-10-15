-- part of a query repo
-- query name: n0ir Unique Users
-- query link: https://dune.com/queries/placeholder_2


SELECT
    COUNT(DISTINCT '0x' || encode(substring(topic1, 13, 20), 'hex')) AS unique_users,
    COUNT(*) AS total_positions_created
FROM base.logs
WHERE contract_address = 0x7c4b58b87D72A2F44baAf9A08F333BE562595540
  AND topic0 = 0x9d8c09d6a3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8b3c6b0c8  -- PositionCreated event signature
