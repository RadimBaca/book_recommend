select * 
from {{ source('staging', 'Rating') }}