-- Fails (returns a row) if a join added or lost orders.
select fct_rows, stg_rows
from (
    select
        (select count(*) from {{ ref('fct_orders') }}) as fct_rows,
        (select count(*) from {{ ref('stg_orders') }}) as stg_rows
)
where fct_rows != stg_rows
