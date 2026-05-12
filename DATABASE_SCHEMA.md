# Tekzo E-Commerce Database Schema

## Complete Database Structure for Tekzo Flutter App

---

## 1. **Users Table**

Stores user account information and authentication data.

| Column Name       | Data Type                         | Constraints                         | Description               |
| ----------------- | --------------------------------- | ----------------------------------- | ------------------------- |
| user_id           | INT                               | PRIMARY KEY, AUTO_INCREMENT         | Unique identifier         |
| email             | VARCHAR(255)                      | UNIQUE, NOT NULL                    | User email                |
| password_hash     | VARCHAR(255)                      | NOT NULL                            | Hashed password           |
| first_name        | VARCHAR(100)                      | NOT NULL                            | User first name           |
| last_name         | VARCHAR(100)                      | NOT NULL                            | User last name            |
| phone             | VARCHAR(15)                       | UNIQUE                              | Phone number              |
| profile_image_url | VARCHAR(500)                      |                                     | Profile picture URL       |
| date_of_birth     | DATE                              |                                     | Date of birth             |
| gender            | ENUM('Male','Female','Other')     |                                     | Gender                    |
| role              | ENUM('customer','admin','vendor') | DEFAULT 'customer'                  | User role                 |
| is_active         | BOOLEAN                           | DEFAULT TRUE                        | Account active status     |
| is_email_verified | BOOLEAN                           | DEFAULT FALSE                       | Email verification status |
| created_at        | TIMESTAMP                         | DEFAULT CURRENT_TIMESTAMP           | Account creation date     |
| updated_at        | TIMESTAMP                         | DEFAULT CURRENT_TIMESTAMP ON UPDATE | Last update date          |
| last_login        | TIMESTAMP                         |                                     | Last login time           |

---

## 2. **Categories Table**

Product categories for organizing products.

| Column Name          | Data Type    | Constraints                         | Description            |
| -------------------- | ------------ | ----------------------------------- | ---------------------- |
| category_id          | INT          | PRIMARY KEY, AUTO_INCREMENT         | Unique identifier      |
| category_name        | VARCHAR(100) | NOT NULL, UNIQUE                    | Category name          |
| category_description | TEXT         |                                     | Category description   |
| category_image_url   | VARCHAR(500) |                                     | Category icon/image    |
| parent_category_id   | INT          | FOREIGN KEY                         | For subcategories      |
| display_order        | INT          | DEFAULT 0                           | Order of display       |
| is_active            | BOOLEAN      | DEFAULT TRUE                        | Category active status |
| created_at           | TIMESTAMP    | DEFAULT CURRENT_TIMESTAMP           | Creation date          |
| updated_at           | TIMESTAMP    | DEFAULT CURRENT_TIMESTAMP ON UPDATE | Last update date       |

---

## 3. **Products Table**

Main product information.

| Column Name         | Data Type      | Constraints                         | Description              |
| ------------------- | -------------- | ----------------------------------- | ------------------------ |
| product_id          | INT            | PRIMARY KEY, AUTO_INCREMENT         | Unique identifier        |
| product_name        | VARCHAR(255)   | NOT NULL                            | Product name             |
| sku                 | VARCHAR(100)   | UNIQUE, NOT NULL                    | Stock keeping unit       |
| category_id         | INT            | FOREIGN KEY (Categories)            | Product category         |
| description         | TEXT           |                                     | Full product description |
| short_description   | VARCHAR(500)   |                                     | Brief description        |
| price               | DECIMAL(10, 2) | NOT NULL                            | Current price            |
| cost_price          | DECIMAL(10, 2) |                                     | Cost to vendor           |
| discount_percentage | DECIMAL(5, 2)  | DEFAULT 0                           | Discount percentage      |
| final_price         | DECIMAL(10, 2) |                                     | Price after discount     |
| stock_quantity      | INT            | DEFAULT 0                           | Current stock            |
| minimum_stock       | INT            | DEFAULT 10                          | Minimum reorder level    |
| brand               | VARCHAR(100)   |                                     | Product brand            |
| weight              | DECIMAL(8, 3)  |                                     | Weight in kg             |
| dimensions          | VARCHAR(100)   |                                     | Dimensions (L x W x H)   |
| warranty_months     | INT            | DEFAULT 0                           | Warranty period          |
| rating              | DECIMAL(3, 2)  | DEFAULT 0                           | Average rating           |
| total_reviews       | INT            | DEFAULT 0                           | Total reviews count      |
| is_featured         | BOOLEAN        | DEFAULT FALSE                       | Featured product         |
| is_active           | BOOLEAN        | DEFAULT TRUE                        | Product active status    |
| created_at          | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP           | Creation date            |
| updated_at          | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP ON UPDATE | Last update date         |

---

## 4. **ProductImages Table**

Multiple images for each product.

| Column Name   | Data Type    | Constraints                 | Description             |
| ------------- | ------------ | --------------------------- | ----------------------- |
| image_id      | INT          | PRIMARY KEY, AUTO_INCREMENT | Unique identifier       |
| product_id    | INT          | FOREIGN KEY (Products)      | Related product         |
| image_url     | VARCHAR(500) | NOT NULL                    | Image URL               |
| alt_text      | VARCHAR(255) |                             | Alternative text        |
| display_order | INT          | DEFAULT 0                   | Display order           |
| is_primary    | BOOLEAN      | DEFAULT FALSE               | Primary/thumbnail image |
| created_at    | TIMESTAMP    | DEFAULT CURRENT_TIMESTAMP   | Upload date             |

---

## 5. **ProductVariants Table**

Product variants (color, size, etc.).

| Column Name      | Data Type      | Constraints                 | Description                        |
| ---------------- | -------------- | --------------------------- | ---------------------------------- |
| variant_id       | INT            | PRIMARY KEY, AUTO_INCREMENT | Unique identifier                  |
| product_id       | INT            | FOREIGN KEY (Products)      | Related product                    |
| variant_name     | VARCHAR(100)   | NOT NULL                    | Variant name (e.g., "Red - Large") |
| variant_type     | VARCHAR(50)    | NOT NULL                    | Type (color, size, material, etc.) |
| variant_value    | VARCHAR(100)   | NOT NULL                    | Value (e.g., "Red", "Large")       |
| sku_variant      | VARCHAR(100)   | UNIQUE                      | SKU for variant                    |
| price_adjustment | DECIMAL(10, 2) | DEFAULT 0                   | Additional price                   |
| stock_quantity   | INT            | DEFAULT 0                   | Stock for this variant             |
| image_url        | VARCHAR(500)   |                             | Variant specific image             |
| is_active        | BOOLEAN        | DEFAULT TRUE                | Variant active status              |

---

## 6. **Cart Table**

Shopping cart storage.

| Column Name | Data Type | Constraints                         | Description          |
| ----------- | --------- | ----------------------------------- | -------------------- |
| cart_id     | INT       | PRIMARY KEY, AUTO_INCREMENT         | Unique identifier    |
| user_id     | INT       | FOREIGN KEY (Users)                 | Cart owner           |
| created_at  | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP           | Cart creation date   |
| updated_at  | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE | Last update date     |
| expires_at  | TIMESTAMP |                                     | Cart expiration date |

---

## 7. **CartItems Table**

Individual items in cart.

| Column Name   | Data Type      | Constraints                   | Description       |
| ------------- | -------------- | ----------------------------- | ----------------- |
| cart_item_id  | INT            | PRIMARY KEY, AUTO_INCREMENT   | Unique identifier |
| cart_id       | INT            | FOREIGN KEY (Cart)            | Related cart      |
| product_id    | INT            | FOREIGN KEY (Products)        | Product in cart   |
| variant_id    | INT            | FOREIGN KEY (ProductVariants) | Product variant   |
| quantity      | INT            | NOT NULL                      | Quantity in cart  |
| price_at_time | DECIMAL(10, 2) |                               | Price when added  |
| added_at      | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP     | Addition time     |

---

## 8. **Orders Table**

Customer orders.

| Column Name         | Data Type                                                                 | Constraints                         | Description                             |
| ------------------- | ------------------------------------------------------------------------- | ----------------------------------- | --------------------------------------- |
| order_id            | INT                                                                       | PRIMARY KEY, AUTO_INCREMENT         | Unique identifier                       |
| order_number        | VARCHAR(50)                                                               | UNIQUE, NOT NULL                    | Display order number (e.g., STKZ-08788) |
| user_id             | INT                                                                       | FOREIGN KEY (Users)                 | Customer                                |
| subtotal            | DECIMAL(10, 2)                                                            | NOT NULL                            | Items total                             |
| tax_amount          | DECIMAL(10, 2)                                                            | DEFAULT 0                           | Tax amount                              |
| shipping_cost       | DECIMAL(10, 2)                                                            | DEFAULT 0                           | Shipping cost                           |
| discount_amount     | DECIMAL(10, 2)                                                            | DEFAULT 0                           | Discount applied                        |
| coupon_code         | VARCHAR(50)                                                               |                                     | Applied coupon                          |
| total_amount        | DECIMAL(10, 2)                                                            | NOT NULL                            | Final total                             |
| order_status        | ENUM('pending','processing','shipped','delivered','cancelled','returned') | DEFAULT 'pending'                   | Order status                            |
| payment_status      | ENUM('pending','completed','failed','refunded')                           | DEFAULT 'pending'                   | Payment status                          |
| payment_method_id   | INT                                                                       | FOREIGN KEY (PaymentMethods)        | Payment method used                     |
| shipping_address_id | INT                                                                       | FOREIGN KEY (ShippingAddresses)     | Delivery address                        |
| billing_address_id  | INT                                                                       | FOREIGN KEY (ShippingAddresses)     | Billing address                         |
| notes               | TEXT                                                                      |                                     | Special instructions                    |
| tracking_number     | VARCHAR(100)                                                              |                                     | Shipment tracking                       |
| created_at          | TIMESTAMP                                                                 | DEFAULT CURRENT_TIMESTAMP           | Order creation date                     |
| updated_at          | TIMESTAMP                                                                 | DEFAULT CURRENT_TIMESTAMP ON UPDATE | Last update date                        |
| delivered_at        | TIMESTAMP                                                                 |                                     | Delivery date                           |

---

## 9. **OrderItems Table**

Individual items in an order.

| Column Name       | Data Type      | Constraints                   | Description       |
| ----------------- | -------------- | ----------------------------- | ----------------- |
| order_item_id     | INT            | PRIMARY KEY, AUTO_INCREMENT   | Unique identifier |
| order_id          | INT            | FOREIGN KEY (Orders)          | Related order     |
| product_id        | INT            | FOREIGN KEY (Products)        | Product ordered   |
| variant_id        | INT            | FOREIGN KEY (ProductVariants) | Product variant   |
| quantity          | INT            | NOT NULL                      | Quantity ordered  |
| unit_price        | DECIMAL(10, 2) | NOT NULL                      | Price per unit    |
| total_price       | DECIMAL(10, 2) | NOT NULL                      | Quantity × Price  |
| warranty_included | BOOLEAN        | DEFAULT FALSE                 | Warranty included |

---

## 10. **ShippingAddresses Table**

User shipping and billing addresses.

| Column Name      | Data Type                         | Constraints                 | Description           |
| ---------------- | --------------------------------- | --------------------------- | --------------------- |
| address_id       | INT                               | PRIMARY KEY, AUTO_INCREMENT | Unique identifier     |
| user_id          | INT                               | FOREIGN KEY (Users)         | Address owner         |
| address_type     | ENUM('shipping','billing','both') | DEFAULT 'shipping'          | Address type          |
| full_name        | VARCHAR(150)                      | NOT NULL                    | Recipient name        |
| phone            | VARCHAR(15)                       | NOT NULL                    | Contact phone         |
| street_address   | VARCHAR(255)                      | NOT NULL                    | Street address        |
| apartment_number | VARCHAR(50)                       |                             | Apt/Suite number      |
| city             | VARCHAR(100)                      | NOT NULL                    | City                  |
| state            | VARCHAR(100)                      | NOT NULL                    | State/Province        |
| postal_code      | VARCHAR(20)                       | NOT NULL                    | ZIP/Postal code       |
| country          | VARCHAR(100)                      | NOT NULL                    | Country               |
| is_default       | BOOLEAN                           | DEFAULT FALSE               | Default address       |
| is_active        | BOOLEAN                           | DEFAULT TRUE                | Address active status |
| created_at       | TIMESTAMP                         | DEFAULT CURRENT_TIMESTAMP   | Creation date         |

---

## 11. **PaymentMethods Table**

Saved payment methods for users.

| Column Name         | Data Type                                                                | Constraints                         | Description                         |
| ------------------- | ------------------------------------------------------------------------ | ----------------------------------- | ----------------------------------- |
| payment_method_id   | INT                                                                      | PRIMARY KEY, AUTO_INCREMENT         | Unique identifier                   |
| user_id             | INT                                                                      | FOREIGN KEY (Users)                 | Payment method owner                |
| payment_type        | ENUM('credit_card','debit_card','upi','wallet','bank_transfer','paypal') |                                     | Payment method type                 |
| card_holder_name    | VARCHAR(150)                                                             |                                     | Cardholder name                     |
| card_last_four      | VARCHAR(4)                                                               |                                     | Last 4 digits                       |
| card_expiry_month   | INT                                                                      |                                     | Expiry month                        |
| card_expiry_year    | INT                                                                      |                                     | Expiry year                         |
| card_brand          | VARCHAR(50)                                                              |                                     | Card brand (Visa, Mastercard, etc.) |
| upi_id              | VARCHAR(100)                                                             |                                     | UPI ID for UPI payments             |
| bank_account_number | VARCHAR(50)                                                              |                                     | Bank account (encrypted)            |
| bank_ifsc           | VARCHAR(20)                                                              |                                     | IFSC code                           |
| bank_name           | VARCHAR(150)                                                             |                                     | Bank name                           |
| is_default          | BOOLEAN                                                                  | DEFAULT FALSE                       | Default payment method              |
| is_active           | BOOLEAN                                                                  | DEFAULT TRUE                        | Payment method active               |
| created_at          | TIMESTAMP                                                                | DEFAULT CURRENT_TIMESTAMP           | Creation date                       |
| updated_at          | TIMESTAMP                                                                | DEFAULT CURRENT_TIMESTAMP ON UPDATE | Last update date                    |

---

## 12. **Reviews Table**

Product reviews and ratings.

| Column Name       | Data Type    | Constraints                         | Description       |
| ----------------- | ------------ | ----------------------------------- | ----------------- |
| review_id         | INT          | PRIMARY KEY, AUTO_INCREMENT         | Unique identifier |
| product_id        | INT          | FOREIGN KEY (Products)              | Reviewed product  |
| order_item_id     | INT          | FOREIGN KEY (OrderItems)            | Order reference   |
| user_id           | INT          | FOREIGN KEY (Users)                 | Reviewer          |
| rating            | INT          | CHECK (rating >= 1 AND rating <= 5) | Rating 1-5        |
| review_title      | VARCHAR(200) |                                     | Review title      |
| review_text       | TEXT         |                                     | Review content    |
| verified_purchase | BOOLEAN      | DEFAULT FALSE                       | Verified buyer    |
| is_published      | BOOLEAN      | DEFAULT FALSE                       | Publish status    |
| helpful_count     | INT          | DEFAULT 0                           | Helpful votes     |
| unhelpful_count   | INT          | DEFAULT 0                           | Unhelpful votes   |
| response_text     | TEXT         |                                     | Admin response    |
| responded_at      | TIMESTAMP    |                                     | Response date     |
| created_at        | TIMESTAMP    | DEFAULT CURRENT_TIMESTAMP           | Review date       |
| updated_at        | TIMESTAMP    | DEFAULT CURRENT_TIMESTAMP ON UPDATE | Last update date  |

---

## 13. **Wishlist Table**

User wishlist/favorites.

| Column Name                 | Data Type    | Constraints                 | Description                |
| --------------------------- | ------------ | --------------------------- | -------------------------- |
| wishlist_item_id            | INT          | PRIMARY KEY, AUTO_INCREMENT | Unique identifier          |
| user_id                     | INT          | FOREIGN KEY (Users)         | Wishlist owner             |
| product_id                  | INT          | FOREIGN KEY (Products)      | Wishlisted product         |
| note                        | VARCHAR(500) |                             | Personal note              |
| added_at                    | TIMESTAMP    | DEFAULT CURRENT_TIMESTAMP   | Addition date              |
| UNIQUE(user_id, product_id) |              |                             | One entry per user-product |

---

## 14. **Notifications Table**

User notifications.

| Column Name         | Data Type                                                              | Constraints                 | Description                        |
| ------------------- | ---------------------------------------------------------------------- | --------------------------- | ---------------------------------- |
| notification_id     | INT                                                                    | PRIMARY KEY, AUTO_INCREMENT | Unique identifier                  |
| user_id             | INT                                                                    | FOREIGN KEY (Users)         | Recipient                          |
| notification_type   | ENUM('order_update','promotion','review','product','system','payment') |                             | Notification type                  |
| title               | VARCHAR(200)                                                           | NOT NULL                    | Notification title                 |
| message             | TEXT                                                                   | NOT NULL                    | Notification content               |
| related_entity_type | VARCHAR(50)                                                            |                             | Entity type (order, product, etc.) |
| related_entity_id   | INT                                                                    |                             | Entity ID                          |
| is_read             | BOOLEAN                                                                | DEFAULT FALSE               | Read status                        |
| action_url          | VARCHAR(500)                                                           |                             | Action URL                         |
| created_at          | TIMESTAMP                                                              | DEFAULT CURRENT_TIMESTAMP   | Creation date                      |

---

## 15. **SupportTickets Table**

Customer support tickets.

| Column Name        | Data Type                                                                                   | Constraints                         | Description           |
| ------------------ | ------------------------------------------------------------------------------------------- | ----------------------------------- | --------------------- |
| ticket_id          | INT                                                                                         | PRIMARY KEY, AUTO_INCREMENT         | Unique identifier     |
| ticket_number      | VARCHAR(50)                                                                                 | UNIQUE                              | Display ticket number |
| user_id            | INT                                                                                         | FOREIGN KEY (Users)                 | User creating ticket  |
| related_order_id   | INT                                                                                         | FOREIGN KEY (Orders)                | Related order         |
| related_product_id | INT                                                                                         | FOREIGN KEY (Products)              | Related product       |
| category           | ENUM('shipping','payment','product_quality','missing_items','refund','general','complaint') |                                     | Ticket category       |
| priority           | ENUM('low','medium','high','urgent')                                                        | DEFAULT 'medium'                    | Priority level        |
| subject            | VARCHAR(255)                                                                                | NOT NULL                            | Subject               |
| description        | TEXT                                                                                        | NOT NULL                            | Detailed description  |
| status             | ENUM('open','in_progress','waiting_customer','resolved','closed')                           | DEFAULT 'open'                      | Status                |
| assigned_to        | INT                                                                                         | FOREIGN KEY (Users, admin)          | Assigned admin        |
| resolution_notes   | TEXT                                                                                        |                                     | Resolution details    |
| created_at         | TIMESTAMP                                                                                   | DEFAULT CURRENT_TIMESTAMP           | Creation date         |
| updated_at         | TIMESTAMP                                                                                   | DEFAULT CURRENT_TIMESTAMP ON UPDATE | Last update date      |
| resolved_at        | TIMESTAMP                                                                                   |                                     | Resolution date       |

---

## 16. **TicketMessages Table**

Messages in support tickets.

| Column Name    | Data Type    | Constraints                  | Description       |
| -------------- | ------------ | ---------------------------- | ----------------- |
| message_id     | INT          | PRIMARY KEY, AUTO_INCREMENT  | Unique identifier |
| ticket_id      | INT          | FOREIGN KEY (SupportTickets) | Related ticket    |
| sender_id      | INT          | FOREIGN KEY (Users)          | Message sender    |
| message_text   | TEXT         | NOT NULL                     | Message content   |
| attachment_url | VARCHAR(500) |                              | Attached file URL |
| created_at     | TIMESTAMP    | DEFAULT CURRENT_TIMESTAMP    | Message date      |

---

## 17. **Coupons Table**

Discount codes and promotions.

| Column Name           | Data Type                         | Constraints                 | Description                  |
| --------------------- | --------------------------------- | --------------------------- | ---------------------------- |
| coupon_id             | INT                               | PRIMARY KEY, AUTO_INCREMENT | Unique identifier            |
| coupon_code           | VARCHAR(50)                       | UNIQUE, NOT NULL            | Coupon code                  |
| discount_type         | ENUM('percentage','fixed_amount') |                             | Discount type                |
| discount_value        | DECIMAL(10, 2)                    | NOT NULL                    | Discount value               |
| minimum_order_value   | DECIMAL(10, 2)                    | DEFAULT 0                   | Minimum order amount         |
| maximum_discount      | DECIMAL(10, 2)                    |                             | Max discount cap             |
| usage_limit           | INT                               |                             | Total usage limit            |
| usage_per_user        | INT                               | DEFAULT 1                   | Uses per user                |
| current_usage         | INT                               | DEFAULT 0                   | Current usage count          |
| valid_from            | TIMESTAMP                         |                             | Coupon start date            |
| valid_until           | TIMESTAMP                         |                             | Coupon expiry date           |
| applicable_categories | VARCHAR(500)                      |                             | Comma-separated category IDs |
| applicable_products   | VARCHAR(500)                      |                             | Comma-separated product IDs  |
| is_active             | BOOLEAN                           | DEFAULT TRUE                | Active status                |
| created_by            | INT                               | FOREIGN KEY (Users, admin)  | Created by admin             |
| created_at            | TIMESTAMP                         | DEFAULT CURRENT_TIMESTAMP   | Creation date                |

---

## 18. **UserActivityLog Table**

User activity tracking for analytics.

| Column Name   | Data Type                                                                                         | Constraints                 | Description          |
| ------------- | ------------------------------------------------------------------------------------------------- | --------------------------- | -------------------- |
| log_id        | INT                                                                                               | PRIMARY KEY, AUTO_INCREMENT | Unique identifier    |
| user_id       | INT                                                                                               | FOREIGN KEY (Users)         | User                 |
| activity_type | ENUM('login','logout','view_product','add_to_cart','purchase','review','support_ticket','logout') |                             | Activity type        |
| description   | VARCHAR(500)                                                                                      |                             | Activity description |
| ip_address    | VARCHAR(45)                                                                                       |                             | IP address           |
| device_info   | VARCHAR(500)                                                                                      |                             | Device information   |
| created_at    | TIMESTAMP                                                                                         | DEFAULT CURRENT_TIMESTAMP   | Activity date        |

---

## 19. **AdminActivityLog Table**

Admin activity tracking for auditing.

| Column Name  | Data Type                                                           | Constraints                 | Description                                  |
| ------------ | ------------------------------------------------------------------- | --------------------------- | -------------------------------------------- |
| log_id       | INT                                                                 | PRIMARY KEY, AUTO_INCREMENT | Unique identifier                            |
| admin_id     | INT                                                                 | FOREIGN KEY (Users)         | Admin user                                   |
| action_type  | ENUM('create','update','delete','view','export','approve','reject') |                             | Action type                                  |
| entity_type  | VARCHAR(50)                                                         |                             | Entity modified (product, order, user, etc.) |
| entity_id    | INT                                                                 |                             | Entity ID                                    |
| changes_made | JSON                                                                |                             | JSON of changes                              |
| reason       | TEXT                                                                |                             | Reason for action                            |
| ip_address   | VARCHAR(45)                                                         |                             | IP address                                   |
| created_at   | TIMESTAMP                                                           | DEFAULT CURRENT_TIMESTAMP   | Action date                                  |

---

## 20. **OrderTracking Table**

Track order status changes and shipping updates.

| Column Name         | Data Type    | Constraints                         | Description              |
| ------------------- | ------------ | ----------------------------------- | ------------------------ |
| tracking_id         | INT          | PRIMARY KEY, AUTO_INCREMENT         | Unique identifier        |
| order_id            | INT          | FOREIGN KEY (Orders)                | Related order            |
| tracking_number     | VARCHAR(100) |                                     | Shipment tracking number |
| carrier             | VARCHAR(100) |                                     | Shipping carrier         |
| status              | VARCHAR(50)  |                                     | Current status           |
| location            | VARCHAR(255) |                                     | Current location         |
| estimated_delivery  | DATE         |                                     | Expected delivery date   |
| last_update_message | TEXT         |                                     | Last status message      |
| updated_at          | TIMESTAMP    | DEFAULT CURRENT_TIMESTAMP ON UPDATE | Last update              |

---

## 21. **ProductReturns Table**

Product returns and refunds.

| Column Name   | Data Type                                                                                | Constraints                 | Description              |
| ------------- | ---------------------------------------------------------------------------------------- | --------------------------- | ------------------------ |
| return_id     | INT                                                                                      | PRIMARY KEY, AUTO_INCREMENT | Unique identifier        |
| return_number | VARCHAR(50)                                                                              | UNIQUE                      | Display return number    |
| order_id      | INT                                                                                      | FOREIGN KEY (Orders)        | Original order           |
| order_item_id | INT                                                                                      | FOREIGN KEY (OrderItems)    | Item being returned      |
| user_id       | INT                                                                                      | FOREIGN KEY (Users)         | Requester                |
| reason        | VARCHAR(255)                                                                             | NOT NULL                    | Return reason            |
| description   | TEXT                                                                                     |                             | Detailed reason          |
| return_status | ENUM('requested','approved','rejected','shipped_back','received','refunded','completed') |                             | Return status            |
| refund_amount | DECIMAL(10, 2)                                                                           |                             | Refund amount            |
| refund_status | ENUM('pending','processed','completed')                                                  | DEFAULT 'pending'           | Refund processing status |
| created_at    | TIMESTAMP                                                                                | DEFAULT CURRENT_TIMESTAMP   | Request date             |
| approved_at   | TIMESTAMP                                                                                |                             | Approval date            |
| refunded_at   | TIMESTAMP                                                                                |                             | Refund date              |

---

## 22. **ProductSpecifications Table**

Detailed product specifications.

| Column Name   | Data Type    | Constraints                 | Description                          |
| ------------- | ------------ | --------------------------- | ------------------------------------ |
| spec_id       | INT          | PRIMARY KEY, AUTO_INCREMENT | Unique identifier                    |
| product_id    | INT          | FOREIGN KEY (Products)      | Related product                      |
| spec_name     | VARCHAR(100) | NOT NULL                    | Specification name                   |
| spec_value    | VARCHAR(255) | NOT NULL                    | Specification value                  |
| spec_category | VARCHAR(100) |                             | Category (technical, features, etc.) |
| display_order | INT          | DEFAULT 0                   | Display order                        |

---

## 23. **Inventory Table**

Detailed inventory management.

| Column Name        | Data Type    | Constraints                         | Description          |
| ------------------ | ------------ | ----------------------------------- | -------------------- |
| inventory_id       | INT          | PRIMARY KEY, AUTO_INCREMENT         | Unique identifier    |
| product_id         | INT          | FOREIGN KEY (Products)              | Product              |
| variant_id         | INT          | FOREIGN KEY (ProductVariants)       | Variant              |
| warehouse_location | VARCHAR(100) |                                     | Storage location     |
| current_stock      | INT          | DEFAULT 0                           | Current quantity     |
| reserved_stock     | INT          | DEFAULT 0                           | Reserved for orders  |
| available_stock    | INT          | DEFAULT 0                           | Available quantity   |
| reorder_level      | INT          | DEFAULT 10                          | Reorder threshold    |
| last_restocked     | TIMESTAMP    |                                     | Last restocking date |
| updated_at         | TIMESTAMP    | DEFAULT CURRENT_TIMESTAMP ON UPDATE | Last update          |

---

## Key Relationships & Constraints

### Foreign Key Relationships:

- `Categories.parent_category_id` → `Categories.category_id`
- `Products.category_id` → `Categories.category_id`
- `ProductImages.product_id` → `Products.product_id`
- `ProductVariants.product_id` → `Products.product_id`
- `Cart.user_id` → `Users.user_id`
- `CartItems.cart_id` → `Cart.cart_id`
- `CartItems.product_id` → `Products.product_id`
- `CartItems.variant_id` → `ProductVariants.variant_id`
- `Orders.user_id` → `Users.user_id`
- `Orders.payment_method_id` → `PaymentMethods.payment_method_id`
- `Orders.shipping_address_id` → `ShippingAddresses.address_id`
- `OrderItems.order_id` → `Orders.order_id`
- `OrderItems.product_id` → `Products.product_id`
- `ShippingAddresses.user_id` → `Users.user_id`
- `PaymentMethods.user_id` → `Users.user_id`
- `Reviews.product_id` → `Products.product_id`
- `Reviews.user_id` → `Users.user_id`
- `Wishlist.user_id` → `Users.user_id`
- `Wishlist.product_id` → `Products.product_id`
- `Notifications.user_id` → `Users.user_id`
- `SupportTickets.user_id` → `Users.user_id`
- `SupportTickets.assigned_to` → `Users.user_id`
- `Coupons.created_by` → `Users.user_id`

---

## Indexes for Performance

```sql
CREATE INDEX idx_users_email ON Users(email);
CREATE INDEX idx_products_category ON Products(category_id);
CREATE INDEX idx_products_sku ON Products(sku);
CREATE INDEX idx_orders_user ON Orders(user_id);
CREATE INDEX idx_orders_status ON Orders(order_status);
CREATE INDEX idx_reviews_product ON Reviews(product_id);
CREATE INDEX idx_reviews_user ON Reviews(user_id);
CREATE INDEX idx_cart_user ON Cart(user_id);
CREATE INDEX idx_wishlist_user ON Wishlist(user_id);
CREATE INDEX idx_notifications_user ON Notifications(user_id);
CREATE INDEX idx_tickets_status ON SupportTickets(status);
CREATE INDEX idx_orderitems_order ON OrderItems(order_id);
CREATE INDEX idx_activity_user ON UserActivityLog(user_id);
```

---

## Summary

**Total Tables: 23**

**Key Categories:**

- **User Management:** Users, ShippingAddresses, PaymentMethods
- **Product Management:** Products, Categories, ProductImages, ProductVariants, ProductSpecifications, Inventory
- **Shopping:** Cart, CartItems, Wishlist
- **Orders:** Orders, OrderItems, OrderTracking, ProductReturns
- **Reviews & Ratings:** Reviews
- **Promotions:** Coupons
- **Support:** SupportTickets, TicketMessages
- **Notifications:** Notifications
- **Logging & Analytics:** UserActivityLog, AdminActivityLog

This schema provides a complete, scalable, and normalized database structure that covers all aspects of the Tekzo e-commerce application without leaving anything for future additions.
