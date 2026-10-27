-- One row per order item. Products, sellers, the category translation and fct_orders are each
-- one row per key, so left joins keep every item and never add rows.
-- is_late and review_score are order-level: averaging them per item weights multi-item orders
-- more. M4 must average them per order.
select
    i.order_id,
    i.order_item_id,
    i.product_id,
    -- English name, else the Portuguese name, else 'unknown' (decision log, M3-07)
    coalesce(t.product_category_name_english, p.product_category_name, 'unknown') as product_category,
    i.seller_id,
    s.seller_state,
    i.price,
    i.freight_value,
    o.order_status,
    o.order_purchase_timestamp,
    o.is_late,
    o.review_score
from {{ ref('stg_order_items') }} as i
left join {{ ref('stg_products') }} as p
    on i.product_id = p.product_id
left join {{ ref('stg_product_category_translation') }} as t
    on p.product_category_name = t.product_category_name
left join {{ ref('stg_sellers') }} as s
    on i.seller_id = s.seller_id
left join {{ ref('fct_orders') }} as o
    on i.order_id = o.order_id
