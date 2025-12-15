
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select unique_activity_id
from "postgres"."public_cl_enpal"."deals"
where unique_activity_id is null



  
  
      
    ) dbt_internal_test