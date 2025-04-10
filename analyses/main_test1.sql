with tolkien_readers as (
    SELECT *
    FROM {{ ref('avg_book_rating') }}
    WHERE BookTitle = 'the fellowship of the ring (the lord of the rings, part 1)'
        AND BookAuthor LIKE '%tolkien%'    
),
tolkien_readers_books as (
    SELECT BookTitle, COUNT(*) AS num_ratings
    FROM {{ ref('avg_book_rating') }}
    WHERE UserID IN (SELECT UserID FROM tolkien_readers)
    GROUP BY BookTitle
    HAVING COUNT(*) >= 8
),    
tolkien_readers_books_ratings as (
    SELECT *
    FROM {{ ref('avg_book_rating') }}
    WHERE BookTitle IN (SELECT BookTitle FROM tolkien_readers_books) and 
          UserID IN (SELECT UserID FROM tolkien_readers)
)
SELECT
    b.BookTitle AS book2,
    CORR(a.AvgRating, b.AvgRating) AS correlation,
    avg(b.AvgRating),
  count(b.AvgRating)
FROM tolkien_readers_books_ratings a
JOIN tolkien_readers_books_ratings b ON a.UserID = b.UserID
WHERE a.BookTitle = 'the fellowship of the ring (the lord of the rings, part 1)'
  AND b.BookTitle != a.BookTitle
GROUP BY a.BookTitle, b.BookTitle
ORDER BY correlation DESC


