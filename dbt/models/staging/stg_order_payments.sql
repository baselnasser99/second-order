-- Rules from docs/data-notes.md: blanks become NULL, plain CAST so bad values fail the build,
-- NUMERIC for money, INT64 for counts.
select
    nullif(trim(order_id), '') as order_id,
    cast(nullif(trim(payment_sequential), '') as int64) as payment_sequential,
    nullif(trim(payment_type), '') as payment_type,
    cast(nullif(trim(payment_installments), '') as int64) as payment_installments,
    cast(nullif(trim(payment_value), '') as numeric) as payment_value
from {{ source('olist', 'raw_order_payments') }}
