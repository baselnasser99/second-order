-- Rules from docs/data-notes.md: blanks become NULL. Joined to products later, in the marts.
select
    nullif(trim(product_category_name), '') as product_category_name,
    nullif(trim(product_category_name_english), '') as product_category_name_english
from {{ source('olist', 'raw_product_category_translation') }}
