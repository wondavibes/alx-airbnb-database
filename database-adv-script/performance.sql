
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status,
    b.total_price,
    -- User details
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    -- Property details
    p.property_id,
    p.Names AS property_name,
    p.Locations,
    p.pricepernight,
    -- Payment details
    pay.payment_id,
    pay.payment_method,
    pay.payment_date,
    pay.amount
FROM Booking b
JOIN "User" u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.start_date DESC;

-- 2. Optimized Query Version 1
-- Removed unnecessary columns and used INNER JOINs where applicable
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.status,
    b.total_price,
    -- Essential user details
    u.first_name,
    u.last_name,
    -- Essential property details
    p.Names AS property_name,
    p.Locations,
    -- Essential payment details
    pay.payment_method,
    pay.amount
FROM Booking b
    INNER JOIN "User" u USING (user_id)
    INNER JOIN Property p USING (property_id)
    LEFT JOIN Payment pay USING (booking_id)
WHERE b.status != 'canceled'  -- Filter out canceled bookings
ORDER BY b.start_date DESC
LIMIT 100;  -- Limit results for better performance

-- 4. Optimized Query Version 2
-- Using subqueries for better performance
EXPLAIN ANALYZE
WITH recent_bookings AS (
    SELECT booking_id, user_id, property_id, start_date, status, total_price
    FROM Booking
    WHERE status != 'canceled'
    AND start_date >= CURRENT_DATE - INTERVAL '6 months'
    ORDER BY start_date DESC
    LIMIT 100
)
SELECT 
    rb.booking_id,
    rb.start_date,
    rb.status,
    rb.total_price,
    -- User details
    u.first_name,
    u.last_name,
    -- Property details
    p.Names AS property_name,
    p.Locations,
    -- Payment summary
    COALESCE(p_summary.total_paid, 0) as total_paid,
    CASE WHEN p_summary.total_paid >= rb.total_price THEN 'Paid' ELSE 'Partially Paid' END as payment_status
FROM recent_bookings rb
JOIN "User" u ON rb.user_id = u.user_id
JOIN Property p ON rb.property_id = p.property_id
LEFT JOIN (
    SELECT booking_id, SUM(amount) as total_paid
    FROM Payment
    GROUP BY booking_id
) p_summary ON rb.booking_id = p_summary.booking_id;

-- 5. Performance Comparison Query
-- This helps track performance improvements
SELECT 
    substring(query, 1, 50) as query_start,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements
WHERE query ILIKE '%booking%'
AND query ILIKE '%user%'
AND query ILIKE '%property%'
ORDER BY mean_time DESC
LIMIT 5;

-- 6. Recommended Index Additions (if not exists)
CREATE INDEX IF NOT EXISTS idx_booking_start_date_status 
ON Booking(start_date DESC, status);

CREATE INDEX IF NOT EXISTS idx_payment_booking_amount 
ON Payment(booking_id, amount);

-- 7. Reset Statistics (Run periodically)
SELECT pg_stat_reset();
SELECT pg_stat_statements_reset();

