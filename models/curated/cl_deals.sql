WITH deduplicated AS (
    SELECT DISTINCT *
    FROM {{ source('enpal', 'deal_changes') }}
),

row_numbers AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY deal_id, changed_field_key, new_value
            ORDER BY change_time DESC
        ) AS rn
    FROM deduplicated
)

SELECT
    CONCAT(deal_id, '_', changed_field_key, '_', new_value, '_', rn) AS unique_activity_id,
    *
FROM row_numbers
