SELECT
    b.BookTitle AS book2,
    CORR(a.AvgRating, b.AvgRating) AS correlation,
    avg(b.AvgRating),
  count(b.AvgRating)
FROM {{ ref('avg_book_rating') }} a
JOIN {{ ref('avg_book_rating') }} b ON a.UserID = b.UserID
WHERE a.BookTitle = 'the fellowship of the ring (the lord of the rings, part 1)'
  AND b.BookTitle != a.BookTitle
GROUP BY b.BookTitle
HAVING COUNT(*) >= 8
ORDER BY correlation DESC