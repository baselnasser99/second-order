-- Rules from docs/data-notes.md: blanks become NULL, plain CAST so bad values fail the build,
-- DATETIME because the source has Brazil local time with no timezone. Missing dates stay NULL.
select
    nullif(trim(order_id), '') as order_id,
    nullif(trim(customer_id), '') as customer_id,
    nullif(trim(order_status), '') as order_status,
    cast(nullif(trim(order_purchase_timestamp), '') as datetime) as order_purchase_timestamp,
    cast(nullif(trim(order_approved_at), '') as datetime) as order_approved_at,
    cast(nullif(trim(order_delivered_carrier_date), '') as datetime) as order_delivered_carrier_date,
    cast(nullif(trim(order_delivered_customer_date), '') as datetime) as order_delivered_customer_date,
    -- always midnight in the source, so a plain date
    cast(cast(nullif(trim(order_estimated_delivery_date), '') as datetime) as date) as order_estimated_delivery_date
from {{ source('olist', 'raw_orders') }}
