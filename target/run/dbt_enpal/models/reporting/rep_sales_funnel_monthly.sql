
      insert into "postgres"."public_rl_enpal"."rep_sales_funnel_monthly" ("month", "kpi_name", "funnel_step", "deals_count")
    (
        select "month", "kpi_name", "funnel_step", "deals_count"
        from "rep_sales_funnel_monthly__dbt_tmp201004342396"
    )


  