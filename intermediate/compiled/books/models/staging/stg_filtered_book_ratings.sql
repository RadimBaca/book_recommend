SELECT "User-ID" UserId, lower(ISBN) ISBN, "Book-Rating" BookRating 
FROM "dev"."main"."stg_book_ratings"
WHERE "Book-Rating" between 1 and 10