# Tekzo Database Implementation Guide

## Step-by-Step Implementation Instructions

---

## PHASE 1: Database Setup

### Step 1: Create Database

```sql
CREATE DATABASE IF NOT EXISTS tekzo_db;
USE tekzo_db;
```

### Step 2: Execute Schema

- Run the complete SQL script from `DATABASE_SCHEMA.sql`
- Verify all 23 tables are created
- Check indexes and foreign keys

### Step 3: Verify Installation

```sql
-- Check all tables exist
SELECT COUNT(*) FROM information_schema.TABLES WHERE table_schema = 'tekzo_db';
-- Should return: 23

-- List all tables
SHOW TABLES;

-- Check specific table structure
DESCRIBE Users;
DESCRIBE Products;
DESCRIBE Orders;
```

---

## PHASE 2: Initial Data Population

### Step 1: Create Seed Data

```sql
-- Insert sample categories
INSERT INTO Categories (category_name, category_description, category_image_url, is_active) VALUES
('Electronics', 'Mobile phones, laptops, tablets, accessories', 'assets/categories/electronics.png', TRUE),
('Fashion', 'Clothing, shoes, bags, accessories', 'assets/categories/fashion.png', TRUE),
('Home & Kitchen', 'Home appliances, kitchen tools, furniture', 'assets/categories/home.png', TRUE),
('Sports & Outdoor', 'Sports equipment, outdoor gear, fitness', 'assets/categories/sports.png', TRUE),
('Books & Media', 'Books, audiobooks, magazines, digital media', 'assets/categories/books.png', TRUE),
('Beauty & Personal Care', 'Skincare, cosmetics, personal care products', 'assets/categories/beauty.png', TRUE);

-- Insert sample admin user
INSERT INTO Users (email, password_hash, first_name, last_name, role, is_active, is_email_verified) VALUES
('admin@tekzo.com', '$2b$12$...', 'Admin', 'User', 'admin', TRUE, TRUE);
```

### Step 2: Insert Sample Products

```sql
-- Example products (insert 5-10 per category for testing)
INSERT INTO Products (product_name, sku, category_id, description, price, cost_price, discount_percentage, stock_quantity, brand, is_featured, is_active) VALUES
('MacBook Pro 16"', 'TECH-MBPRO-16', 1, 'High-performance laptop', 2499.00, 1800.00, 10, 15, 'Apple', TRUE, TRUE),
('Sony WH-1000XM5', 'TECH-SONY-WH', 1, 'Premium noise-cancelling headphones', 399.00, 250.00, 5, 25, 'Sony', TRUE, TRUE);
```

### Step 3: Add Product Images

```sql
INSERT INTO ProductImages (product_id, image_url, alt_text, display_order, is_primary) VALUES
(1, 'assets/products/mbpro_1.jpg', 'MacBook Pro Front View', 1, TRUE),
(1, 'assets/products/mbpro_2.jpg', 'MacBook Pro Side View', 2, FALSE);
```

---

## PHASE 3: Connection Configuration

### For Different Backend Frameworks:

#### Node.js/Express + MySQL

```javascript
const mysql = require("mysql2/promise");

const pool = mysql.createPool({
  host: "localhost",
  user: "root",
  password: "your_password",
  database: "tekzo_db",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

module.exports = pool;
```

#### Python/Flask + SQLAlchemy

```python
from flask_sqlalchemy import SQLAlchemy

app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:password@localhost/tekzo_db'
db = SQLAlchemy(app)
```

#### Java/Spring Boot

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/tekzo_db
spring.datasource.username=root
spring.datasource.password=your_password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.hibernate.ddl-auto=validate
```

#### .NET Core

```csharp
services.AddDbContext<TekzoDB>(options =>
    options.UseMySql("Server=localhost;Database=tekzo_db;User=root;Password=password;",
    new MySqlServerVersion(new Version(8, 0, 23))));
```

---

## PHASE 4: Create API Endpoints

### Authentication Endpoints

```
POST /api/auth/register
  - Insert into Users table
  - Hash password with bcrypt

POST /api/auth/login
  - Query Users by email
  - Verify password hash
  - Return JWT token

POST /api/auth/logout
  - Invalidate token
  - Log activity

POST /api/auth/refresh
  - Refresh JWT token
```

### Product Endpoints

```
GET /api/products
  - SELECT * FROM Products WHERE is_active = TRUE
  - Include filters, pagination, search

GET /api/products/{id}
  - SELECT FROM Products, ProductImages, ProductVariants, Reviews

GET /api/categories
  - SELECT * FROM Categories WHERE is_active = TRUE

GET /api/products/search
  - Full-text search on product_name, description

GET /api/products/featured
  - SELECT * FROM Products WHERE is_featured = TRUE
```

### Cart Endpoints

```
GET /api/cart/{user_id}
  - SELECT * FROM Cart WHERE user_id = ?
  - Join with CartItems, Products, ProductVariants

POST /api/cart/items
  - INSERT into CartItems

PUT /api/cart/items/{item_id}
  - UPDATE CartItems (quantity)

DELETE /api/cart/items/{item_id}
  - DELETE from CartItems

POST /api/cart/apply-coupon
  - Validate coupon in Coupons table
  - Calculate discount
```

### Order Endpoints

```
POST /api/orders
  - BEGIN TRANSACTION
  - INSERT into Orders
  - INSERT into OrderItems (from CartItems)
  - UPDATE Products stock_quantity
  - DELETE from CartItems
  - COMMIT
  - CREATE Notifications

GET /api/orders/{user_id}
  - SELECT * FROM Orders WHERE user_id = ?
  - Filter by status (active/completed)

GET /api/orders/{order_id}
  - SELECT * FROM Orders, OrderItems, Products, OrderTracking
  - Full order details

PUT /api/orders/{order_id}
  - Admin: UPDATE order_status, payment_status

GET /api/orders/{order_id}/tracking
  - SELECT * FROM OrderTracking WHERE order_id = ?
```

### Review Endpoints

```
POST /api/reviews
  - INSERT into Reviews
  - Verify purchase from OrderItems
  - UPDATE Products rating and total_reviews

GET /api/products/{product_id}/reviews
  - SELECT * FROM Reviews WHERE product_id = ? AND is_published = TRUE

PUT /api/reviews/{review_id}
  - Admin: UPDATE is_published, response_text

GET /api/reviews/{review_id}/helpful
  - UPDATE helpful_count or unhelpful_count
```

### Wishlist Endpoints

```
POST /api/wishlist
  - INSERT into Wishlist

DELETE /api/wishlist/{product_id}
  - DELETE from Wishlist WHERE user_id = ? AND product_id = ?

GET /api/wishlist
  - SELECT * FROM Wishlist WHERE user_id = ?
  - Join with Products, ProductImages
```

### Address Endpoints

```
GET /api/addresses
  - SELECT * FROM ShippingAddresses WHERE user_id = ?

POST /api/addresses
  - INSERT into ShippingAddresses

PUT /api/addresses/{address_id}
  - UPDATE ShippingAddresses

DELETE /api/addresses/{address_id}
  - DELETE from ShippingAddresses

PUT /api/addresses/{address_id}/default
  - UPDATE is_default for addresses
```

### Payment Methods Endpoints

```
GET /api/payment-methods
  - SELECT * FROM PaymentMethods WHERE user_id = ?

POST /api/payment-methods
  - INSERT into PaymentMethods
  - Encrypt sensitive data

DELETE /api/payment-methods/{method_id}
  - DELETE from PaymentMethods

PUT /api/payment-methods/{method_id}/default
  - UPDATE is_default
```

### Support Ticket Endpoints

```
POST /api/support/tickets
  - INSERT into SupportTickets
  - Generate ticket_number

GET /api/support/tickets
  - SELECT * FROM SupportTickets WHERE user_id = ?

POST /api/support/tickets/{ticket_id}/messages
  - INSERT into TicketMessages

GET /api/support/tickets/{ticket_id}
  - SELECT * FROM SupportTickets, TicketMessages, Users
  - Full ticket details with conversation
```

### Admin Endpoints

```
GET /api/admin/dashboard
  - SELECT COUNT(*), SUM() statistics from Orders, Users, Products

GET /api/admin/products
  - SELECT * FROM Products (all, with is_active check)
  - Pagination, filtering

POST /api/admin/products
  - INSERT into Products
  - INSERT into ProductImages
  - INSERT into ProductVariants
  - INSERT into Inventory

PUT /api/admin/products/{id}
  - UPDATE Products

DELETE /api/admin/products/{id}
  - DELETE from Products (cascade to images, variants)

GET /api/admin/orders
  - SELECT * FROM Orders (all orders)
  - Filter by status, date range

PUT /api/admin/orders/{id}
  - UPDATE Orders (status, tracking, etc.)

GET /api/admin/reviews
  - SELECT * FROM Reviews (all)
  - Manage moderation

PUT /api/admin/reviews/{id}
  - UPDATE is_published, response_text

GET /api/admin/users
  - SELECT * FROM Users

PUT /api/admin/users/{id}
  - UPDATE Users (manage accounts)

GET /api/admin/analytics
  - Revenue reports
  - Customer statistics
  - Product performance
```

---

## PHASE 5: Security Implementation

### Authentication & Authorization

```
✓ Use bcrypt or Argon2 for password hashing
✓ Implement JWT for API authentication
✓ Add rate limiting on auth endpoints
✓ Use HTTPS for all API calls
✓ Implement CORS properly
✓ Add request validation on all endpoints
```

### Data Protection

```sql
-- Encrypt sensitive fields
ALTER TABLE PaymentMethods
ADD COLUMN card_holder_name_encrypted VARCHAR(255);

-- Implement audit triggers
CREATE TRIGGER user_password_change_log
AFTER UPDATE ON Users
FOR EACH ROW
BEGIN
  IF OLD.password_hash != NEW.password_hash THEN
    INSERT INTO AdminActivityLog (admin_id, action_type, entity_type, entity_id, changes_made)
    VALUES (NEW.user_id, 'update', 'Users', NEW.user_id, JSON_OBJECT('field', 'password_hash'));
  END IF;
END;
```

### Input Validation

- Validate all inputs on application layer
- Use parameterized queries (prevent SQL injection)
- Sanitize user inputs
- Validate file uploads (size, type)

---

## PHASE 6: Testing

### Unit Tests

```
✓ Test all CRUD operations
✓ Test foreign key relationships
✓ Test triggers and stored procedures
✓ Test constraints and validations
```

### Integration Tests

```sql
-- Test transaction integrity
BEGIN;
INSERT INTO Orders VALUES (...);
INSERT INTO OrderItems VALUES (...);
-- Verify both inserted
ROLLBACK; -- Undo

-- Test cascading deletes
DELETE FROM Categories WHERE category_id = 1;
-- Verify products in category are handled
```

### Load Testing

```
✓ Test with 100K+ products
✓ Test with 10K+ concurrent users
✓ Monitor query performance
✓ Optimize slow queries
```

### Data Validation

```sql
-- Check data integrity
SELECT * FROM Products WHERE price < cost_price;
SELECT * FROM Orders WHERE total_amount != (subtotal + tax_amount + shipping_cost - discount_amount);
SELECT * FROM CartItems WHERE product_id NOT IN (SELECT product_id FROM Products);
```

---

## PHASE 7: Optimization

### Index Usage

```sql
-- Analyze index usage
ANALYZE TABLE Products;
EXPLAIN SELECT * FROM Products WHERE product_name LIKE '%laptop%';

-- Create composite indexes for common queries
CREATE INDEX idx_orders_user_date ON Orders(user_id, created_at DESC);
CREATE INDEX idx_products_category_active ON Products(category_id, is_active);
```

### Query Optimization

```sql
-- Instead of this (N+1 problem):
SELECT * FROM Orders WHERE user_id = 1;
-- Then loop and query each order's items

-- Use this (single query with JOIN):
SELECT o.*, oi.*, p.product_name
FROM Orders o
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
WHERE o.user_id = 1;
```

### Caching Strategy

```
✓ Cache frequently accessed data (categories, featured products)
✓ Use Redis for session storage
✓ Cache API responses (1-5 minute TTL for product lists)
✓ Invalidate cache on updates
```

---

## PHASE 8: Maintenance

### Regular Tasks

**Daily:**

- Monitor slow queries
- Check database size growth
- Verify backups

**Weekly:**

- Analyze table statistics
- Review error logs
- Check disk space

**Monthly:**

- Archive old logs
- Optimize tables: `OPTIMIZE TABLE table_name;`
- Review query performance
- Update statistics

**Quarterly:**

- Full backup test
- Capacity planning
- Security audit
- Schema review

### Backup Strategy

```sql
-- Full backup
mysqldump -u root -p tekzo_db > tekzo_db_backup_$(date +%Y%m%d).sql

-- Incremental backup (binary log)
-- Enable binary logging in my.cnf
[mysqld]
log-bin=mysql-bin
server-id=1

-- Point-in-time recovery
mysqlbinlog mysql-bin.000001 | mysql -u root -p
```

### Monitoring Queries

```sql
-- Slow queries (queries taking > 2 seconds)
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;

-- Check table sizes
SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb
FROM information_schema.TABLES
WHERE table_schema = 'tekzo_db'
ORDER BY size_mb DESC;

-- Check connections
SHOW PROCESSLIST;
SHOW STATUS LIKE 'Threads%';

-- Check deadlocks
SHOW ENGINE INNODB STATUS;
```

---

## PHASE 9: Scaling Considerations

### Horizontal Scaling

```
✓ Read replicas for SELECT queries
✓ Write master for INSERT/UPDATE/DELETE
✓ Use connection pooling
✓ Implement sharding for very large tables
```

### Vertical Scaling

```
✓ Increase server RAM
✓ Upgrade CPU
✓ Use SSD storage
✓ Increase max connections
```

### Table Partitioning

```sql
-- Partition Orders by date (monthly)
ALTER TABLE Orders
PARTITION BY RANGE (YEAR(created_at)*100 + MONTH(created_at)) (
  PARTITION p202501 VALUES LESS THAN (202502),
  PARTITION p202502 VALUES LESS THAN (202503),
  PARTITION p202503 VALUES LESS THAN (202504),
  PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

---

## DEPLOYMENT CHECKLIST

- [ ] Database created
- [ ] All 23 tables created
- [ ] Indexes created
- [ ] Foreign keys verified
- [ ] Sample data inserted
- [ ] Triggers created
- [ ] Backup configured
- [ ] Connection pooling setup
- [ ] API endpoints implemented
- [ ] Authentication working
- [ ] All tests passing
- [ ] Performance benchmarks met
- [ ] Security audit passed
- [ ] Monitoring setup
- [ ] Documentation complete
- [ ] Team trained
- [ ] Production deployment ready

---

## TROUBLESHOOTING

### Common Issues

**Issue:** Foreign key constraint fails

```sql
-- Solution: Check if referenced record exists
SELECT * FROM Users WHERE user_id = 999;
-- Or temporarily disable constraints for bulk operations
SET FOREIGN_KEY_CHECKS = 0;
-- ... perform operations ...
SET FOREIGN_KEY_CHECKS = 1;
```

**Issue:** Slow queries

```sql
-- Solution: Check query plan
EXPLAIN SELECT * FROM Products WHERE product_name LIKE '%laptop%';
-- Add appropriate indexes
CREATE INDEX idx_product_name ON Products(product_name);
```

**Issue:** Disk space full

```sql
-- Solution: Archive old data
INSERT INTO archive_db.Orders SELECT * FROM Orders WHERE created_at < DATE_SUB(NOW(), INTERVAL 2 YEAR);
DELETE FROM Orders WHERE created_at < DATE_SUB(NOW(), INTERVAL 2 YEAR);
```

**Issue:** Too many connections

```sql
-- Solution: Increase max connections
SET GLOBAL max_connections = 1000;
-- Or implement connection pooling in application
```

---

## REFERENCE DOCUMENTATION

- **Schema Details:** See `DATABASE_SCHEMA.md`
- **Screens Mapping:** See `SCREENS_TO_DATABASE_MAPPING.md`
- **ERD:** See `DATABASE_SCHEMA_ERD.md`
- **SQL Script:** See `DATABASE_SCHEMA.sql`

---

**Implementation Status:** Ready for Deployment ✅
**Last Updated:** May 3, 2026
**Version:** 1.0
