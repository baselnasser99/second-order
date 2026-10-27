-- The source has many rows per zip prefix (see docs/data-notes.md), so this keeps one row per
-- prefix with the average position. City and state are left out: customers and sellers have their own.
select
    nullif(trim(geolocation_zip_code_prefix), '') as geolocation_zip_code_prefix,
    avg(cast(nullif(trim(geolocation_lat), '') as float64)) as geolocation_lat,
    avg(cast(nullif(trim(geolocation_lng), '') as float64)) as geolocation_lng
from {{ source('olist', 'raw_geolocation') }}
group by 1
