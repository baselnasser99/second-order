-- Rules from docs/data-notes.md: blanks become NULL, plain CAST so bad values fail the build,
-- NUMERIC for money, DATETIME because the source has Brazil local time with no timezone.
select
    nullif(trim(order_id), '') as order_id,
    cast(nullif(trim(order_item_id), '') as int64) as order_item_id,
    nullif(trim(product_id), '') as product_id,
    nullif(trim(seller_id), '') as seller_id,
    cast(nullif(trim(shipping_limit_date), '') as datetime) as shipping_limit_date,
    cast(nullif(trim(price), '') as numeric) as price,
    cast(nullif(trim(freight_value), '') as numeric) as freight_value
from {{ source('olist', 'raw_order_items') }}
