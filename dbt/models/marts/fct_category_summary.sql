-- One row per product category, for dashboard page 2. Counts and sums, not rates, so Data
-- Studio computes each rate as SUM / SUM and it stays correct in any grouping.
-- Same queries as docs/metrics.md section 3: first one row per order per category, because
-- is_late and review_score repeat on every item of an order.
with orders_per_category as (
    select
        product_category,
        order_id,
        any_value(is_late) as is_late,  -- the same value on every item of the order
        any_value(review_score) as review_score
    from {{ ref('fct_order_items') }}
    group by product_category, order_id
),

order_counts as (
    select
        product_category,
        count(*) as orders,
        countif(is_late) as late_orders,
        count(is_late) as orders_with_delivery_date,
        sum(review_score) as review_score_sum,
        count(review_score) as orders_with_review
    from orders_per_category
    group by product_category
),

-- summed over items, not per-order rows, so each category gets only its own items' prices
category_value as (
    select
        product_category,
        sum(price) as order_value
    from {{ ref('fct_order_items') }}
    group by product_category
)

select
    c.product_category,
    c.orders,
    c.late_orders,
    c.orders_with_delivery_date,
    c.review_score_sum,
    c.orders_with_review,
    v.order_value,
    -- 'unknown' is unlabeled products mixed together, not an actionable category (decision log, M4-05)
    c.orders >= 30 and c.product_category != 'unknown' as in_rankings
from order_counts as c
inner join category_value as v
    on c.product_category = v.product_category
