select UserId, 
    NormBookTitle, 
    NormBookAuthor,
    max(BookTitle) BookTitle,
    max(BookAuthor) BookAuthor,
    avg(BookRating) AS AvgRating
from {{ ref('book_rating') }}
group by UserId, NormBookTitle, NormBookAuthor
