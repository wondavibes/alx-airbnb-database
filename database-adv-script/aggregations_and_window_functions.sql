-- Total number of bookings made by each user
-- Uses COUNT() with GROUP BY to aggregate bookings per user
SELECT
    u.user_id,
    COALESCE(u.first_name, '') || ' ' || COALESCE(u.last_name, '') AS user_name,
    COUNT(b.booking_id) AS total_bookings
FROM Booking b
JOIN "User" u ON b.user_id = u.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_bookings DESC;


-- Rank properties by total bookings using a window function (RANK)
-- RANK() will assign the same rank to ties (e.g., properties with equal booking counts)
SELECT
    p.property_id,
    p.Names AS property_name,
    bc.total_bookings,
    RANK() OVER (ORDER BY bc.total_bookings DESC) AS booking_rank
FROM (
    SELECT
        property_id,
        COUNT(booking_id) AS total_bookings
    FROM Booking
    GROUP BY property_id
) AS bc
JOIN Property p ON bc.property_id = p.property_id
ORDER BY booking_rank, bc.total_bookings DESC;


-- Alternative: use ROW_NUMBER() to get a strict ordering (no ties)
-- This can be useful when you need a unique position for each property.
SELECT
    p.property_id,
    p.Names AS property_name,
    bc.total_bookings,
    ROW_NUMBER() OVER (ORDER BY bc.total_bookings DESC) AS row_num
FROM (
    SELECT
        property_id,
        COUNT(booking_id) AS total_bookings
    FROM Booking
    GROUP BY property_id
) AS bc
JOIN Property p ON bc.property_id = p.property_id
ORDER BY row_num;