select UserId, 
    BookTitle, 
    BookAuthor,
    ShortenedCleanedISBN,
    avg(BookRating) AS AvgRating
from {{ ref('book_rating') }}
group by UserId, BookTitle, BookAuthor, ShortenedCleanedISBN
