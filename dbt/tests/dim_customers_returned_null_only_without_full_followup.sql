-- Fails (returns rows) if returned_within_180_days is NULL with full follow-up, or set without it.
select customer_unique_id, has_full_followup, returned_within_180_days
from {{ ref('dim_customers') }}
where has_full_followup = (returned_within_180_days is null)
