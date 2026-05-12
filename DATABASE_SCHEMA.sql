-- Tekzo E-Commerce Database Schema
-- Complete SQL implementation for Flutter app
-- Created: May 3, 2026

-- =====================================================
-- 1. USERS TABLE
-- =====================================================
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE,
    profile_image_url VARCHAR(500),
    date_of_birth DATE,
    gender ENUM('Male','Female','Other'),
    role ENUM('customer','admin','vendor') DEFAULT 'customer',
    is_active BOOLEAN DEFAULT TRUE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role)
);

-- =====================================================
-- 2. CATEGORIES TABLE
-- =====================================================
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    category_description TEXT,
    category_image_url VARCHAR(500),
    parent_category_id INT,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES Categories(category_id),
    INDEX idx_parent_id (parent_category_id)
);

-- =====================================================
-- 3. PRODUCTS TABLE
-- =====================================================
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    category_id INT NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    price DECIMAL(10, 2) NOT NULL,
    cost_price DECIMAL(10, 2),
    discount_percentage DECIMAL(5, 2) DEFAULT 0,
    final_price DECIMAL(10, 2),
    stock_quantity INT DEFAULT 0,
    minimum_stock INT DEFAULT 10,
    brand VARCHAR(100),
    weight DECIMAL(8, 3),
    dimensions VARCHAR(100),
    warranty_months INT DEFAULT 0,
    rating DECIMAL(3, 2) DEFAULT 0,
    total_reviews INT DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id),
    INDEX idx_category (category_id),
    INDEX idx_sku (sku),
    INDEX idx_featured (is_featured)
);

-- =====================================================
-- 4. PRODUCT IMAGES TABLE
-- =====================================================
CREATE TABLE ProductImages (
    image_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    display_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    INDEX idx_product_id (product_id)
);

-- =====================================================
-- 5. PRODUCT VARIANTS TABLE
-- =====================================================
CREATE TABLE ProductVariants (
    variant_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    variant_name VARCHAR(100) NOT NULL,
    variant_type VARCHAR(50) NOT NULL,
    variant_value VARCHAR(100) NOT NULL,
    sku_variant VARCHAR(100) UNIQUE,
    price_adjustment DECIMAL(10, 2) DEFAULT 0,
    stock_quantity INT DEFAULT 0,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    INDEX idx_product_id (product_id),
    INDEX idx_variant_type (variant_type)
);

-- =====================================================
-- 6. PRODUCT SPECIFICATIONS TABLE
-- =====================================================
CREATE TABLE ProductSpecifications (
    spec_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    spec_name VARCHAR(100) NOT NULL,
    spec_value VARCHAR(255) NOT NULL,
    spec_category VARCHAR(100),
    display_order INT DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    INDEX idx_product_id (product_id)
);

-- =====================================================
-- 7. CART TABLE
-- =====================================================
CREATE TABLE Cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
);

-- =====================================================
-- 8. CART ITEMS TABLE
-- =====================================================
CREATE TABLE CartItems (
    cart_item_id INT PRIMARY KEY AUTO_INCREMENT,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    variant_id INT,
    quantity INT NOT NULL,
    price_at_time DECIMAL(10, 2),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cart_id) REFERENCES Cart(cart_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (variant_id) REFERENCES ProductVariants(variant_id),
    INDEX idx_cart_id (cart_id)
);

-- =====================================================
-- 9. SHIPPING ADDRESSES TABLE
-- =====================================================
CREATE TABLE ShippingAddresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    address_type ENUM('shipping','billing','both') DEFAULT 'shipping',
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    apartment_number VARCHAR(50),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_address_type (address_type)
);

-- =====================================================
-- 10. PAYMENT METHODS TABLE
-- =====================================================
CREATE TABLE PaymentMethods (
    payment_method_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    payment_type ENUM('credit_card','debit_card','upi','wallet','bank_transfer','paypal') NOT NULL,
    card_holder_name VARCHAR(150),
    card_last_four VARCHAR(4),
    card_expiry_month INT,
    card_expiry_year INT,
    card_brand VARCHAR(50),
    upi_id VARCHAR(100),
    bank_account_number VARCHAR(50),
    bank_ifsc VARCHAR(20),
    bank_name VARCHAR(150),
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_payment_type (payment_type)
);

-- =====================================================
-- 11. ORDERS TABLE
-- =====================================================
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    shipping_cost DECIMAL(10, 2) DEFAULT 0,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    coupon_code VARCHAR(50),
    total_amount DECIMAL(10, 2) NOT NULL,
    order_status ENUM('pending','processing','shipped','delivered','cancelled','returned') DEFAULT 'pending',
    payment_status ENUM('pending','completed','failed','refunded') DEFAULT 'pending',
    payment_method_id INT,
    shipping_address_id INT NOT NULL,
    billing_address_id INT NOT NULL,
    notes TEXT,
    tracking_number VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    delivered_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (payment_method_id) REFERENCES PaymentMethods(payment_method_id),
    FOREIGN KEY (shipping_address_id) REFERENCES ShippingAddresses(address_id),
    FOREIGN KEY (billing_address_id) REFERENCES ShippingAddresses(address_id),
    INDEX idx_user_id (user_id),
    INDEX idx_order_status (order_status),
    INDEX idx_payment_status (payment_status),
    INDEX idx_order_number (order_number)
);

-- =====================================================
-- 12. ORDER ITEMS TABLE
-- =====================================================
CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    variant_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    warranty_included BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (variant_id) REFERENCES ProductVariants(variant_id),
    INDEX idx_order_id (order_id)
);

-- =====================================================
-- 13. ORDER TRACKING TABLE
-- =====================================================
CREATE TABLE OrderTracking (
    tracking_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    tracking_number VARCHAR(100),
    carrier VARCHAR(100),
    status VARCHAR(50),
    location VARCHAR(255),
    estimated_delivery DATE,
    last_update_message TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id)
);

-- =====================================================
-- 14. REVIEWS TABLE
-- =====================================================
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    order_item_id INT,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_title VARCHAR(200),
    review_text TEXT,
    verified_purchase BOOLEAN DEFAULT FALSE,
    is_published BOOLEAN DEFAULT FALSE,
    helpful_count INT DEFAULT 0,
    unhelpful_count INT DEFAULT 0,
    response_text TEXT,
    responded_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (order_item_id) REFERENCES OrderItems(order_item_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    INDEX idx_product_id (product_id),
    INDEX idx_user_id (user_id),
    INDEX idx_is_published (is_published),
    INDEX idx_rating (rating)
);

-- =====================================================
-- 15. WISHLIST TABLE
-- =====================================================
CREATE TABLE Wishlist (
    wishlist_item_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    note VARCHAR(500),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_product (user_id, product_id),
    INDEX idx_user_id (user_id)
);

-- =====================================================
-- 16. NOTIFICATIONS TABLE
-- =====================================================
CREATE TABLE Notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    notification_type ENUM('order_update','promotion','review','product','system','payment') NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    related_entity_type VARCHAR(50),
    related_entity_id INT,
    is_read BOOLEAN DEFAULT FALSE,
    action_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_notification_type (notification_type)
);

-- =====================================================
-- 17. COUPONS TABLE
-- =====================================================
CREATE TABLE Coupons (
    coupon_id INT PRIMARY KEY AUTO_INCREMENT,
    coupon_code VARCHAR(50) UNIQUE NOT NULL,
    discount_type ENUM('percentage','fixed_amount') NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL,
    minimum_order_value DECIMAL(10, 2) DEFAULT 0,
    maximum_discount DECIMAL(10, 2),
    usage_limit INT,
    usage_per_user INT DEFAULT 1,
    current_usage INT DEFAULT 0,
    valid_from TIMESTAMP,
    valid_until TIMESTAMP,
    applicable_categories VARCHAR(500),
    applicable_products VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES Users(user_id),
    INDEX idx_coupon_code (coupon_code),
    INDEX idx_valid_dates (valid_from, valid_until)
);

-- =====================================================
-- 18. SUPPORT TICKETS TABLE
-- =====================================================
CREATE TABLE SupportTickets (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_number VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    related_order_id INT,
    related_product_id INT,
    category ENUM('shipping','payment','product_quality','missing_items','refund','general','complaint') NOT NULL,
    priority ENUM('low','medium','high','urgent') DEFAULT 'medium',
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status ENUM('open','in_progress','waiting_customer','resolved','closed') DEFAULT 'open',
    assigned_to INT,
    resolution_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (related_order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (related_product_id) REFERENCES Products(product_id),
    FOREIGN KEY (assigned_to) REFERENCES Users(user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_ticket_number (ticket_number)
);

-- =====================================================
-- 19. TICKET MESSAGES TABLE
-- =====================================================
CREATE TABLE TicketMessages (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    sender_id INT NOT NULL,
    message_text TEXT NOT NULL,
    attachment_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES SupportTickets(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES Users(user_id),
    INDEX idx_ticket_id (ticket_id)
);

-- =====================================================
-- 20. PRODUCT RETURNS TABLE
-- =====================================================
CREATE TABLE ProductReturns (
    return_id INT PRIMARY KEY AUTO_INCREMENT,
    return_number VARCHAR(50) UNIQUE NOT NULL,
    order_id INT NOT NULL,
    order_item_id INT NOT NULL,
    user_id INT NOT NULL,
    reason VARCHAR(255) NOT NULL,
    description TEXT,
    return_status ENUM('requested','approved','rejected','shipped_back','received','refunded','completed') DEFAULT 'requested',
    refund_amount DECIMAL(10, 2),
    refund_status ENUM('pending','processed','completed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    refunded_at TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (order_item_id) REFERENCES OrderItems(order_item_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    INDEX idx_order_id (order_id),
    INDEX idx_return_status (return_status)
);

-- =====================================================
-- 21. INVENTORY TABLE
-- =====================================================
CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    variant_id INT,
    warehouse_location VARCHAR(100),
    current_stock INT DEFAULT 0,
    reserved_stock INT DEFAULT 0,
    available_stock INT DEFAULT 0,
    reorder_level INT DEFAULT 10,
    last_restocked TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (variant_id) REFERENCES ProductVariants(variant_id),
    INDEX idx_product_id (product_id)
);

-- =====================================================
-- 22. USER ACTIVITY LOG TABLE
-- =====================================================
CREATE TABLE UserActivityLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    activity_type ENUM('login','logout','view_product','add_to_cart','purchase','review','support_ticket','wishlist') NOT NULL,
    description VARCHAR(500),
    ip_address VARCHAR(45),
    device_info VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_activity_type (activity_type),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- 23. ADMIN ACTIVITY LOG TABLE
-- =====================================================
CREATE TABLE AdminActivityLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    admin_id INT NOT NULL,
    action_type ENUM('create','update','delete','view','export','approve','reject') NOT NULL,
    entity_type VARCHAR(50),
    entity_id INT,
    changes_made JSON,
    reason TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES Users(user_id),
    INDEX idx_admin_id (admin_id),
    INDEX idx_entity_type (entity_type),
    INDEX idx_created_at (created_at)
);

-- =====================================================
-- ADDITIONAL INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX idx_products_search ON Products(product_name, sku);
CREATE INDEX idx_orders_created_at ON Orders(created_at);
CREATE INDEX idx_reviews_created_at ON Reviews(created_at);
CREATE INDEX idx_notifications_created_at ON Notifications(created_at);
CREATE INDEX idx_cart_items_product ON CartItems(product_id);
CREATE INDEX idx_wishlist_product ON Wishlist(product_id);

-- =====================================================
-- STORED PROCEDURES & TRIGGERS (Optional but Recommended)
-- =====================================================

-- Trigger to update product final_price when price or discount changes
DELIMITER //
CREATE TRIGGER update_final_price BEFORE UPDATE ON Products
FOR EACH ROW
BEGIN
    SET NEW.final_price = NEW.price * (1 - NEW.discount_percentage / 100);
END//
DELIMITER ;

-- Trigger to update order total when order items change
DELIMITER //
CREATE TRIGGER update_order_total AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
    UPDATE Orders 
    SET total_amount = subtotal + tax_amount + shipping_cost - discount_amount
    WHERE order_id = NEW.order_id;
END//
DELIMITER ;

-- =====================================================
-- DATABASE COMPLETE
-- =====================================================
-- Total Tables: 23
-- This schema provides complete coverage for all Tekzo app features
