# Metric definitions (M4-02)

Every number on the dashboard, in plain words, with the mart table and columns it uses and the SQL that produces it. The dashboard uses these definitions; if a chart and this file disagree, this file is right and the chart needs fixing.

Every query below was run as written on Oct 28, 2026; the results are from that run.

## Rules for every metric

- Every metric reads a mart table in `ecommerce_dbt`: `dim_customers`, `fct_orders` or `fct_order_items`. Nothing reads raw or staging. The only exception is the hand-checks at the end, which read the raw tables in `ecommerce_analytics` on purpose.
- Rates count orders or people, never items. An order with three items counts once.
- NULL means "no data" and is left out of rates and averages. `COUNT(col)` and `AVG(col)` skip NULLs; `COUNT(*)` doesn't.
- Money is in Brazilian reais (BRL), stored as NUMERIC (an exact decimal type, so cents never drift).
- Orders of every status count unless a metric says otherwise (decision log, M3-05).

## 1. Customers (`dim_customers`, page 1)

One row per real person (`customer_unique_id`).

### People

How many different people placed at least one order.

```sql
SELECT COUNT(*) AS people
FROM `ecommerce_dbt.dim_customers`
```

Result: 96,096.

### Repeat customers

People who placed more than one order, of any status, on any day. Uses `is_repeat_customer`.

```sql
SELECT COUNTIF(is_repeat_customer) AS repeat_customers
FROM `ecommerce_dbt.dim_customers`
```

Result: 2,997.

### Repeat rate

Repeat customers divided by all people.

```sql
SELECT COUNTIF(is_repeat_customer) / COUNT(*) AS repeat_rate
FROM `ecommerce_dbt.dim_customers`
```

Result: 2,997 / 96,096 = 3.12%.

### 180-day return rate

Of the people with full follow-up (first order on or before 2018-02-22), the share who came back within 180 days. Uses `has_full_followup` and `returned_within_180_days`. A same-day order and a canceled or unavailable order don't count as coming back (decision log). People without full follow-up are left out, so everyone compared had the same 180 days to return.

```sql
SELECT
  COUNT(*) AS people_with_full_followup,
  COUNTIF(returned_within_180_days) AS returned,
  COUNTIF(returned_within_180_days) / COUNT(*) AS return_rate_180_days
FROM `ecommerce_dbt.dim_customers`
WHERE has_full_followup
```

Result: 1,116 / 56,007 = 1.99%.

Page 1 splits this rate by `first_order_is_late` (late vs on time) and by `first_order_review_score` (1–5), with `people_with_full_followup` shown next to each rate as the group size. People whose first order has no delivery date or no review have NULL in that column and drop out of that chart.

## 2. Orders (`fct_orders`)

One row per order.

### Late-order rate

Orders delivered after their estimated date, divided by orders that have a delivery date. Uses `is_late`. Orders with no delivery date (`is_late` is NULL) are left out, because they can't be late or on time yet.

```sql
SELECT
  COUNTIF(is_late) AS late_orders,
  COUNT(is_late) AS orders_with_delivery_date,
  COUNTIF(is_late) / COUNT(is_late) AS late_order_rate
FROM `ecommerce_dbt.fct_orders`
```

Result: 6,535 late out of 96,476 orders with a delivery date = 6.77%.

### Average review per order

The average review score (1–5) over orders that have a review. Uses `review_score`, the order's most recent review.

```sql
SELECT AVG(review_score) AS average_review
FROM `ecommerce_dbt.fct_orders`
```

Result: 4.09.

### Order value

The sum of item prices, freight not included. Uses `items_value`. Orders with no items have NULL and add nothing.

```sql
SELECT SUM(items_value) AS order_value
FROM `ecommerce_dbt.fct_orders`
```

Result: 13,591,643.70.

Order value is `items_value` because page 2 has to split value by category and seller, and only item prices can be split that way (`fct_order_items.price`). `items_value` is the sum of those same prices, so page 1 and page 2 add up to the same total.

### Payment total

The sum of everything customers paid. Uses `payment_total`. Kept separate from order value, because payments include vouchers and installment fees and don't always equal items plus freight (decision log, M3-06).

```sql
SELECT SUM(payment_total) AS payment_total
FROM `ecommerce_dbt.fct_orders`
```

Result: 16,008,872.12.

Payment total is higher than order value (13,591,643.70) mainly because it includes freight (2,251,909.54), which order value leaves out. Of the remaining 165,318.88, 162,591.95 is payments on the 775 orders (any status) that have no items; the last 2,726.93 is the net of all other differences between payments and items plus freight (installment interest, for example); it wasn't broken down further.

### Payments on canceled and unavailable orders

What customers paid on orders that were canceled or unavailable. Uses `order_status` and `payment_total`.

This metric uses `payment_total`, while order value uses `items_value`, because 767 of these 1,234 orders (62.2%) have no items, so `items_value` would miss most of them.

```sql
SELECT
  order_status,
  COUNT(*) AS orders,
  COUNTIF(items_value IS NULL) AS orders_without_items,
  COUNTIF(payment_total IS NULL) AS orders_without_payment,
  SUM(payment_total) AS payments
FROM `ecommerce_dbt.fct_orders`
WHERE order_status IN ('canceled', 'unavailable')
GROUP BY order_status
```

| Status | Orders | Without items | Without payment | Payments (BRL) |
|---|---|---|---|---|
| canceled | 625 | 164 | 0 | 143,255.60 |
| unavailable | 609 | 603 | 0 | 126,479.51 |
| Both | 1,234 | 767 | 0 | 269,735.11 |

No canceled or unavailable order is missing both items and payment, so `payment_total` covers all 1,234. Because most of these orders have no items, this metric is one total, not split by category or seller.

## 3. Categories and sellers (`fct_order_items`, page 2)

One row per item. `is_late` and `review_score` are copied from the order onto every item, so each query first reduces to one row per order in each group. Otherwise a 3-item order would count three times. An order with items in two categories (or from two sellers) counts once in each.

Groups with fewer than 30 orders are left out of rankings, so one seller with 2 bad orders can't top the list.

Items whose product has no category are in the category `unknown` (1,603 items, decision log M3-07). `unknown` is kept in every total, so category values still add up to order value; M4-05 decides whether it appears in rankings.

Categories come first, then sellers. Sellers are shown by `seller_id`, a code, because the data has no seller names.

### Orders, late-order rate and average review per category

```sql
WITH orders_per_category AS (
  SELECT
    product_category,
    order_id,
    ANY_VALUE(is_late) AS is_late,  -- the same value on every item of the order
    ANY_VALUE(review_score) AS review_score
  FROM `ecommerce_dbt.fct_order_items`
  GROUP BY product_category, order_id
)
SELECT
  product_category,
  COUNT(*) AS orders,
  SAFE_DIVIDE(COUNTIF(is_late), COUNT(is_late)) AS late_order_rate,  -- NULL, not an error, when no order has a delivery date
  AVG(review_score) AS average_review
FROM orders_per_category
GROUP BY product_category
HAVING COUNT(*) >= 30
```

Result: 63 of 74 categories have at least 30 orders.

### Order value per category

The sum of item prices in the category, freight not included. Uses `price`. Each row is one item with its own category, so a category's total holds only its own items' prices, never the rest of the order. An order with items in two categories counts once in each category's `orders`, and each category gets only its own items' prices. This is the same definition as order value in section 2: across all categories it adds up to `SUM(fct_orders.items_value)`.

```sql
SELECT
  product_category,
  COUNT(DISTINCT order_id) AS orders,
  SUM(price) AS order_value
FROM `ecommerce_dbt.fct_order_items`
GROUP BY product_category
HAVING COUNT(DISTINCT order_id) >= 30
```

Result: 63 categories. Over all 74 categories, before the 30-order cut, item prices add up to 13,591,643.70, the same as `SUM(fct_orders.items_value)`.

### Orders, late-order rate and average review per seller

The same as per category, grouped by `seller_id`. An order with items from two sellers counts once for each.

```sql
WITH orders_per_seller AS (
  SELECT
    seller_id,
    order_id,
    ANY_VALUE(is_late) AS is_late,  -- the same value on every item of the order
    ANY_VALUE(review_score) AS review_score
  FROM `ecommerce_dbt.fct_order_items`
  GROUP BY seller_id, order_id
)
SELECT
  seller_id,
  COUNT(*) AS orders,
  SAFE_DIVIDE(COUNTIF(is_late), COUNT(is_late)) AS late_order_rate,  -- NULL, not an error, when no order has a delivery date
  AVG(review_score) AS average_review
FROM orders_per_seller
GROUP BY seller_id
HAVING COUNT(*) >= 30
```

Result: 634 of 3,095 sellers have at least 30 orders.

### Order value per seller

The sum of the seller's item prices, freight not included. Each seller gets only their own items' prices.

```sql
SELECT
  seller_id,
  COUNT(DISTINCT order_id) AS orders,
  SUM(price) AS order_value
FROM `ecommerce_dbt.fct_order_items`
GROUP BY seller_id
HAVING COUNT(DISTINCT order_id) >= 30
```

Result: 634 sellers, the same ones as the query above.

## 4. Hand-checks against the raw tables

Three numbers recomputed from the raw tables in `ecommerce_analytics`, without dbt, to prove the marts are right. Each query copies the staging steps: `NULLIF(TRIM(col), '')` for blanks, the same casts, NUMERIC for money.

### Repeat customers: expected 2,997

Joins orders to customers and counts orders per `customer_unique_id`, the same way `dim_customers` does.

```sql
SELECT COUNTIF(orders > 1) AS repeat_customers
FROM (
  SELECT NULLIF(TRIM(c.customer_unique_id), '') AS customer_unique_id, COUNT(*) AS orders
  FROM `ecommerce_analytics.raw_orders` AS o
  JOIN `ecommerce_analytics.raw_customers` AS c
    ON NULLIF(TRIM(o.customer_id), '') = NULLIF(TRIM(c.customer_id), '')
  GROUP BY 1
)
```

Result: 2,997. Matches.

### Late orders: expected 6,535

The same comparison as `fct_orders.is_late`: delivery date after the estimated delivery date, both cast the way staging casts them.

```sql
SELECT
  COUNTIF(
    DATE(CAST(NULLIF(TRIM(order_delivered_customer_date), '') AS DATETIME))
      > CAST(CAST(NULLIF(TRIM(order_estimated_delivery_date), '') AS DATETIME) AS DATE)
  ) AS late_orders
FROM `ecommerce_analytics.raw_orders`
```

Result: 6,535. Matches.

### Payment total: expected 16,008,872.12

```sql
SELECT SUM(CAST(NULLIF(TRIM(payment_value), '') AS NUMERIC)) AS payment_total
FROM `ecommerce_analytics.raw_order_payments`
```

Result: 16,008,872.12. Matches.

## 5. Data Studio setup for page 1

The calculated fields below live inside the report's `dim_customers` data source. Removing and re-adding the data source deletes them, so re-enter them from here. Each one matches a metric in section 1.

| Field | Formula | Type | Matches |
|---|---|---|---|
| `repeat_customers` | `SUM(CASE WHEN is_repeat_customer = true THEN 1 ELSE 0 END)` | Number | Repeat customers (2,997) |
| `repeat_rate` | `SUM(CASE WHEN is_repeat_customer = true THEN 1 ELSE 0 END) / COUNT(customer_unique_id)` | Percent | Repeat rate (3.12%) |
| `people_full_followup` | `SUM(CASE WHEN has_full_followup = true THEN 1 ELSE 0 END)` | Number | People with full follow-up (56,007) |
| `return_rate_180d` | `SUM(CASE WHEN returned_within_180_days = true THEN 1 ELSE 0 END) / SUM(CASE WHEN has_full_followup = true THEN 1 ELSE 0 END)` | Percent | 180-day return rate (1.99%) |
| `first_order_timing` | `CASE WHEN first_order_is_late = true THEN "Late" WHEN first_order_is_late = false THEN "On time" END` | Text | Label for `first_order_is_late` |

`return_rate_180d` divides by full-follow-up people itself, so it stays correct even if a chart's filter is missing. `first_order_timing` names both cases, so a NULL stays NULL instead of being labelled "On time".

Data source settings: owner's credentials, community visualizations off, `first_order_review_score` default aggregation Average.

### Page 1 charts

- Scorecards: People (Record Count, 96,096), Repeat customers (2,997), Repeat rate (3.12%).
- Return rate by first-order timing: a table with `first_order_timing`, `return_rate_180d` and `people_full_followup`. Filter: include `has_full_followup` = true, exclude `first_order_timing` is null. Result: on time 2.02% (50,681 people), late 1.69% (3,317).
- Return rate by first-order review score: the same table with `first_order_review_score`, sorted ascending. Filter: include `has_full_followup` = true, exclude `first_order_review_score` is null. Results: 1 = 1.68% (6,544), 2 = 1.53% (1,832), 3 = 1.98% (4,800), 4 = 1.84% (10,913), 5 = 2.15% (31,437).
- Cross-filtering is off on both tables, so clicking a row doesn't filter the whole page.

Hand-checked with direct SQL on `dim_customers` on Oct 28, 2026: late, on time and score 5 all match.
