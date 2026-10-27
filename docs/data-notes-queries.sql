-- Queries behind docs/data-notes.md, numbered to match its questions.
-- All are read-only SELECTs. Run them in the BigQuery console of your own project.

-- 1.1 · blanks: raw_customers
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(customer_id IS NULL) AS customer_id__null,
  COUNTIF(customer_id = '') AS customer_id__empty,
  COUNTIF(customer_id != '' AND TRIM(customer_id) = '') AS customer_id__whitespace,
  COUNTIF(customer_unique_id IS NULL) AS customer_unique_id__null,
  COUNTIF(customer_unique_id = '') AS customer_unique_id__empty,
  COUNTIF(customer_unique_id != '' AND TRIM(customer_unique_id) = '') AS customer_unique_id__whitespace,
  COUNTIF(customer_zip_code_prefix IS NULL) AS customer_zip_code_prefix__null,
  COUNTIF(customer_zip_code_prefix = '') AS customer_zip_code_prefix__empty,
  COUNTIF(customer_zip_code_prefix != '' AND TRIM(customer_zip_code_prefix) = '') AS customer_zip_code_prefix__whitespace,
  COUNTIF(customer_city IS NULL) AS customer_city__null,
  COUNTIF(customer_city = '') AS customer_city__empty,
  COUNTIF(customer_city != '' AND TRIM(customer_city) = '') AS customer_city__whitespace,
  COUNTIF(customer_state IS NULL) AS customer_state__null,
  COUNTIF(customer_state = '') AS customer_state__empty,
  COUNTIF(customer_state != '' AND TRIM(customer_state) = '') AS customer_state__whitespace
FROM `ecommerce_analytics.raw_customers`;

-- 1.2 · blanks: raw_geolocation
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(geolocation_zip_code_prefix IS NULL) AS geolocation_zip_code_prefix__null,
  COUNTIF(geolocation_zip_code_prefix = '') AS geolocation_zip_code_prefix__empty,
  COUNTIF(geolocation_zip_code_prefix != '' AND TRIM(geolocation_zip_code_prefix) = '') AS geolocation_zip_code_prefix__whitespace,
  COUNTIF(geolocation_lat IS NULL) AS geolocation_lat__null,
  COUNTIF(geolocation_lat = '') AS geolocation_lat__empty,
  COUNTIF(geolocation_lat != '' AND TRIM(geolocation_lat) = '') AS geolocation_lat__whitespace,
  COUNTIF(geolocation_lng IS NULL) AS geolocation_lng__null,
  COUNTIF(geolocation_lng = '') AS geolocation_lng__empty,
  COUNTIF(geolocation_lng != '' AND TRIM(geolocation_lng) = '') AS geolocation_lng__whitespace,
  COUNTIF(geolocation_city IS NULL) AS geolocation_city__null,
  COUNTIF(geolocation_city = '') AS geolocation_city__empty,
  COUNTIF(geolocation_city != '' AND TRIM(geolocation_city) = '') AS geolocation_city__whitespace,
  COUNTIF(geolocation_state IS NULL) AS geolocation_state__null,
  COUNTIF(geolocation_state = '') AS geolocation_state__empty,
  COUNTIF(geolocation_state != '' AND TRIM(geolocation_state) = '') AS geolocation_state__whitespace
FROM `ecommerce_analytics.raw_geolocation`;

-- 1.3 · blanks: raw_order_items
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(order_id IS NULL) AS order_id__null,
  COUNTIF(order_id = '') AS order_id__empty,
  COUNTIF(order_id != '' AND TRIM(order_id) = '') AS order_id__whitespace,
  COUNTIF(order_item_id IS NULL) AS order_item_id__null,
  COUNTIF(order_item_id = '') AS order_item_id__empty,
  COUNTIF(order_item_id != '' AND TRIM(order_item_id) = '') AS order_item_id__whitespace,
  COUNTIF(product_id IS NULL) AS product_id__null,
  COUNTIF(product_id = '') AS product_id__empty,
  COUNTIF(product_id != '' AND TRIM(product_id) = '') AS product_id__whitespace,
  COUNTIF(seller_id IS NULL) AS seller_id__null,
  COUNTIF(seller_id = '') AS seller_id__empty,
  COUNTIF(seller_id != '' AND TRIM(seller_id) = '') AS seller_id__whitespace,
  COUNTIF(shipping_limit_date IS NULL) AS shipping_limit_date__null,
  COUNTIF(shipping_limit_date = '') AS shipping_limit_date__empty,
  COUNTIF(shipping_limit_date != '' AND TRIM(shipping_limit_date) = '') AS shipping_limit_date__whitespace,
  COUNTIF(price IS NULL) AS price__null,
  COUNTIF(price = '') AS price__empty,
  COUNTIF(price != '' AND TRIM(price) = '') AS price__whitespace,
  COUNTIF(freight_value IS NULL) AS freight_value__null,
  COUNTIF(freight_value = '') AS freight_value__empty,
  COUNTIF(freight_value != '' AND TRIM(freight_value) = '') AS freight_value__whitespace
FROM `ecommerce_analytics.raw_order_items`;

-- 1.4 · blanks: raw_order_payments
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(order_id IS NULL) AS order_id__null,
  COUNTIF(order_id = '') AS order_id__empty,
  COUNTIF(order_id != '' AND TRIM(order_id) = '') AS order_id__whitespace,
  COUNTIF(payment_sequential IS NULL) AS payment_sequential__null,
  COUNTIF(payment_sequential = '') AS payment_sequential__empty,
  COUNTIF(payment_sequential != '' AND TRIM(payment_sequential) = '') AS payment_sequential__whitespace,
  COUNTIF(payment_type IS NULL) AS payment_type__null,
  COUNTIF(payment_type = '') AS payment_type__empty,
  COUNTIF(payment_type != '' AND TRIM(payment_type) = '') AS payment_type__whitespace,
  COUNTIF(payment_installments IS NULL) AS payment_installments__null,
  COUNTIF(payment_installments = '') AS payment_installments__empty,
  COUNTIF(payment_installments != '' AND TRIM(payment_installments) = '') AS payment_installments__whitespace,
  COUNTIF(payment_value IS NULL) AS payment_value__null,
  COUNTIF(payment_value = '') AS payment_value__empty,
  COUNTIF(payment_value != '' AND TRIM(payment_value) = '') AS payment_value__whitespace
FROM `ecommerce_analytics.raw_order_payments`;

-- 1.5 · blanks: raw_order_reviews
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(review_id IS NULL) AS review_id__null,
  COUNTIF(review_id = '') AS review_id__empty,
  COUNTIF(review_id != '' AND TRIM(review_id) = '') AS review_id__whitespace,
  COUNTIF(order_id IS NULL) AS order_id__null,
  COUNTIF(order_id = '') AS order_id__empty,
  COUNTIF(order_id != '' AND TRIM(order_id) = '') AS order_id__whitespace,
  COUNTIF(review_score IS NULL) AS review_score__null,
  COUNTIF(review_score = '') AS review_score__empty,
  COUNTIF(review_score != '' AND TRIM(review_score) = '') AS review_score__whitespace,
  COUNTIF(review_comment_title IS NULL) AS review_comment_title__null,
  COUNTIF(review_comment_title = '') AS review_comment_title__empty,
  COUNTIF(review_comment_title != '' AND TRIM(review_comment_title) = '') AS review_comment_title__whitespace,
  COUNTIF(review_comment_message IS NULL) AS review_comment_message__null,
  COUNTIF(review_comment_message = '') AS review_comment_message__empty,
  COUNTIF(review_comment_message != '' AND TRIM(review_comment_message) = '') AS review_comment_message__whitespace,
  COUNTIF(review_creation_date IS NULL) AS review_creation_date__null,
  COUNTIF(review_creation_date = '') AS review_creation_date__empty,
  COUNTIF(review_creation_date != '' AND TRIM(review_creation_date) = '') AS review_creation_date__whitespace,
  COUNTIF(review_answer_timestamp IS NULL) AS review_answer_timestamp__null,
  COUNTIF(review_answer_timestamp = '') AS review_answer_timestamp__empty,
  COUNTIF(review_answer_timestamp != '' AND TRIM(review_answer_timestamp) = '') AS review_answer_timestamp__whitespace
FROM `ecommerce_analytics.raw_order_reviews`;

-- 1.6 · blanks: raw_orders
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(order_id IS NULL) AS order_id__null,
  COUNTIF(order_id = '') AS order_id__empty,
  COUNTIF(order_id != '' AND TRIM(order_id) = '') AS order_id__whitespace,
  COUNTIF(customer_id IS NULL) AS customer_id__null,
  COUNTIF(customer_id = '') AS customer_id__empty,
  COUNTIF(customer_id != '' AND TRIM(customer_id) = '') AS customer_id__whitespace,
  COUNTIF(order_status IS NULL) AS order_status__null,
  COUNTIF(order_status = '') AS order_status__empty,
  COUNTIF(order_status != '' AND TRIM(order_status) = '') AS order_status__whitespace,
  COUNTIF(order_purchase_timestamp IS NULL) AS order_purchase_timestamp__null,
  COUNTIF(order_purchase_timestamp = '') AS order_purchase_timestamp__empty,
  COUNTIF(order_purchase_timestamp != '' AND TRIM(order_purchase_timestamp) = '') AS order_purchase_timestamp__whitespace,
  COUNTIF(order_approved_at IS NULL) AS order_approved_at__null,
  COUNTIF(order_approved_at = '') AS order_approved_at__empty,
  COUNTIF(order_approved_at != '' AND TRIM(order_approved_at) = '') AS order_approved_at__whitespace,
  COUNTIF(order_delivered_carrier_date IS NULL) AS order_delivered_carrier_date__null,
  COUNTIF(order_delivered_carrier_date = '') AS order_delivered_carrier_date__empty,
  COUNTIF(order_delivered_carrier_date != '' AND TRIM(order_delivered_carrier_date) = '') AS order_delivered_carrier_date__whitespace,
  COUNTIF(order_delivered_customer_date IS NULL) AS order_delivered_customer_date__null,
  COUNTIF(order_delivered_customer_date = '') AS order_delivered_customer_date__empty,
  COUNTIF(order_delivered_customer_date != '' AND TRIM(order_delivered_customer_date) = '') AS order_delivered_customer_date__whitespace,
  COUNTIF(order_estimated_delivery_date IS NULL) AS order_estimated_delivery_date__null,
  COUNTIF(order_estimated_delivery_date = '') AS order_estimated_delivery_date__empty,
  COUNTIF(order_estimated_delivery_date != '' AND TRIM(order_estimated_delivery_date) = '') AS order_estimated_delivery_date__whitespace
FROM `ecommerce_analytics.raw_orders`;

-- 1.7 · blanks: raw_products
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(product_id IS NULL) AS product_id__null,
  COUNTIF(product_id = '') AS product_id__empty,
  COUNTIF(product_id != '' AND TRIM(product_id) = '') AS product_id__whitespace,
  COUNTIF(product_category_name IS NULL) AS product_category_name__null,
  COUNTIF(product_category_name = '') AS product_category_name__empty,
  COUNTIF(product_category_name != '' AND TRIM(product_category_name) = '') AS product_category_name__whitespace,
  COUNTIF(product_name_lenght IS NULL) AS product_name_lenght__null,
  COUNTIF(product_name_lenght = '') AS product_name_lenght__empty,
  COUNTIF(product_name_lenght != '' AND TRIM(product_name_lenght) = '') AS product_name_lenght__whitespace,
  COUNTIF(product_description_lenght IS NULL) AS product_description_lenght__null,
  COUNTIF(product_description_lenght = '') AS product_description_lenght__empty,
  COUNTIF(product_description_lenght != '' AND TRIM(product_description_lenght) = '') AS product_description_lenght__whitespace,
  COUNTIF(product_photos_qty IS NULL) AS product_photos_qty__null,
  COUNTIF(product_photos_qty = '') AS product_photos_qty__empty,
  COUNTIF(product_photos_qty != '' AND TRIM(product_photos_qty) = '') AS product_photos_qty__whitespace,
  COUNTIF(product_weight_g IS NULL) AS product_weight_g__null,
  COUNTIF(product_weight_g = '') AS product_weight_g__empty,
  COUNTIF(product_weight_g != '' AND TRIM(product_weight_g) = '') AS product_weight_g__whitespace,
  COUNTIF(product_length_cm IS NULL) AS product_length_cm__null,
  COUNTIF(product_length_cm = '') AS product_length_cm__empty,
  COUNTIF(product_length_cm != '' AND TRIM(product_length_cm) = '') AS product_length_cm__whitespace,
  COUNTIF(product_height_cm IS NULL) AS product_height_cm__null,
  COUNTIF(product_height_cm = '') AS product_height_cm__empty,
  COUNTIF(product_height_cm != '' AND TRIM(product_height_cm) = '') AS product_height_cm__whitespace,
  COUNTIF(product_width_cm IS NULL) AS product_width_cm__null,
  COUNTIF(product_width_cm = '') AS product_width_cm__empty,
  COUNTIF(product_width_cm != '' AND TRIM(product_width_cm) = '') AS product_width_cm__whitespace
FROM `ecommerce_analytics.raw_products`;

-- 1.8 · blanks: raw_sellers
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(seller_id IS NULL) AS seller_id__null,
  COUNTIF(seller_id = '') AS seller_id__empty,
  COUNTIF(seller_id != '' AND TRIM(seller_id) = '') AS seller_id__whitespace,
  COUNTIF(seller_zip_code_prefix IS NULL) AS seller_zip_code_prefix__null,
  COUNTIF(seller_zip_code_prefix = '') AS seller_zip_code_prefix__empty,
  COUNTIF(seller_zip_code_prefix != '' AND TRIM(seller_zip_code_prefix) = '') AS seller_zip_code_prefix__whitespace,
  COUNTIF(seller_city IS NULL) AS seller_city__null,
  COUNTIF(seller_city = '') AS seller_city__empty,
  COUNTIF(seller_city != '' AND TRIM(seller_city) = '') AS seller_city__whitespace,
  COUNTIF(seller_state IS NULL) AS seller_state__null,
  COUNTIF(seller_state = '') AS seller_state__empty,
  COUNTIF(seller_state != '' AND TRIM(seller_state) = '') AS seller_state__whitespace
FROM `ecommerce_analytics.raw_sellers`;

-- 1.9 · blanks: raw_product_category_translation
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(product_category_name IS NULL) AS product_category_name__null,
  COUNTIF(product_category_name = '') AS product_category_name__empty,
  COUNTIF(product_category_name != '' AND TRIM(product_category_name) = '') AS product_category_name__whitespace,
  COUNTIF(product_category_name_english IS NULL) AS product_category_name_english__null,
  COUNTIF(product_category_name_english = '') AS product_category_name_english__empty,
  COUNTIF(product_category_name_english != '' AND TRIM(product_category_name_english) = '') AS product_category_name_english__whitespace
FROM `ecommerce_analytics.raw_product_category_translation`;

-- 2.1 · dates: raw_order_items
SELECT
  ARRAY_AGG(shipping_limit_date IGNORE NULLS LIMIT 3) AS shipping_limit_date__samples,
  COUNTIF(NOT REGEXP_CONTAINS(shipping_limit_date, r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')) AS shipping_limit_date__not_yyyy_mm_dd_hh_mm_ss
FROM `ecommerce_analytics.raw_order_items`;

-- 2.2 · dates: raw_order_reviews
SELECT
  ARRAY_AGG(review_creation_date IGNORE NULLS LIMIT 3) AS review_creation_date__samples,
  COUNTIF(NOT REGEXP_CONTAINS(review_creation_date, r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')) AS review_creation_date__not_yyyy_mm_dd_hh_mm_ss,
  ARRAY_AGG(review_answer_timestamp IGNORE NULLS LIMIT 3) AS review_answer_timestamp__samples,
  COUNTIF(NOT REGEXP_CONTAINS(review_answer_timestamp, r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')) AS review_answer_timestamp__not_yyyy_mm_dd_hh_mm_ss
FROM `ecommerce_analytics.raw_order_reviews`;

-- 2.3 · dates: raw_orders
SELECT
  ARRAY_AGG(order_purchase_timestamp IGNORE NULLS LIMIT 3) AS order_purchase_timestamp__samples,
  COUNTIF(NOT REGEXP_CONTAINS(order_purchase_timestamp, r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')) AS order_purchase_timestamp__not_yyyy_mm_dd_hh_mm_ss,
  ARRAY_AGG(order_approved_at IGNORE NULLS LIMIT 3) AS order_approved_at__samples,
  COUNTIF(NOT REGEXP_CONTAINS(order_approved_at, r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')) AS order_approved_at__not_yyyy_mm_dd_hh_mm_ss,
  ARRAY_AGG(order_delivered_carrier_date IGNORE NULLS LIMIT 3) AS order_delivered_carrier_date__samples,
  COUNTIF(NOT REGEXP_CONTAINS(order_delivered_carrier_date, r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')) AS order_delivered_carrier_date__not_yyyy_mm_dd_hh_mm_ss,
  ARRAY_AGG(order_delivered_customer_date IGNORE NULLS LIMIT 3) AS order_delivered_customer_date__samples,
  COUNTIF(NOT REGEXP_CONTAINS(order_delivered_customer_date, r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')) AS order_delivered_customer_date__not_yyyy_mm_dd_hh_mm_ss,
  ARRAY_AGG(order_estimated_delivery_date IGNORE NULLS LIMIT 3) AS order_estimated_delivery_date__samples,
  COUNTIF(NOT REGEXP_CONTAINS(order_estimated_delivery_date, r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')) AS order_estimated_delivery_date__not_yyyy_mm_dd_hh_mm_ss
FROM `ecommerce_analytics.raw_orders`;

-- 3.1 · values: raw_customers
SELECT
  COUNTIF(TRIM(customer_zip_code_prefix) != '' AND LENGTH(customer_zip_code_prefix) != 5) AS customer_zip_code_prefix__length_not_5
FROM `ecommerce_analytics.raw_customers`;

-- 3.2 · values: raw_geolocation
SELECT
  COUNTIF(TRIM(geolocation_lat) != '' AND SAFE_CAST(TRIM(geolocation_lat) AS NUMERIC) IS NULL) AS geolocation_lat__not_a_number,
  COUNTIF(TRIM(geolocation_lng) != '' AND SAFE_CAST(TRIM(geolocation_lng) AS NUMERIC) IS NULL) AS geolocation_lng__not_a_number,
  COUNTIF(TRIM(geolocation_zip_code_prefix) != '' AND LENGTH(geolocation_zip_code_prefix) != 5) AS geolocation_zip_code_prefix__length_not_5
FROM `ecommerce_analytics.raw_geolocation`;

-- 3.3 · values: raw_order_items
SELECT
  COUNTIF(TRIM(order_item_id) != '' AND SAFE_CAST(TRIM(order_item_id) AS NUMERIC) IS NULL) AS order_item_id__not_a_number,
  COUNTIF(TRIM(price) != '' AND SAFE_CAST(TRIM(price) AS NUMERIC) IS NULL) AS price__not_a_number,
  COUNTIF(TRIM(freight_value) != '' AND SAFE_CAST(TRIM(freight_value) AS NUMERIC) IS NULL) AS freight_value__not_a_number
FROM `ecommerce_analytics.raw_order_items`;

-- 3.4 · values: raw_order_payments
SELECT
  COUNTIF(TRIM(payment_sequential) != '' AND SAFE_CAST(TRIM(payment_sequential) AS NUMERIC) IS NULL) AS payment_sequential__not_a_number,
  COUNTIF(TRIM(payment_installments) != '' AND SAFE_CAST(TRIM(payment_installments) AS NUMERIC) IS NULL) AS payment_installments__not_a_number,
  COUNTIF(TRIM(payment_value) != '' AND SAFE_CAST(TRIM(payment_value) AS NUMERIC) IS NULL) AS payment_value__not_a_number
FROM `ecommerce_analytics.raw_order_payments`;

-- 3.5 · values: raw_order_reviews
SELECT
  COUNTIF(TRIM(review_score) != '' AND SAFE_CAST(TRIM(review_score) AS NUMERIC) IS NULL) AS review_score__not_a_number,
  COUNTIF(SAFE_CAST(review_score AS NUMERIC) NOT BETWEEN 1 AND 5) AS review_score__outside_1_to_5
FROM `ecommerce_analytics.raw_order_reviews`;

-- 3.6 · values: raw_products
SELECT
  COUNTIF(TRIM(product_name_lenght) != '' AND SAFE_CAST(TRIM(product_name_lenght) AS NUMERIC) IS NULL) AS product_name_lenght__not_a_number,
  COUNTIF(TRIM(product_description_lenght) != '' AND SAFE_CAST(TRIM(product_description_lenght) AS NUMERIC) IS NULL) AS product_description_lenght__not_a_number,
  COUNTIF(TRIM(product_photos_qty) != '' AND SAFE_CAST(TRIM(product_photos_qty) AS NUMERIC) IS NULL) AS product_photos_qty__not_a_number,
  COUNTIF(TRIM(product_weight_g) != '' AND SAFE_CAST(TRIM(product_weight_g) AS NUMERIC) IS NULL) AS product_weight_g__not_a_number,
  COUNTIF(TRIM(product_length_cm) != '' AND SAFE_CAST(TRIM(product_length_cm) AS NUMERIC) IS NULL) AS product_length_cm__not_a_number,
  COUNTIF(TRIM(product_height_cm) != '' AND SAFE_CAST(TRIM(product_height_cm) AS NUMERIC) IS NULL) AS product_height_cm__not_a_number,
  COUNTIF(TRIM(product_width_cm) != '' AND SAFE_CAST(TRIM(product_width_cm) AS NUMERIC) IS NULL) AS product_width_cm__not_a_number
FROM `ecommerce_analytics.raw_products`;

-- 3.7 · values: raw_sellers
SELECT
  COUNTIF(TRIM(seller_zip_code_prefix) != '' AND LENGTH(seller_zip_code_prefix) != 5) AS seller_zip_code_prefix__length_not_5
FROM `ecommerce_analytics.raw_sellers`;

-- 4 · duplicate_review_ids
SELECT
  COUNT(*) AS review_ids_seen_more_than_once,
  SUM(n) - COUNT(*) AS extra_rows,
  COUNTIF(distinct_orders > 1) AS ids_linked_to_several_orders
FROM (
  SELECT review_id, COUNT(*) AS n, COUNT(DISTINCT order_id) AS distinct_orders
  FROM `ecommerce_analytics.raw_order_reviews`
  GROUP BY review_id
  HAVING COUNT(*) > 1
);

-- 5.1 · geolocation_rows_per_zip
SELECT
  COUNT(*) AS zip_prefixes,
  SUM(n) AS total_rows,
  MIN(n) AS min_rows, ROUND(AVG(n), 1) AS avg_rows, MAX(n) AS max_rows,
  COUNTIF(n > 1) AS prefixes_with_more_than_one_row
FROM (
  SELECT geolocation_zip_code_prefix, COUNT(*) AS n
  FROM `ecommerce_analytics.raw_geolocation`
  GROUP BY geolocation_zip_code_prefix
);

-- 5.2 · geolocation_exact_duplicates
SELECT COUNT(*) - COUNT(DISTINCT TO_JSON_STRING(g)) AS exact_duplicate_rows
FROM `ecommerce_analytics.raw_geolocation` AS g;

-- 6 · unique_ids_with_many_customer_ids
SELECT
  COUNT(DISTINCT customer_unique_id) AS unique_ids,
  SUM(n) AS customer_ids,
  COUNTIF(n > 1) AS unique_ids_with_more_than_one_customer_id,
  MAX(n) AS max_customer_ids_per_person
FROM (
  SELECT customer_unique_id, COUNT(DISTINCT customer_id) AS n
  FROM `ecommerce_analytics.raw_customers`
  GROUP BY customer_unique_id
);

-- 7 · untranslated_categories
SELECT p.product_category_name, COUNT(*) AS products
FROM `ecommerce_analytics.raw_products` AS p
LEFT JOIN `ecommerce_analytics.raw_product_category_translation` AS tr
  ON p.product_category_name = tr.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND p.product_category_name != ''
  AND tr.product_category_name IS NULL
GROUP BY p.product_category_name
ORDER BY products DESC;
