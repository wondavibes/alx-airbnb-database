### Index Performance Analysis for Airbnb Clone Database
 This file contains index analysis, creation commands, and performance measurements

 1. Existing Indexes Analysis
     User table:
       - Primary Key on user_id (automatically indexed)
       - idx_user_email on email (already exists)
     Property table:
      - Primary Key on property_id (automatically indexed)
      - idx_property_host_id on host_id (already exists)    
     Booking table:
      - Primary Key on booking_id (automatically indexed)
      - idx_booking_property_id on property_id (already exists)
      - idx_booking_user_id on user_id (already exists)

 2. New Suggested Indexes Based on Query Patterns

    - Property Search Index (compound index for location and price searches)

---