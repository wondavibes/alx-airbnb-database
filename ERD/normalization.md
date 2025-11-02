---

# 🧮 Database Normalization to Third Normal Form (3NF)

This document reviews the schema for the property booking platform and applies normalization principles to ensure the design adheres to Third Normal Form (3NF).

---

## 📚 Normalization Principles Overview

Normalization is the process of organizing data to reduce redundancy and improve data integrity. The key stages are:

### 1NF – First Normal Form
- All attributes contain atomic (indivisible) values.
- Each record is unique and has a primary key.

### 2NF – Second Normal Form
- Meets 1NF.
- All non-key attributes are fully functionally dependent on the entire primary key (especially relevant for composite keys).

### 3NF – Third Normal Form
- Meets 2NF.
- No transitive dependencies: non-key attributes must not depend on other non-key attributes.

---

## 🔍 Schema Review and 3NF Compliance

### ✅ User Table
- Atomic fields (e.g., `first_name`, `email`)
- No transitive dependencies
- Unique constraint on `email` ensures integrity
- ✅ Already in 3NF

### ✅ Property Table
- `host_id` references `User(user_id)` — no redundancy
- All attributes describe the property directly
- ✅ Already in 3NF

### ✅ Booking Table
- Attributes like `start_date`, `end_date`, `total_price`, and `status` depend only on `booking_id`
- No derived or transitive fields
- ✅ Already in 3NF

### ✅ Payment Table
- `amount`, `payment_date`, and `payment_method` depend only on `payment_id`
- Linked to `booking_id` without redundancy
- ✅ Already in 3NF

### ✅ Review Table
- `rating` and `comment` depend only on `review_id`
- No transitive dependencies
- ✅ Already in 3NF

### ✅ Message Table
- `sender_id` and `recipient_id` are foreign keys referencing `User(user_id)`
- `message_body` and `sent_at` depend only on `message_id`
- ✅ Already in 3NF

---

## ✅ Summary
All tables in the schema meet the requirements of Third Normal Form:

- No repeating groups or multi-valued attributes (1NF)
- All non-key attributes depend on the whole key (2NF)
- No transitive dependencies between non-key attributes (3NF)

The schema is optimized for integrity, scalability, and maintainability.
---
