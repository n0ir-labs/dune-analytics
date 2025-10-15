-- part of a query repo
-- query name: n0ir Unique Users
-- query link: https://dune.com/queries/placeholder_2


SELECT
    COUNT(DISTINCT bytearray_substring(topic1, 13, 20)) AS unique_users,
    COUNT(*) AS total_positions_created
FROM base.logs
WHERE contract_address = 0x7c4b58b87D72A2F44baAf9A08F333BE562595540
  AND topic0 = 0x22c1b606e32c54081d4813a6daf0b6ab4522b84a2829c0dfa181ac6f12c62b7c  -- PositionCreated
