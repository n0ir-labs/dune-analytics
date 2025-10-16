-- part of a query repo
-- query name: n0ir Unique Users
-- query link: https://dune.com/queries/placeholder_2


-- Count unique users only from the new contract to avoid duplicates
-- Total positions includes both old and new contracts
WITH all_positions AS (
    SELECT
        bytearray_substring(topic1, 13, 20) AS user_address,
        contract_address
    FROM base.logs
    WHERE contract_address IN (
        0x7c4b58b87D72A2F44baAf9A08F333BE562595540,  -- Current proxy
        0x0ee44295f4335256D2cE1123E5Bc277Fa36aB140   -- Old contract
    )
      AND topic0 = 0x22c1b606e32c54081d4813a6daf0b6ab4522b84a2829c0dfa181ac6f12c62b7c  -- PositionCreated
)
SELECT
    COUNT(DISTINCT CASE WHEN contract_address = 0x7c4b58b87D72A2F44baAf9A08F333BE562595540 THEN user_address END) AS unique_users,
    COUNT(*) AS total_positions_created
FROM all_positions
