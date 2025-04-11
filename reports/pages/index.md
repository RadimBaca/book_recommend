---
title: Welcome to Book Recomender
---

<TextInput
    name=input_book
    title="Enter phrase searched in book names"
/>

<Slider
    title="# common users treshold" 
    name=input_treshold
    min=0
    max=30
/>

Searching for '{inputs.input_book}'

# Books finded
<DataTable data={find_book}/>

# Recommended books
<DataTable data={rec_book}/>

```sql find_book
SELECT
    a.BookTitle as "Book title",
    a.BookAuthor as "Book author",
    a.LowerISBN as "ISBN"
FROM books.stg_normalized_book a
WHERE a.BookTitle = lower('${inputs.input_book}')
```

```sql rec_book
SELECT
    b.BookTitle AS "Book title",
    CORR(a.AvgRating, b.AvgRating) AS Correlation,
    avg(b.AvgRating) "Avg book rating",
  count(distinct a.UserID) "# Readers who rated"
FROM books.avg_book_rating a
JOIN books.avg_book_rating b ON a.UserID = b.UserID
WHERE a.BookTitle = lower('${inputs.input_book}')
  AND b.BookTitle != a.BookTitle
GROUP BY b.BookTitle
HAVING COUNT(distinct a.UserID) >= ${inputs.input_treshold}
ORDER BY correlation DESC
LIMIT 10
```


<!-- 
<Dropdown data={categories} name=category value=category>
    <DropdownOption value="%" valueLabel="All Categories"/>
</Dropdown>

<Dropdown name=year>
    <DropdownOption value=% valueLabel="All Years"/>
    <DropdownOption value=2019/>
    <DropdownOption value=2020/>
    <DropdownOption value=2021/>
</Dropdown>

```sql orders_by_category
  select 
      date_trunc('month', order_datetime) as month,
      sum(sales) as sales_usd,
      category
  from needful_things.orders
  where category like '${inputs.category.value}'
  and date_part('year', order_datetime) like '${inputs.year.value}'
  group by all
  order by sales_usd desc
```

<BarChart
    data={orders_by_category}
    title="Sales by Month, {inputs.category.label}"
    x=month
    y=sales_usd
    series=category
/>
 -->
