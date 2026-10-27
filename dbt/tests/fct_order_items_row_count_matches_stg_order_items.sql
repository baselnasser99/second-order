-- Fails (returns a row) if a join added or lost items.
select fct_rows, stg_rows
from (
    select
        (select count(*) from {{ ref('fct_order_items') }}) as fct_rows,
        (select count(*) from {{ ref('stg_order_items') }}) as stg_rows
)
where fct_rows != stg_rows
