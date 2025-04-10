
  
  create view "dev"."main"."stg_book_ratings__dbt_tmp" as (
    select * 
from "dev"."staging"."Ratings"
  );
