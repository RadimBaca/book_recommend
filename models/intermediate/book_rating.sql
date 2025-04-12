{{ config(materialized='table') }}

SELECT r.UserID, 
    r.LowerISBN, 
    r.ShortenedCleanedISBN,
    r.BookRating, 
    b.BookTitle, 
    b.BookAuthor,
    b.NormBookTitle,
    b.NormBookAuthor
FROM {{ ref('stg_filtered_book_rating') }} r
JOIN {{ ref('stg_normalized_book') }} b ON r.ShortenedCleanedISBN = b.ShortenedCleanedISBN