select *
from {{ source('staging', 'Book_reject_table') }} 