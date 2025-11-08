
EXPLAIN ANALYZE
SELECT * FROM Property 
WHERE Locations LIKE '%New York%' 
AND pricepernight BETWEEN 100 AND 300;

CREATE INDEX idx_property_location_price 
ON Property(Locations, pricepernight);

EXPLAIN ANALYZE
SELECT * FROM Property 
WHERE Locations LIKE '%New York%' 
AND pricepernight BETWEEN 100 AND 300;

-- Booking Date Range Index (for availability searches)
EXPLAIN ANALYZE
SELECT p.*, b.start_date, b.end_date
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
WHERE (b.start_date >= '2025-11-01' AND b.end_date <= '2025-12-31')
   OR b.booking_id IS NULL;

CREATE INDEX idx_booking_dates 
ON Booking(start_date, end_date);

EXPLAIN ANALYZE
SELECT p.*, b.start_date, b.end_date
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
WHERE (b.start_date >= '2025-11-01' AND b.end_date <= '2025-12-31')
   OR b.booking_id IS NULL;

-- Booking Status Index (for filtering active/pending bookings)
EXPLAIN ANALYZE
SELECT * FROM Booking 
WHERE status = 'confirmed' 
AND start_date >= CURRENT_DATE;

CREATE INDEX idx_booking_status_dates
ON Booking(status, start_date);

EXPLAIN ANALYZE
SELECT * FROM Booking 
WHERE status = 'confirmed' 
AND start_date >= CURRENT_DATE;

-- Property Price Range Index (for price-based searches)
EXPLAIN ANALYZE
SELECT * FROM Property 
WHERE pricepernight <= 200 
ORDER BY pricepernight;

CREATE INDEX idx_property_price 
ON Property(pricepernight);

EXPLAIN ANALYZE
SELECT * FROM Property 
WHERE pricepernight <= 200 
ORDER BY pricepernight;

-- 3. Performance Impact Analysis

-- Example query showing performance before/after indexes:
-- Before adding idx_booking_status_dates:
EXPLAIN ANALYZE
SELECT b.*, p.Names as property_name, u.email
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
JOIN "User" u ON b.user_id = u.user_id
WHERE b.status = 'confirmed'
AND b.start_date >= CURRENT_DATE
ORDER BY b.start_date;

-- After adding all suggested indexes:
-- Expected improvements:
-- 1. Faster property searches by location and price
-- 2. Better performance for availability checks
-- 3. Optimized booking status filtering
-- 4. Improved price range queries

-- Note: Run ANALYZE after creating indexes and loading significant data
-- to ensure the query planner has current statistics:
ANALYZE Property;
ANALYZE Booking;
ANALYZE "User";

-- 4. Index Maintenance Considerations

-- Monitor index usage:
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
AND tablename IN ('Property', 'Booking', 'User');

-- Monitor index size:
SELECT pg_size_pretty(pg_total_relation_size('idx_property_location_price')) as location_price_index_size,
       pg_size_pretty(pg_total_relation_size('idx_booking_dates')) as booking_dates_index_size,
       pg_size_pretty(pg_total_relation_size('idx_booking_status_dates')) as status_dates_index_size,
       pg_size_pretty(pg_total_relation_size('idx_property_price')) as price_index_size;

-- Consider dropping unused indexes:
-- DROP INDEX IF EXISTS index_name;

-- 5. Best Practices
-- 1. Regularly analyze tables to update statistics
-- 2. Monitor index usage and remove unused indexes
-- 3. Consider partial indexes for specific WHERE clauses
-- 4. Balance between query performance and write overhead
-- 5. Test indexes with representative data volumes