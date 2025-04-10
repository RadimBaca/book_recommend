select ShortenedCleanedISBN 
from {{ ref('stg_normalized_book') }}
group by ShortenedCleanedISBN
having count(*) > 1
