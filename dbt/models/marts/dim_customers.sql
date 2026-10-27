-- One row per real person. A new customer_id is made for every order, so people are
-- grouped by customer_unique_id. Orders of every status count (decision log, M3-05).
select
    c.customer_unique_id,
    -- state on the person's most recent order; order_id breaks ties so the result never changes between runs
    array_agg(c.customer_state order by o.order_purchase_timestamp desc, o.order_id desc limit 1)[offset(0)] as customer_state,
    min(o.order_purchase_timestamp) as first_order_at,
    max(o.order_purchase_timestamp) as last_order_at,
    count(*) as number_of_orders,
    count(*) > 1 as is_repeat_customer
from {{ ref('stg_orders') }} as o
join {{ ref('stg_customers') }} as c
    on o.customer_id = c.customer_id
group by c.customer_unique_id
