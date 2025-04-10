with lower_rating as (
  SELECT "User-ID" UserId, 
    lower(ISBN) LowerISBN, 
    "Book-Rating" BookRating 
  FROM {{ ref('stg_book_rating') }}
),
rating_isbn1 as (
  SELECT *,
         (
            select string_agg(matched, '')
            from (
              SELECT 
                UNNEST(REGEXP_EXTRACT_ALL(LowerISBN, '[0-9x]+')) AS matched
            )
         ) AS CleanedISBN
  FROM lower_rating
),
rating_isbn2 as (
    SELECT *,
         left(CleanedISBN, 9) AS ShortenedCleanedISBN
    FROM rating_isbn1
)
SELECT UserId, LowerISBN, BookRating, CleanedISBN, ShortenedCleanedISBN
FROM rating_isbn2
WHERE BookRating between 1 and 10