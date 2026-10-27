-- Rules from docs/data-notes.md: blanks become NULL; zip prefix stays text to keep leading zeros.
select
    nullif(trim(customer_id), '') as customer_id,
    nullif(trim(customer_unique_id), '') as customer_unique_id,
    nullif(trim(customer_zip_code_prefix), '') as customer_zip_code_prefix,
    nullif(trim(customer_city), '') as customer_city,
    nullif(trim(customer_state), '') as customer_state
from {{ source('olist', 'raw_customers') }}
