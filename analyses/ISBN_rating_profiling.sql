select isbn_length, count(*) as count
from (
    select length(ShortenedCleanedISBN) as isbn_length
    from {{ ref('stg_filtered_book_rating') }}
) t
group by isbn_length

