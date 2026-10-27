-- One row per order. Items, payments and reviews can have many rows per order, so each is
-- reduced to one row per order before joining; left joins keep every order. No items or
-- payments gives NULL, not 0 (decision log, M3-06).
with items as (
    select
        order_id,
        sum(price) as items_value,
        sum(freight_value) as freight_value
    from {{ ref('stg_order_items') }}
    group by order_id
),

payments as (
    select
        order_id,
        sum(payment_value) as payment_total
    from {{ ref('stg_order_payments') }}
    group by order_id
),

reviews as (
    select
        order_id,
        -- most recent review; review_id breaks ties so the result never changes between runs
        array_agg(review_score order by review_creation_date desc, review_id desc limit 1)[offset(0)] as review_score
    from {{ ref('stg_order_reviews') }}
    group by order_id
)

select
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    o.order_status,
    o.order_purchase_timestamp,
    i.items_value,
    i.freight_value,
    p.payment_total,
    -- calendar days; NULL when there is no delivery date
    date_diff(date(o.order_delivered_customer_date), date(o.order_purchase_timestamp), day) as delivery_days,
    date(o.order_delivered_customer_date) > o.order_estimated_delivery_date as is_late,
    r.review_score
from {{ ref('stg_orderz') }} as o
left join {{ ref('stg_customers') }} as c
    on o.customer_id = c.customer_id
left join items as i
    on o.order_id = i.order_id
left join payments as p
    on o.order_id = p.order_id
left join reviews as r
    on o.order_id = r.order_id
