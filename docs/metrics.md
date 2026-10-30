# Metric definitions (M4-02)

Every number on the dashboard, in plain words, with the mart table and columns it uses and the SQL that produces it. The dashboard uses these definitions; if a chart and this file disagree, this file is right and the chart needs fixing.

Every query below was run as written on Oct 28, 2026; the results are from that run.

## Rules for every metric

- Every metric reads a mart table in `ecommerce_dbt`: `dim_customers`, `fct_orders`, `fct_order_items`, or the summary tables `fct_category_summary` and `fct_seller_summary` built from `fct_order_items`. Nothing reads raw or staging. The only exception is the hand-checks at the end, which read the raw tables in `ecommerce_analytics` on purpose.
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

People who ordered only once: 96,096 people minus 2,997 repeat customers = 93,099 (96.88%, about 97 in 100).

### Repeat rate

Repeat customers divided by all people.

```sql
SELECT COUNTIF(is_repeat_customer) / COUNT(*) AS repeat_rate
FROM `ecommerce_dbt.dim_customers`
```

Result: 2,997 / 96,096 = 3.12%.

### 180-day return rate

Of the people with full follow-up (first order on or before 2018-02-22), the share who came back within 180 days. Uses `has_full_followup` and `returned_within_180_days`. A same-day order and a canceled or unavailable order don't count as coming back (decision log). People without full follow-up are left out, so everyone compared had the same 180 days to return. The data ends 2018-08-21, 180 days after 2018-02-22.

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

Items whose product has no category are in the category `unknown` (1,603 items, decision log M3-07). `unknown` is left out of rankings (`in_rankings` = false) but kept in every total, so category values still add up to order value; it has 1,451 orders.

Categories come first, then sellers. Sellers are shown by `seller_id`, a code, because the data has no seller names.

For the dashboard, `fct_category_summary` and `fct_seller_summary` build these numbers, one row per category or seller. They store counts and sums, not finished rates, so Data Studio computes each rate as SUM / SUM and it stays correct in any grouping. Their `in_rankings` column applies the 30-order cut-off (and leaves out `unknown`). The queries in this section stay as the definitions. Result: 62 categories and 634 sellers are in rankings.

Both tables also show `late_orders`, the count, next to the late-order rate, so a high rate on a small seller can be read as a handful of orders.

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

## 5. Data Studio setup

### Design

**Design:** Roboto font; accent color teal #0F766E (theme color, hero scorecards, bars); bars start at 0 with the number visible; on Customers, the two return-rate bar columns are sized to share one scale (~42px per point); table row numbers off; light grey (#F5F5F5) table headers; sort arrows hidden by sorting each table on a hidden chart-level field; tables show the top 10 rows with no paging; captions #666; one shared left edge (scorecard left padding 8px, with each label's first letter lined up on its number's first digit). Canvas: report default 1200×1500; Customers custom 1200×565; Money custom 1200×1247. The README screenshots are full-canvas captures at device pixel ratio 2 (2400×1130 and 2400×2494), so future screenshots can be checked against those sizes.

**Scorecards** (all four): "Hide field name" on; number font size 48px; padding top 32px, left 8px, right 16px; border radius 8; shadow off; Compact numbers off.
- People and Repeat customers: background #FFFFFF, border #E5E7EB 1px, number #1F2937.
- Repeat rate and At-risk payments: background #F0FDFA, border #99D5CC 1px, number #0F766E.

**Scorecard labels** are separate text boxes, because Data Studio sizes a scorecard's own label together with its number. Each is Roboto 14px, transparent background, 200×25, 11px below the card's top and 2px from the card's left edge (3px for At-risk payments, because "A" has no space before it), so each label's first letter lines up with the number's first digit. They sit on top of the cards. Text "People", "Repeat customers", "Repeat rate" and "At-risk payments (BRL)"; color #666666 for the first two, #0F766E for the last two.

**Positions:**
- Customers: cards at y 124, 101px tall; captions at y 232; tables at y 304; lower captions at y 390 and 475; page 1200×565.
- Money: card at y 122, 100px tall; caption at y 233; Categories heading y 319; category table y 369, its caption y 704; Sellers heading y 779; seller tables y 819; bottom captions y 1154; page 1200×1247.

**Page headlines** (text boxes at the top of each page):
- Customers: "Only about 3 in 100 customers ever order again", with the subtitle "Olist orders 2016–2018 · 96,096 people".
- Money: "The most late orders come from large sellers, not the worst-rate small ones", with the subtitle "Olist orders 2016–2018 · 62 categories and 634 sellers with 30+ orders".

### Data Studio setup for page 1 ("Customers")

The calculated fields below live inside the report's `dim_customers` data source. Removing and re-adding the data source deletes them, so re-enter them from here. Each one matches a metric in section 1.

| Field | Formula | Type | Matches |
|---|---|---|---|
| `repeat_customers` | `SUM(CASE WHEN is_repeat_customer = true THEN 1 ELSE 0 END)` | Number | Repeat customers (2,997) |
| `repeat_rate` | `SUM(CASE WHEN is_repeat_customer = true THEN 1 ELSE 0 END) / COUNT(customer_unique_id)` | Percent | Repeat rate (3.12%) |
| `people_full_followup` | `SUM(CASE WHEN has_full_followup = true THEN 1 ELSE 0 END)` | Number | People with full follow-up (56,007) |
| `return_rate_180d` | `SUM(CASE WHEN returned_within_180_days = true THEN 1 ELSE 0 END) / SUM(CASE WHEN has_full_followup = true THEN 1 ELSE 0 END)` | Percent | 180-day return rate (1.99%) |
| `first_order_timing` | `CASE WHEN first_order_is_late = true THEN "Late" WHEN first_order_is_late = false THEN "On time" END` | Text | Label for `first_order_is_late` |

`return_rate_180d` divides by full-follow-up people itself, so it stays correct even if a chart's filter is missing. `first_order_timing` names both cases, so a NULL stays NULL instead of being labelled "On time".

Data source settings: owner's credentials, community visualizations off, `first_order_review_score` default aggregation Average. Data Studio fills in `first_order_at` as the date range dimension, with the default date range "Auto: All available dates"; leave it as it is.

#### Page 1 charts

- Scorecards: "People" (Record Count, 96,096), "Repeat customers" (2,997), "Repeat rate" (3.12%).
- Return rate by first-order timing: a table with `first_order_timing` ("First order"), `return_rate_180d` ("180-day return rate") and `people_full_followup` ("People"), sorted by Record Count descending (not shown in the table, so no sort arrow appears; it puts the larger group, On time, first). Filter "Full follow-up, has timing": include `has_full_followup` = true AND exclude `first_order_timing` is null. Result: on time 2.02% (50,681 people), late 1.69% (3,317).
- Return rate by first-order review score: the same table with `first_order_review_score` ("First-order review (1–5)"), `return_rate_180d` ("180-day return rate") and `people_full_followup` ("People"), sorted ascending. Filter "Full follow-up, has review": include `has_full_followup` = true AND exclude `first_order_review_score` is null. Results: 1 = 1.68% (6,544), 2 = 1.53% (1,832), 3 = 1.98% (4,800), 4 = 1.84% (10,913), 5 = 2.15% (31,437).
- Cross-filtering is off on both tables, so clicking a row doesn't filter the whole page.

Hand-checked with direct SQL on `dim_customers` on Oct 28, 2026: late, on time and score 5 all match.

### Data Studio setup for page 2 ("Money")

Page 2 reads three embedded data sources: `fct_category_summary` and `fct_seller_summary` (section 3), plus the existing `fct_orders` source for the scorecard. Settings on the two summary sources: owner's credentials, community visualizations off, every count and sum column (`orders`, `late_orders`, `orders_with_delivery_date`, `review_score_sum`, `orders_with_review`, `order_value`) default aggregation Sum. Settings on `fct_orders`: owner's credentials, community visualizations off, `review_score` and `delivery_days` default aggregation Average. Data Studio fills in `order_purchase_timestamp` as its date range dimension, with the default date range "Auto: All available dates"; leave it as it is.

The calculated fields below are the same on both summary sources. Removing and re-adding a source deletes them, so re-enter them from here.

| Field | Formula | Type | Matches |
|---|---|---|---|
| `late_order_rate` | `SUM(late_orders) / SUM(orders_with_delivery_date)` | Percent | Late-order rate per category or seller (section 3) |
| `average_review` | `SUM(review_score_sum) / SUM(orders_with_review)` | Number | Average review per category or seller (section 3) |

#### Page 2 charts

- Scorecard on `fct_orders`, labelled "At-risk payments (BRL)" (the full name made the number too small; the caption says what it counts): Sum of `payment_total`, Number, 2 decimals, number in teal. Filter "Canceled or unavailable": include `order_status` in canceled, unavailable (section 2, payments on canceled and unavailable orders).
- Category table on `fct_category_summary`: dimension "Category", a chart-level field with the formula `REPLACE(product_category, "_", " ")`; metrics `orders` ("Orders"), `late_order_rate` ("Late-order rate", Percent, 2 decimals, shown as bars), `late_orders` ("Late orders"), `average_review` ("Avg review", Number, 2 decimals), `order_value` ("Order value (BRL)", Number, 0 decimals). Filter "In rankings": include `in_rankings` = true. Sort: a hidden chart-level field `late_order_rate * 1`, descending. Top 10 rows. Cross-filtering off.
- Sellers by rate table on `fct_seller_summary`: the same metrics, with `seller_id` ("Seller ID", column narrowed so IDs show about 10 characters) as the dimension and its own filter "In rankings (sellers)": include `in_rankings` = true. Filters belong to one data source, so each table needs its own. Sort: a hidden chart-level field `late_order_rate * 1`, descending. Top 10 rows. Cross-filtering off.
- Sellers by late orders table on `fct_seller_summary`: dimension `seller_id` ("Seller ID", narrowed the same way); metrics `orders` ("Orders"), `late_order_rate` ("Late-order rate", Percent, 2 decimals), `late_orders` ("Late orders", shown as bars). Filter "In rankings (sellers)". Sort: a hidden chart-level field `SUM(late_orders)`, descending. Top 10 rows. Cross-filtering off. It shows the evidence for the seller caption: the large seller with 172 late orders.

Chart-level fields (Data Studio IDs starting `qt_`) belong to their chart, not the data source, so re-adding a source doesn't delete them. But they refer to source fields by name, so if a source is re-added and its field names change, they break. All four are listed above with their formulas so they can be re-created: "Category" and the hidden sort on the Category table, and the hidden sorts on both seller tables.

Hand-checked against direct SQL on Oct 28, 2026, all matching: `bed_bath_table` 9,417 orders, 7.43% late, 3.97 average review, 1,036,988.68 order value (the table shows it rounded to 1,036,989); seller `6560211a19b47992c3666cc44a7e94c0` 1,854 orders, 5.28%, 3.94, 123,304.83; scorecard 269,735.11.

The M4-06 Reverse step rebuilt a copy of the report from mart tables only on Oct 29, 2026, and every chart matched.

### Rebuilding a data source

After a data source is removed and re-added, charts can swap in other fields (for example `number_of_orders` or Record Count), lose their filters (shown as a pink broken filter) and lose their labels, so check every chip against this section. If a chart can't find the new source's fields, switch its data source to another one and back. Re-add the source and its calculated fields before reconnecting charts. "Make a copy" once failed with an `errorStatus` code 3 page; closing the browser and trying again worked. The scorecard label text boxes aren't part of any data source, so re-adding a source doesn't remove them, but they must be moved with their cards.

### Captions

Captions live inside the report and are lost with it, so this is the permanent copy; each is one sentence, placed in a small grey text box under its chart.

| Page | Chart | Caption |
|---|---|---|
| Customers | People | 96,096 different people placed at least one order between 2016 and 2018. |
| Customers | Repeat customers | 2,997 people placed more than one order, counting orders of any status, including same-day ones. |
| Customers | Repeat rate | Only about 3 in every 100 people ever placed a second order. |
| Customers | Return rate by first-order timing | People whose first order arrived late returned within 180 days slightly less often (1.69% of 3,317 people vs 2.02% of 50,681), but both groups sit near 2%, so delivery timing alone doesn't explain why customers don't come back. |
| Customers | Return rate by first-order review score | Whatever score people gave their first order, from 1 to 5, only 1.5–2.2% came back within 180 days, so even happy first-time customers rarely return. |
| Money | At-risk payments scorecard | Customers paid 269,735.11 BRL on 1,234 orders that were canceled or unavailable; the data doesn't show refunds, so this is money at risk, not a confirmed loss. |
| Money | Category table | Categories with 30+ orders, ranked by late-order rate (a high rate on a small category can mean just a few late orders); items with no category ("unknown", 1,451 orders) count in totals but not in this ranking. |
| Money | Sellers by rate table | The highest late rates belong to small sellers (the top one has 14 late orders), while one large seller at 9.71% has 172, more than the 10 highest-rate sellers combined (140). |
| Money | Sellers by late orders table | Ranked by late orders instead, one large seller (4a3ca931, 1,806 orders) tops the list with 172 late orders at a 9.71% rate. |
