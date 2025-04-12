SELECT
    MAX(b.BookTitle) AS BookTitle,
    CORR(a.AvgRating, b.AvgRating) AS correlation,
    avg(b.AvgRating),
  count(b.AvgRating)
FROM {{ ref('avg_book_rating') }} a
JOIN {{ ref('avg_book_rating') }} b ON a.UserID = b.UserID
WHERE Levenshtein(a.BookTitle, 'the fellowship of the ring (the lord of the rings, part 1)') <= 3
  AND b.NormBookTitle != a.NormBookTitle
GROUP BY b.NormBookTitle
HAVING COUNT(distinct a.UserID) >= 8
ORDER BY correlation DESC