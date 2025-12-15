
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select lost_reason_id
from "postgres"."public_cl_enpal"."lost_reasons"
where lost_reason_id is null



  
  
      
    ) dbt_internal_test