WITH deduplicated AS (
    SELECT DISTINCT *
    FROM {{ source('enpal', 'deal_changes') }}
)

SELECT
    CONCAT(deal_id, '_', changed_field_key, '_', new_value) AS unique_activity_id,
    *
FROM deduplicated
