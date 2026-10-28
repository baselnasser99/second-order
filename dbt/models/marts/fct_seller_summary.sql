-- One row per seller, for dashboard page 2. Counts and sums, not rates, so Data Studio
-- computes each rate as SUM / SUM and it stays correct in any grouping.
-- Same queries as docs/metrics.md section 3: first one row per order per seller, because
-- is_late and review_score repeat on every item of an order.
with orders_per_seller as (
    select
        seller_id,
        order_id,
        any_value(is_late) as is_late,  -- the same value on every item of the order
        any_value(review_score) as review_score
    from {{ ref('fct_order_items') }}
    group by seller_id, order_id
),

order_counts as (
    select
        seller_id,
        count(*) as orders,
        countif(is_late) as late_orders,
        count(is_late) as orders_with_delivery_date,
        sum(review_score) as review_score_sum,
        count(review_score) as orders_with_review
    from orders_per_seller
    group by seller_id
),

-- summed over items, not per-order rows, so each seller gets only their own items' prices
seller_value as (
    select
        seller_id,
        sum(price) as order_value
    from {{ ref('fct_order_items') }}
    group by seller_id
)

select
    c.seller_id,
    c.orders,
    c.late_orders,
    c.orders_with_delivery_date,
    c.review_score_sum,
    c.orders_with_review,
    v.order_value,
    c.orders >= 30 as in_rankings
from order_counts as c
inner join seller_value as v
    on c.seller_id = v.seller_id
