SELECT DISTINCT *
FROM {{ source('enpal', 'activity') }}
