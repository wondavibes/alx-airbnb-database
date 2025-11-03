
# 🌱 Airbnb Clone – Database Seed Scripts

This folder contains SQL commands used to populate the **Airbnb Clone Project** database with sample data across all core entities. These scripts help simulate real-world usage and support development, testing, and demonstration.

## 📦 Contents

- `seed_users.sql`: Adds sample users (guests, hosts, admins)
- `seed_properties.sql`: Adds property listings hosted by users
- `seed_bookings.sql`: Adds booking records for properties
- `seed_payments.sql`: Adds payment transactions linked to bookings
- `seed_reviews.sql`: Adds user reviews for properties
- `seed_messages.sql`: Adds messages exchanged between users

## 🧪 Sample Data Highlights

- Multiple users with varied roles
- Properties listed by hosts in different locations
- Bookings with realistic dates and prices
- Payments using different methods
- Reviews with ratings and comments
- Messages simulating guest-host communication

## 🚀 Usage

To seed the database, run the scripts in logical order:

```bash
psql -f seed.sql
```

Ensure the database schema is already created before running these scripts.

---
