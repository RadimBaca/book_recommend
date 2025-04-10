with tolkien_readers as (
    SELECT *
    FROM {{ ref('book_rating') }}
    WHERE BookTitle = 'the fellowship of the ring (the lord of the rings, part 1)'
        AND BookAuthor LIKE '%tolkien%'    
),
books_by_tolkien_readers as (
    SELECT *
    FROM {{ ref('book_rating') }}
    WHERE UserID IN (SELECT UserID FROM tolkien_readers)
),
books_rating_counts as (
    SELECT BookTitle, COUNT(*) AS num_ratings
    FROM books_by_tolkien_readers
    GROUP BY BookTitle
    HAVING COUNT(*) >= 8
),
user_book_ratings as (
    SELECT UserID, BookTitle, AVG(BookRating) AS AvgRating
    FROM books_by_tolkien_readers
    WHERE BookTitle IN (SELECT BookTitle FROM books_rating_counts)
    GROUP BY UserID, BookTitle
)
SELECT
    b.BookTitle AS book2,
    CORR(a.AvgRating, b.AvgRating) AS correlation,
    avg(b.AvgRating),
  count(a.AvgRating)
FROM user_book_ratings a
JOIN user_book_ratings b ON a.UserID = b.UserID
WHERE a.BookTitle = 'the fellowship of the ring (the lord of the rings, part 1)'
  AND b.BookTitle != a.BookTitle
GROUP BY a.BookTitle, b.BookTitle
ORDER BY correlation DESC