WITH deduplicated AS (
    SELECT DISTINCT *
    FROM {{ source('enpal', 'activity') }}
)

SELECT
    *,
    CONCAT(activity_id, '_', due_to) AS unique_activity_id
FROM deduplicated
-- For this deal, we have an exception where sales_call_2 is 
-- scheduled before sales_call_1. I assume that should not happen
-- in normal cases, so I will exclude this deal from the final output
WHERE
    deal_id != 960413
