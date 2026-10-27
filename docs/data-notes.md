# Raw data notes (M3-02)

What the 9 raw tables in `ecommerce_analytics` actually contain, checked before writing any dbt staging model. Every column was loaded as STRING (text), so these checks look at the text as delivered.

The exact text of all 24 queries is in [data-notes-queries.sql](data-notes-queries.sql), numbered to match the questions below. All are read-only `SELECT`s. Results are from the data loaded on Oct 26, 2026.

## 1. Are blanks NULL, empty text, or spaces?

For every column: how many values are `NULL`, how many are empty text `''`, and how many are only spaces. Whitespace-only is counted as `col != '' AND TRIM(col) = ''`, so empty text isn't counted twice. One query per table (queries 1.1–1.9), each repeating these three lines for every column:

```sql
COUNTIF(col IS NULL) AS col__null,
COUNTIF(col = '') AS col__empty,
COUNTIF(col != '' AND TRIM(col) = '') AS col__whitespace
```

**Answer:** no column has empty text (`''`). Every missing value is a real `NULL`. Only two columns have whitespace-only values. Everything not listed below has no blanks at all.

| Table | Column | NULL | Empty | Whitespace only | Rows |
|---|---|---|---|---|---|
| raw_order_reviews | review_comment_title | 87,656 | 0 | 2 | 99,224 |
| raw_order_reviews | review_comment_message | 58,247 | 0 | 27 | 99,224 |
| raw_orders | order_approved_at | 160 | 0 | 0 | 99,441 |
| raw_orders | order_delivered_carrier_date | 1,783 | 0 | 0 | 99,441 |
| raw_orders | order_delivered_customer_date | 2,965 | 0 | 0 | 99,441 |
| raw_products | product_category_name, product_name_lenght, product_description_lenght, product_photos_qty | 610 each | 0 | 0 | 32,951 |
| raw_products | product_weight_g, product_length_cm, product_height_cm, product_width_cm | 2 each | 0 | 0 | 32,951 |

## 2. What format are the dates in?

Queries 2.1–2.3. For each date column: 3 sample values, plus a count of values that don't match `YYYY-MM-DD HH:MM:SS`.

```sql
SELECT
  ARRAY_AGG(shipping_limit_date IGNORE NULLS LIMIT 3) AS shipping_limit_date__samples,
  COUNTIF(NOT REGEXP_CONTAINS(shipping_limit_date, r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')) AS shipping_limit_date__not_yyyy_mm_dd_hh_mm_ss
FROM `ecommerce_analytics.raw_order_items`
```

Queries 2.2 and 2.3 repeat the same two lines for each date column of `raw_order_reviews` and `raw_orders`.

**Answer:** every non-NULL date value in all 8 columns is `YYYY-MM-DD HH:MM:SS`. No value has a different format.

| Table | Column | Samples |
|---|---|---|
| raw_order_items | shipping_limit_date | 2018-05-04 03:55:26 · 2018-05-02 20:30:34 · 2018-05-07 02:55:22 |
| raw_order_reviews | review_creation_date | 2016-10-02 00:00:00 · 2016-10-06 00:00:00 · 2016-10-09 00:00:00 |
| raw_order_reviews | review_answer_timestamp | 2016-10-26 12:31:00 · 2016-10-07 18:32:28 · 2016-10-11 14:31:29 |
| raw_orders | order_purchase_timestamp | 2017-02-06 20:18:17 · 2017-04-25 01:25:34 · 2016-09-13 15:24:19 |
| raw_orders | order_approved_at | 2017-02-06 20:30:19 · 2017-04-30 20:32:41 · 2016-10-07 13:16:46 |
| raw_orders | order_delivered_carrier_date | 2016-10-25 12:14:28 · 2016-10-11 15:07:11 · 2016-10-13 13:36:59 |
| raw_orders | order_delivered_customer_date | 2016-11-08 10:58:34 · 2016-10-14 15:07:11 · 2016-10-16 14:36:59 |
| raw_orders | order_estimated_delivery_date | 2017-03-01 00:00:00 · 2017-05-22 00:00:00 · 2016-09-30 00:00:00 |

The samples for `review_creation_date` and `order_estimated_delivery_date` are all at midnight. They look like plain dates stored with a time, but only the samples were checked for this.

## 3. Do number columns parse, and are review scores and zip codes valid?

Queries 3.1–3.7, one per table. For each column staging will turn into a number, the query counts non-blank values that don't convert to a number:

```sql
COUNTIF(TRIM(col) != '' AND SAFE_CAST(TRIM(col) AS NUMERIC) IS NULL) AS col__not_a_number
```

The same queries also count review scores outside 1–5 and zip code prefixes that aren't 5 characters long:

```sql
COUNTIF(SAFE_CAST(review_score AS NUMERIC) NOT BETWEEN 1 AND 5) AS review_score__outside_1_to_5
COUNTIF(TRIM(col) != '' AND LENGTH(col) != 5) AS col__length_not_5
```

Columns checked: `order_item_id`, `price`, `freight_value` (order items); `payment_sequential`, `payment_installments`, `payment_value` (payments); `review_score`; the 7 product size, weight and count columns; `geolocation_lat`, `geolocation_lng`; and the zip code prefix in customers, sellers and geolocation.

**Answer:** zero problems. Every non-blank number value converts, every review score is between 1 and 5, and every zip code prefix is exactly 5 characters.

## 4. Are there duplicate `review_id`s in reviews?

Query 4:

```sql
SELECT
  COUNT(*) AS review_ids_seen_more_than_once,
  SUM(n) - COUNT(*) AS extra_rows,
  COUNTIF(distinct_orders > 1) AS ids_linked_to_several_orders
FROM (
  SELECT review_id, COUNT(*) AS n, COUNT(DISTINCT order_id) AS distinct_orders
  FROM `ecommerce_analytics.raw_order_reviews`
  GROUP BY review_id
  HAVING COUNT(*) > 1
)
```

**Answer:** yes. **789** `review_id`s appear more than once, which adds **814** extra rows. Every one of the 789 is attached to more than one different order, so these look like one review copied onto several orders, not repeated rows. `review_id` alone is not a unique key.

## 5. How many geolocation rows are there per zip prefix?

Query 5.1:

```sql
SELECT
  COUNT(*) AS zip_prefixes,
  SUM(n) AS total_rows,
  MIN(n) AS min_rows, ROUND(AVG(n), 1) AS avg_rows, MAX(n) AS max_rows,
  COUNTIF(n > 1) AS prefixes_with_more_than_one_row
FROM (
  SELECT geolocation_zip_code_prefix, COUNT(*) AS n
  FROM `ecommerce_analytics.raw_geolocation`
  GROUP BY geolocation_zip_code_prefix
)
```

Query 5.2, rows that are exact copies of another row:

```sql
SELECT COUNT(*) - COUNT(DISTINCT TO_JSON_STRING(g)) AS exact_duplicate_rows
FROM `ecommerce_analytics.raw_geolocation` AS g
```

**Answer:** 1,000,163 rows cover only **19,015** zip prefixes. That's 1 to 1,146 rows per prefix, 52.6 on average, and 17,972 prefixes have more than one row. **261,831** rows are exact copies of another row. Joining customers or sellers to this table by zip prefix as it stands would multiply rows.

## 6. How many people have more than one `customer_id`?

Query 6:

```sql
SELECT
  COUNT(DISTINCT customer_unique_id) AS unique_ids,
  SUM(n) AS customer_ids,
  COUNTIF(n > 1) AS unique_ids_with_more_than_one_customer_id,
  MAX(n) AS max_customer_ids_per_person
FROM (
  SELECT customer_unique_id, COUNT(DISTINCT customer_id) AS n
  FROM `ecommerce_analytics.raw_customers`
  GROUP BY customer_unique_id
)
```

**Answer:** 99,441 `customer_id`s belong to **96,096** real people (`customer_unique_id`). **2,997** people have more than one `customer_id`, and one person has 17. A new `customer_id` is created for each order, so counting customers by `customer_id` would make every buyer look like a first-time buyer.

## 7. Which product categories are missing from the translation table?

Query 7:

```sql
SELECT p.product_category_name, COUNT(*) AS products
FROM `ecommerce_analytics.raw_products` AS p
LEFT JOIN `ecommerce_analytics.raw_product_category_translation` AS tr
  ON p.product_category_name = tr.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND p.product_category_name != ''
  AND tr.product_category_name IS NULL
GROUP BY p.product_category_name
ORDER BY products DESC
```

**Answer:** 2 categories, 13 products: `portateis_cozinha_e_preparadores_de_alimentos` (10 products) and `pc_gamer` (3). Another 610 products have no category at all (see question 1).

## What this means for staging

| Finding | Rule in staging |
|---|---|
| Blanks are already NULL, except whitespace-only review comments | Wrap every text column in `NULLIF(TRIM(col), '')`. This trims spaces and turns any empty or whitespace-only value into NULL, so the rule still holds if a reload brings in `''` |
| All dates are `YYYY-MM-DD HH:MM:SS` | Cast with `SAFE_CAST(col AS TIMESTAMP)`. `review_creation_date` and `order_estimated_delivery_date` look like plain dates, so cast them to `DATE` |
| Missing delivery and approval dates (orders not yet approved, shipped or delivered) | Keep them as NULL. Don't fill them in; NULL means "hasn't happened" |
| All number columns parse | Cast with `SAFE_CAST`: `NUMERIC` for money (`price`, `freight_value`, `payment_value`), `INT64` for counts, IDs and sizes, `FLOAT64` for lat/lng. Fix the source's misspellings `lenght` → `length` when renaming |
| Review scores are all 1–5 | Cast to `INT64` and add a dbt test that scores stay between 1 and 5 |
| Zip prefixes are all 5 characters | Keep them as STRING. Casting to a number would drop leading zeros |
| `review_id` repeats across orders | Don't test `review_id` as unique. Test the pair `review_id` + `order_id` as unique instead (not yet checked against the data) |
| Geolocation has many rows per zip prefix and 261,831 exact copies | Reduce to one row per zip prefix (average lat/lng) before joining it to anything |
| One person can have many `customer_id`s | Join orders to customers by `customer_id`, but count people and repeat buyers by `customer_unique_id` |
| 2 categories have no English name; 610 products have no category | Use the English name when there is one, otherwise keep the Portuguese name; NULL categories become `'unknown'` in the marts |
