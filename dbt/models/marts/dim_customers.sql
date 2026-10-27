-- One row per real person. A new customer_id is made for every order, so people are
-- grouped by customer_unique_id. Orders of every status count (decision log, M3-05).
with people as (
    select
        c.customer_unique_id,
        -- state on the person's most recent order; order_id breaks ties so the result never changes between runs
        array_agg(c.customer_state order by o.order_purchase_timestamp desc, o.order_id desc limit 1)[offset(0)] as customer_state,
        -- earliest order, any status, same tie-break
        array_agg(o.order_id order by o.order_purchase_timestamp, o.order_id limit 1)[offset(0)] as first_order_id,
        min(o.order_purchase_timestamp) as first_order_at,
        max(o.order_purchase_timestamp) as last_order_at,
        count(*) as number_of_orders,
        count(*) > 1 as is_repeat_customer,
        -- first order at least 180 days before the end of the data, so everyone compared had the same chance to come back
        date(min(o.order_purchase_timestamp)) <= date_sub(date('{{ var("end_of_data") }}'), interval 180 day) as has_full_followup
    from {{ ref('stg_orders') }} as o
    join {{ ref('stg_customers') }} as c
        on o.customer_id = c.customer_id
    group by c.customer_unique_id
),

-- people with a non-canceled, non-unavailable order 1 to 180 calendar days after the first order's date
returns as (
    select distinct p.customer_unique_id
    from people as p
    join {{ ref('fct_orders') }} as o
        on o.customer_unique_id = p.customer_unique_id
    where o.order_status not in ('canceled', 'unavailable')
        and date_diff(date(o.order_purchase_timestamp), date(p.first_order_at), day) between 1 and 180
)

select
    p.customer_unique_id,
    p.customer_state,
    p.first_order_at,
    p.last_order_at,
    p.number_of_orders,
    p.is_repeat_customer,
    p.first_order_id,
    f.is_late as first_order_is_late,
    f.review_score as first_order_review_score,
    p.has_full_followup,
    if(p.has_full_followup, r.customer_unique_id is not null, null) as returned_within_180_days
from people as p
left join {{ ref('fct_orders') }} as f
    on p.first_order_id = f.order_id
left join returns as r
    on p.customer_unique_id = r.customer_unique_id
