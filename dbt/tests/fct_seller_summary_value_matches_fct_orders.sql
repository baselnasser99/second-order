-- Fails (returns a row) if seller order values don't add up to total order value.
select summary_value, orders_value
from (
    select
        (select sum(order_value) from {{ ref('fct_seller_summary') }}) as summary_value,
        (select sum(items_value) from {{ ref('fct_orders') }}) as orders_value
)
where summary_value is distinct from orders_value  -- also fails if either sum is NULL
