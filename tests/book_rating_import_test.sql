select *
from {{ source('staging', 'Rating_reject_table') }} 