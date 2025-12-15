
    
    

select
    deal_id as unique_field,
    count(*) as n_records

from "postgres"."public_cl_enpal"."deal_stages"
where deal_id is not null
group by deal_id
having count(*) > 1


