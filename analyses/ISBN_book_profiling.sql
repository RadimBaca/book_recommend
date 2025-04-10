select isbn_length, count(*) as count
from (
    select length(ShortenedCleanedISBN) as isbn_length
    from {{ ref('stg_normalized_book') }}
) t
group by isbn_length

