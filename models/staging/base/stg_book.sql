select * 
from {{ source('staging', 'Book') }}