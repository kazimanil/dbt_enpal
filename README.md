## Setup

1. Download Docker Desktop (if you don’t have installed) using the official website, install and launch.
2. Fork this Github project to you Github account. Clone the forked repo to your device.
3. Open your Command Prompt or Terminal, navigate to that folder, and run the command `docker compose up`.
4. Now you have launched a local Postgres database with the following credentials:
 ```
    Host: localhost
    User: admin
    Password: admin
    Port: 5432 
```
5. Connect to the db via a preferred tool (e.g. DataGrip, Dbeaver etc)
6. Install dbt-core and dbt-postgres using pip (if you don’t have) on your preferred environment.
7. Now you can run `dbt run` with the test model and check public_pipedrive_analytics schema to see the dbt result (with one test model)

**Important Note:** If you'd like these steps to work, then avoid using Python's latest 3.14 version as dbt currently has compatibility issues with it.

## Project
1. Remove the test model once you make sure it works
2. Dive deep into the Pipedrive CRM source data to gain a thorough understanding of all its details. (You may also research the Pipedrive CRM tool terms).
3. Define DBT sources and build the necessary layers organizing the data flow for optimal relevance and maintainability.
4. Build a reporting model (rep_sales_funnel_monthly) with monthly intervals, incorporating the following funnel steps (KPIs):  
  &nbsp;&nbsp;&nbsp;Step 1: Lead Generation  
  &nbsp;&nbsp;&nbsp;Step 2: Qualified Lead  
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Step 2.1: Sales Call 1  
  &nbsp;&nbsp;&nbsp;Step 3: Needs Assessment  
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Step 3.1: Sales Call 2  
  &nbsp;&nbsp;&nbsp;Step 4: Proposal/Quote Preparation  
  &nbsp;&nbsp;&nbsp;Step 5: Negotiation  
  &nbsp;&nbsp;&nbsp;Step 6: Closing  
  &nbsp;&nbsp;&nbsp;Step 7: Implementation/Onboarding  
  &nbsp;&nbsp;&nbsp;Step 8: Follow-up/Customer Success  
  &nbsp;&nbsp;&nbsp;Step 9: Renewal/Expansion
5. Column names of the reporting model: `month`, `kpi_name`, `funnel_step`, `deals_count`
6. “Git commit” all the changes and create a PR to your forked repo (not the original one). Send your repo link to us.

## Notes

Usually funnel views are snapshots of the current state of the deals. However, in this case, final output requires historical data as well throughout the required `month` column. Therefore, I will create a curated table `deal_stages` to capture the historical changes to the deal stages.

### Data Preparation

#### Activity Types Table

A simple table with more detail on the activity types. It shows `Follow Up Call` to be not active. However, I will ignore that as it is used in the `activity` table and required to calculate the 8th step of the funnel.

#### Stages Table
Stages table explain the changes to the deal stages from the `deal_changes` table. However checking the `deal_changes` table alone won't help us solve this task as there are two call steps for 2nd and 3rd stages. In order to catch those, `activity` table also needs to be considered. 

```
1 Lead Generation
2 Qualified Lead _possibly with a Sales Call 1_
3 Needs Assessment _possibly with a Sales Call 2_
4 Proposal/Quote Preparation
5 Negotiation
6 Closing
7 Implementation/Onboarding
8 Follow-up/Customer Success
9 Renewal/Expansion
```

This table could also be created via parsing the JSON template in the `fields` table's lost_reason row.

#### Fields Table

It is explaining the fields of other tables in a JSON format. It could be used to understand to the meaning of the lost reasons. I will utilise a JSON parse to create `activity` table.

#### Activity Table

Each record has two duplicates here. So I will de-duplicate it for the curated pipeline.

```
SELECT COUNT(*) FROM (SELECT DISTINCT * FROM activity) -- 4579
```

There is only one exception where `sc_2` happens earlier than `meeting` for the same deal (deal_id = 960413). For this case, I will ignore this exception and not illustrate it in the final output. This case also doesn't have any records in the deal changes table, so this is a safe assumption.

#### Deal Changes Table

There are cases with duplicate entries again on this table. I will first eliminate those duplicates.

```
SELECT deal_id, changed_field_key, new_value, COUNT(*)
FROM public.deal_changes
GROUP BY 1, 2, 3
HAVING COUNT(*) > 1;
```

This will reduce the table size from 92436 to 15406 rows.

```
SELECT COUNT(*) FROM public_cl_enpal.deals; -- 15406
SELECT COUNT(*) FROM deal_changes; -- 92436
```

On top of this duplication, there are some cases where the process is restarted (see `955417` for an example). As we are interested only in the amount of changes and there is no warning that states a process can't be restarted, I will keep those records as is.

#### Users Table

There are 21 users with duplicate names. However, their IDs are different and we are focused on deals, so I will not take any action on this.

```
SELECT 
    COUNT(DISTINCT(name)),  -- 1766
    COUNT(*) -- 1787
FROM users;
```

To query the list of users with multiple IDs (or users with the same name):

```
SELECT *
FROM users WHERE name IN (
  SELECT name
  FROM users
  GROUP BY 1
  HAVING COUNT(id) > 1
)
ORDER BY 2, 1;
```
#### Curated Layer

These tables are described in the schema__curated.yml file. They are prepared according to the notes above.

#### Reporting Layer

## Glossary

I used these two websited to acquaint myself with Pipedrive terms:
- [Pipedrive Glossary](https://support.pipedrive.com/en/article/pipedrive-glossary)
- [Top Result on Google for Pipedrive Terms](https://www.google.com/search?q=Pipedrive+CRM+tool+terms&oq=Pipedrive+CRM+tool+terms&gs_lcrp=EgZjaHJvbWUqBggAEEUYOzIGCAAQRRg70gEHMzI2ajBqN6gCALACAA&sourceid=chrome&ie=UTF-8)
