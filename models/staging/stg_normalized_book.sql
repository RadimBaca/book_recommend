with book_lower as (
    SELECT lower(b."Book-Title") BookTitle, 
        lower(b."Book-Author") BookAuthor,
        lower(b.ISBN) LowerISBN
    FROM {{ ref('stg_book') }} b
), remove_dots_and_hyphen as (
  select *,
    trim(replace(replace(BookAuthor, '-', ' '), '.', ' ')) NormBookAuthor,
    trim(regexp_replace(BookTitle, '[^a-z0-9]', '', 'g')) NormBookTitle
  from book_lower
), normalized_author AS (
  SELECT
    * EXCLUDE(NormBookAuthor),
    lower(split_part(NormBookAuthor, ' ', 1)) || ' ' ||
    lower(split_part(NormBookAuthor, ' ', -1)) AS NormBookAuthor
  FROM remove_dots_and_hyphen
), book_isbn1 as (
    SELECT *,
         (
            select string_agg(matched, '')
            from (
              SELECT 
                UNNEST(REGEXP_EXTRACT_ALL(LowerISBN, '[0-9x]+')) AS matched
            )
         ) AS CleanedISBN
    FROM normalized_author
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
select BookTitle, NormBookTitle, BookAuthor, NormBookAuthor, LowerISBN, ShortenedCleanedISBN
from books_with_row_number
where rn = 1