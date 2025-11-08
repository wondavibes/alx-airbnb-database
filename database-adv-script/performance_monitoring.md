# Performance Monitoring Report

## Purpose
This document records the monitoring steps, identified bottlenecks, changes implemented (indexes/schema adjustments), and the performance improvements observed for frequently used queries.

## Queries Monitored
1. Bookings + joins (representative):
   - JOIN Booking -> User -> Property -> Payment
   - Ordering by `Booking.start_date`
2. Property search by location and price:
   - `Property.Locations ILIKE '%...%'` + `pricepernight` range
3. Availability queries:
   - LEFT JOIN Property to Booking with date-range filters

## How measurements were taken
- Use EXPLAIN ANALYZE to capture the query plan and execution times.
- Record `Total runtime` and note whether sequential scans or index scans were used.
- Use `pg_stat_statements` to compare mean times across runs when available.

Example commands:

```sql
EXPLAIN ANALYZE <your-query-here>;
-- or for more detail
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) <your-query-here>;
```

## Bottlenecks Identified
1. Sequential scans on `Booking` when filtering by date (no effective index on `start_date` + `status`).
2. Slow text searches on `Property.Locations` using leading wildcard ILIKE '%term%' which cannot use a regular B-tree index.
3. Potential type mismatch between `Booking.user_id` (UUID) and `User.user_id` (CHAR(36)) in the provided schema—this can prevent index usage and cause implicit casts.
4. Large JOINs (Booking -> Property -> User -> Payment) returning many columns and ordering large result sets.

## Changes Implemented
File: `database-adv-script/implement_indexes.sql` (created)

Summary of implemented SQL changes (see file for exact SQL):

- Enabled trigram extension: `CREATE EXTENSION IF NOT EXISTS pg_trgm;`
- Created trigram GIN index for `Property(Locations)` to speed up ILIKE '%...%'.
- Created B-tree index for `Property(pricepernight)`.
- Created composite/indexed columns on `Booking(start_date, status)` to speed date+status filtering.
- Ensured indexes on `Booking(user_id)` and `Booking(property_id)` exist.
- Created index on `Payment(booking_id)` to speed aggregation and joins.
- Ran `ANALYZE` on affected tables.
- (Optional) Schema alignment suggestion: convert `Booking.user_id` to CHAR(36) to match `User.user_id` if safe to do so.

Notes:
- Index creation in production should use `CREATE INDEX CONCURRENTLY` to avoid locking writes.
- Partial indexes are recommended when filters are selective (e.g., `WHERE status = 'confirmed'`).

## How to reproduce before/after measurements
1. Run the initial EXPLAIN ANALYZE for each monitored query and save the output (baseline).
2. Apply `implement_indexes.sql` (or run relevant CREATE INDEX statements; use CONCURRENTLY in production).
3. Run `ANALYZE` on the affected tables to update planner statistics.
4. Run the same EXPLAIN ANALYZE queries and compare `Total runtime` and plan nodes (Index Scan vs Seq Scan).

## Observed Improvements (example template)
> Run these on your server and replace the example numbers with real results.

Query 1: Bookings join (LIMIT 100)
- Before: Total runtime = 220 ms, Plan used: Seq Scan on Booking
- After: Total runtime = 35 ms, Plan used: Index Scan using idx_booking_start_date_desc
- Improvement: ~84%

Query 2: Property location + price
- Before: Total runtime = 1,200 ms, Plan used: Seq Scan on Property (filter on ILIKE)
- After: Total runtime = 120 ms, Plan used: Bitmap Index Scan using idx_property_locations_trgm
- Improvement: ~90%

Query 3: Availability date-range
- Before: Total runtime = 2,000 ms, Plan used: Seq Scan on Booking
- After: Total runtime = 480 ms, Plan used: Index Scan on idx_booking_start_date_status
- Improvement: ~76%

> Note: Replace above placeholders with actual EXPLAIN ANALYZE outputs from your environment.

## Additional Recommendations
- Use `pg_trgm` indexes for free-text LIKE searches. Try to avoid leading wildcards when possible.
- Use partial indexes for very common filters, e.g.:
  ```sql
  CREATE INDEX CONCURRENTLY idx_booking_confirmed_start
  ON Booking(start_date)
  WHERE status = 'confirmed';
  ```
- Consider materialized views for complex aggregates used frequently.
- Fix schema type inconsistencies (Booking.user_id vs User.user_id) to avoid implicit casts and permit proper index usage.
- Schedule `ANALYZE` after bulk loads, and periodically run `VACUUM`/`AUTOVACUUM` tuning.

## Files created/edited
- `database-adv-script/implement_indexes.sql` — contains the SQL commands to create indexes, optional schema-change, and before/after EXPLAIN ANALYZE blocks.
- `database-adv-script/performance_monitoring.md` — this report.

## Next steps you can run now
1. Save baseline EXPLAIN ANALYZE outputs for the monitored queries (copy the full output to a file).
2. Run `implement_indexes.sql` (preferably with CONCURRENTLY and during low load).
3. Run the post-change EXPLAIN ANALYZE and paste results into this document under Observed Improvements.

If you want, I can:
- Add a script that automatically runs EXPLAIN ANALYZE for each query and collects basic metrics into a CSV
- Create partial-index suggestions tuned to your real query patterns (if you share the actual WHERE clauses)
- Help update the schema safely to fix the user_id type mismatch with migration steps and tests

