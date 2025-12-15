{{
    config(
        enabled=false
) }}


WITH filtered_data AS (
    SELECT field_value_options
    FROM {{ source('enpal', 'fields') }}
    WHERE field_key = 'lost_reason'
)

SELECT
    x.id AS lost_reason_id,
    x.label AS lost_reason
FROM filtered_data,
    jsonb_array_elements(field_value_options) AS t(doc),
    jsonb_to_record(t.doc) AS x ("id" INT, "label" TEXT)
