
  
  create view "dev"."main"."stg_books__dbt_tmp" as (
    select * 
from "dev"."staging"."Books"
  );
