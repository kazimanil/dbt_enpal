WITH deduplicated AS (
    SELECT DISTINCT *
    FROM {{ source('enpal', 'activity') }}
)

SELECT
    CONCAT(activity_id, '_', due_to) AS unique_activity_id,
    *
FROM deduplicated
