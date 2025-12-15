
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    unique_activity_id as unique_field,
    count(*) as n_records

from "postgres"."public_cl_enpal"."activity"
where unique_activity_id is not null
group by unique_activity_id
having count(*) > 1



  
  
      
    ) dbt_internal_test