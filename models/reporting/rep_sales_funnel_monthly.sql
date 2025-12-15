{{ config(materialized = 'incremental') }}

SELECT
    DATE_TRUNC('month', change_time)::date AS month,
    -- this could also be done via a join to a fields table 
    -- but copilot helped me do it faster :)
    CASE
        WHEN
            changed_field_key = 'stage_id' AND new_value = '1'
            THEN 'Lead Generation'
        WHEN
            changed_field_key = 'stage_id' AND new_value = '2'
            THEN 'Qualified Lead'
        WHEN
            changed_field_key = 'stage_id' AND new_value = '3'
            THEN 'Needs Assessment'
        WHEN
            changed_field_key = 'stage_id' AND new_value = '4'
            THEN 'Proposal/Quote Preparation'
        WHEN
            changed_field_key = 'stage_id' AND new_value = '5'
            THEN 'Negotiation'
        WHEN changed_field_key = 'stage_id' AND new_value = '6' THEN 'Closing'
        WHEN
            changed_field_key = 'stage_id' AND new_value = '7'
            THEN 'Implementation/Onboarding'
        WHEN
            changed_field_key = 'stage_id' AND new_value = '8'
            THEN 'Follow-up/Customer Success'
        WHEN
            changed_field_key = 'stage_id' AND new_value = '9'
            THEN 'Renewal/Expansion'
        WHEN changed_field_key = 'lost_reason' THEN 'Churned'
    END AS kpi_name,
    CASE
        WHEN changed_field_key = 'stage_id' THEN CONCAT('0', new_value)
        WHEN changed_field_key = 'lost_reason' THEN '10'
    END AS funnel_step,
    COUNT(*) AS deals_count
FROM {{ ref('deals') }}
WHERE
    changed_field_key IN ('stage_id', 'lost_reason')
    {% if is_incremental() %}
        AND DATE_TRUNC('month', change_time)::date
        >= (SELECT MAX(month) FROM {{ this }})
    {% endif %}
GROUP BY 1, 2, 3

UNION ALL

SELECT
    DATE_TRUNC('month', due_to)::date AS month,
    -- this could also be done via a join to a fields table 
    -- but copilot helped me do it faster :)
    CASE
        WHEN type = 'meeting' THEN 'Sales Call 1'
        WHEN type = 'sc_2' THEN 'Sales Call 2'
    END AS kpi_name,
    CASE
        WHEN type = 'meeting' THEN '02.1'
        WHEN type = 'sc_2' THEN '03.1'
    END AS funnel_step,
    COUNT(*) AS deals_count
FROM {{ ref('activity') }}
WHERE
    type IN ('meeting', 'sc_2')
    {% if is_incremental() %}
        AND DATE_TRUNC('month', due_to)::date
        >= (SELECT MAX(month) FROM {{ this }})
    {% endif %}
GROUP BY 1, 2, 3
