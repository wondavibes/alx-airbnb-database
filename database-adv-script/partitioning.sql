-- Booking Table Partitioning Implementation
-- This script implements range partitioning on the Booking table by start_date

-- 1. Create new partitioned table
CREATE TABLE Booking_Partitioned (
    booking_id CHAR(36),
    property_id CHAR(36) NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(10) CHECK (status IN ('pending', 'confirmed', 'canceled')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (booking_id, start_date),  -- Include partition key in primary key
    FOREIGN KEY (property_id) REFERENCES Property(property_id),
    FOREIGN KEY (user_id) REFERENCES "User"(user_id)
) PARTITION BY RANGE (start_date);

-- 2. Create partitions (one per quarter for recent and future dates)
CREATE TABLE booking_q4_2025 
    PARTITION OF Booking_Partitioned 
    FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');

CREATE TABLE booking_q1_2026 
    PARTITION OF Booking_Partitioned 
    FOR VALUES FROM ('2026-01-01') TO ('2026-04-01');

CREATE TABLE booking_q2_2026 
    PARTITION OF Booking_Partitioned 
    FOR VALUES FROM ('2026-04-01') TO ('2026-07-01');

CREATE TABLE booking_q3_2026 
    PARTITION OF Booking_Partitioned 
    FOR VALUES FROM ('2026-07-01') TO ('2026-10-01');

-- Create default partition for older bookings
CREATE TABLE booking_historical 
    PARTITION OF Booking_Partitioned 
    FOR VALUES FROM (MINVALUE) TO ('2025-10-01');

-- Create future partition for bookings way ahead
CREATE TABLE booking_future 
    PARTITION OF Booking_Partitioned 
    FOR VALUES FROM ('2026-10-01') TO (MAXVALUE);

-- 3. Create indexes on partitions
CREATE INDEX idx_booking_part_status_date ON Booking_Partitioned(status, start_date);
CREATE INDEX idx_booking_part_property ON Booking_Partitioned(property_id);
CREATE INDEX idx_booking_part_user ON Booking_Partitioned(user_id);

-- 4. Migrate data from old table to partitioned table
INSERT INTO Booking_Partitioned 
SELECT * FROM Booking;

-- 5. Verify partition usage
EXPLAIN ANALYZE
SELECT * FROM Booking_Partitioned
WHERE start_date BETWEEN '2025-11-01' AND '2025-12-31'
AND status = 'confirmed';

-- 6. Performance test queries

-- Test 1: Range scan on specific quarter
EXPLAIN ANALYZE
SELECT COUNT(*) 
FROM Booking_Partitioned
WHERE start_date BETWEEN '2025-10-01' AND '2025-12-31';

-- Test 2: Multi-partition scan
EXPLAIN ANALYZE
SELECT b.*, p.Names as property_name
FROM Booking_Partitioned b
JOIN Property p ON b.property_id = p.property_id
WHERE b.start_date BETWEEN '2025-12-01' AND '2026-02-28'
AND b.status = 'confirmed';

-- Test 3: Specific partition with additional filters
EXPLAIN ANALYZE
SELECT b.*, u.first_name, u.last_name
FROM Booking_Partitioned b
JOIN "User" u ON b.user_id = u.user_id
WHERE b.start_date >= '2025-10-01' 
AND b.start_date < '2026-01-01'
AND b.status = 'confirmed'
ORDER BY b.start_date DESC;

-- Test 4: Aggregate query across partitions
EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('month', start_date) as booking_month,
    COUNT(*) as booking_count,
    SUM(total_price) as total_revenue
FROM Booking_Partitioned
WHERE start_date BETWEEN '2025-10-01' AND '2026-03-31'
GROUP BY DATE_TRUNC('month', start_date)
ORDER BY booking_month;

-- 7. Maintenance procedures

-- Add new partition for future quarter
CREATE TABLE booking_q4_2026 
    PARTITION OF Booking_Partitioned 
    FOR VALUES FROM ('2026-10-01') TO ('2027-01-01');

-- Detach old partition to archive
ALTER TABLE Booking_Partitioned 
DETACH PARTITION booking_historical;

-- Procedure to create new partition (example)
CREATE OR REPLACE PROCEDURE create_booking_partition(
    start_date DATE,
    end_date DATE,
    partition_name TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    EXECUTE format(
        'CREATE TABLE %I PARTITION OF Booking_Partitioned
         FOR VALUES FROM (%L) TO (%L)',
        partition_name, start_date, end_date
    );
END;
$$;