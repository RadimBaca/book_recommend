
  
    
    

    create  table
      "dev"."main"."avg_book_rating__dbt_tmp"
  
    as (
      select UserId, 
    BookTitle, 
    BookAuthor,
    avg(BookRating) AS AvgRating
from "dev"."main"."book_ratings"
group by UserId, BookTitle, BookAuthor
    );
  
  