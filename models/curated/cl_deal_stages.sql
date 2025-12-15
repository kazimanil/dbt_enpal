WITH deals AS (
    SELECT
        deal_id,
        MAX(CASE WHEN changed_field_key = 'add_time' THEN TO_TIMESTAMP('%Y-%m-%dT%H:%M:%S%z', new_value) END) AS deal_generated_at,
        MAX(CASE WHEN changed_field_key = 'stage_id' AND new_value = '1' THEN change_time::timestamptz END) AS lead_generated_at,
        MAX(CASE WHEN changed_field_key = 'stage_id' AND new_value = '2' THEN change_time::timestamptz END) AS qualified_lead_at,
        MAX(CASE WHEN changed_field_key = 'stage_id' AND new_value = '3' THEN change_time::timestamptz END) AS needs_assessment_at,
        MAX(CASE WHEN changed_field_key = 'stage_id' AND new_value = '4' THEN change_time::timestamptz END) AS proposal_quote_preparation_at,
        MAX(CASE WHEN changed_field_key = 'stage_id' AND new_value = '5' THEN change_time::timestamptz END) AS negotiation_at,
        MAX(CASE WHEN changed_field_key = 'stage_id' AND new_value = '6' THEN change_time::timestamptz END) AS closing_at,
        MAX(CASE WHEN changed_field_key = 'stage_id' AND new_value = '7' THEN change_time::timestamptz END) AS implementation_at,
        MAX(CASE WHEN changed_field_key = 'stage_id' AND new_value = '8' THEN change_time::timestamptz END) AS activated_at,
        MAX(CASE WHEN changed_field_key = 'stage_id' AND new_value = '9' THEN change_time::timestamptz END) AS renewal_at,
        MAX(CASE WHEN changed_field_key = 'lost_reason' THEN change_time::timestamptz END) AS churned_at,
        MAX(CASE WHEN changed_field_key = 'lost_reason' THEN new_value::int END) AS lost_reason_id
    FROM {{ ref('deals') }}
    GROUP BY 1
),

calls AS (
    SELECT
        deal_id,
        MAX(CASE WHEN type = 'meeting' THEN due_to::timestamptz END) AS sales_call_1_scheduled_at,
        MAX(CASE WHEN type = 'sc_2' THEN due_to::timestamptz END) AS sales_call_2_scheduled_at
    FROM {{ ref('activity') }}
    GROUP BY 1
)

SELECT
    COALESCE(d.deal_id, c.deal_id) AS deal_id,
    d.deal_generated_at,
    d.lead_generated_at,
    d.qualified_lead_at,
    d.needs_assessment_at,
    d.proposal_quote_preparation_at,
    d.negotiation_at,
    d.closing_at,
    d.implementation_at,
    d.activated_at,
    d.renewal_at,
    d.churned_at,
    clr.lost_reason,
    c.sales_call_1_scheduled_at,
    c.sales_call_2_scheduled_at
FROM deals AS d
FULL JOIN calls AS c
    ON d.deal_id = c.deal_id
LEFT JOIN {{ ref('lost_reasons') }} AS clr
    ON d.lost_reason_id = clr.lost_reason_id
