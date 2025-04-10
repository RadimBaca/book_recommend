

SELECT r.UserID, 
    r.ISBN, 
    r.BookRating, 
    lower(b."Book-Title") BookTitle, 
    lower(b."Book-Author") BookAuthor
FROM "dev"."main"."stg_filtered_book_ratings" r
JOIN "dev"."main"."stg_books" b ON lower(r.ISBN) = lower(b.ISBN)