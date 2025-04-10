with book_lower as (
    SELECT lower(b."Book-Title") BookTitle, 
        lower(b."Book-Author") BookAuthor,
        lower(b.ISBN) LowerISBN
    FROM {{ ref('stg_book') }} b
),
book_isbn1 as (
    SELECT *,
         (
            select string_agg(matched, '')
            from (
              SELECT 
                UNNEST(REGEXP_EXTRACT_ALL(LowerISBN, '[0-9x]+')) AS matched
            )
         ) AS CleanedISBN
    FROM book_lower
),
book_isbn2 as (
    SELECT *,
         left(CleanedISBN, 9) AS ShortenedCleanedISBN
    FROM book_isbn1
),
books_with_row_number as (
    select *, row_number() over (partition by ShortenedCleanedISBN order by len(BookTitle)) as rn
    from book_isbn2
) 
select BookTitle, BookAuthor, LowerISBN, CleanedISBN, ShortenedCleanedISBN
from books_with_row_number
where rn = 1