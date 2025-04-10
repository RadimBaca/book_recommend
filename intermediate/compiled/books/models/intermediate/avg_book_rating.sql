select UserId, 
    BookTitle, 
    BookAuthor,
    avg(BookRating) AS AvgRating
from "dev"."main"."book_ratings"
group by UserId, BookTitle, BookAuthor