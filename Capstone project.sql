DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- 1. Users Table (Customer Registration)
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    role ENUM('Customer', 'Admin', 'Support', 'InventoryManager') DEFAULT 'Customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Categories Table (Product Categories)
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- 3. Products Table (Product Management / Inventory Management)
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE SET NULL,
    INDEX idx_product_name (product_name)
);

-- 4. Cart Table (Shopping Cart)
CREATE TABLE Cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_product_cart (user_id, product_id)
);

-- 5. Orders Table (Order Placement)
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    order_status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    shipping_address TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE RESTRICT,
    INDEX idx_order_date (order_date)
);

-- 6. Order Items Table (Order Connections)
CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE RESTRICT
);

-- 7. Payments Table (Payments Management)
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    payment_method ENUM('Credit Card', 'PayPal', 'Stripe', 'Bank Transfer') NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE
);

-- 8. Reviews Table (Product Reviews)
CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_product_review (user_id, product_id)
);

-- 9. Wishlist Table (Wishlist Management)
CREATE TABLE Wishlist (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_product_wishlist (user_id, product_id)
);

-- 10. Audit Logs Table (Audit Logging)
CREATE TABLE Audit_Logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    action_performed ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    record_id INT NOT NULL,
    old_value TEXT,
    new_value TEXT,
    performed_by VARCHAR(100),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1. Seed Categories (5)
INSERT INTO Categories (category_name, description) VALUES
('Electronics', 'Gadgets and devices'),
('Clothing', 'Apparel and fashion'),
('Home & Kitchen', 'Appliances and decor'),
('Books', 'Printed and digital books'),
('Beauty', 'Cosmetics and skincare');

-- 2. Seed Users (20)
INSERT INTO Users (username, email, password_hash, first_name, last_name, phone, role) VALUES
('alice_w', 'alice.smith@gmail.com', 'hash1', 'Alice', 'Smith', '555-0101', 'Customer'),
('bob_j', 'bob.jones@yahoo.com', 'hash2', 'Bob', 'Jones', '555-0102', 'Customer'),
('charlie_b', 'charlie.brown@outlook.com', 'hash3', 'Charlie', 'Brown', '555-0103', 'Customer'),
('david_m', 'david.miller@gmail.com', 'hash4', 'David', 'Miller', '555-0104', 'Customer'),
('emma_w', 'emma.watson@gmail.com', 'hash5', 'Emma', 'Watson', '555-0105', 'Customer'),
('frank_t', 'frank.thomas@yahoo.com', 'hash6', 'Frank', 'Thomas', '555-0106', 'Customer'),
('grace_h', 'grace.harris@gmail.com', 'hash7', 'Grace', 'Harris', '555-0107', 'Customer'),
('henry_g', 'henry.green@outlook.com', 'hash8', 'Henry', 'Green', '555-0108', 'Customer'),
('ivy_c', 'ivy.carter@gmail.com', 'hash9', 'Ivy', 'Carter', '555-0109', 'Customer'),
('jack_r', 'jack.robinson@yahoo.com', 'hash10', 'Jack', 'Robinson', '555-0110', 'Customer'),
('kevin_d', 'kevin.davis@gmail.com', 'hash11', 'Kevin', 'Davis', '555-0111', 'Customer'),
('lily_e', 'lily.evans@gmail.com', 'hash12', 'Lily', 'Evans', '555-0112', 'Customer'),
('matt_k', 'matt.king@outlook.com', 'hash13', 'Matt', 'King', '555-0113', 'Customer'),
('nancy_l', 'nancy.lopez@gmail.com', 'hash14', 'Nancy', 'Lopez', '555-0114', 'Customer'),
('oliver_s', 'oliver.scott@yahoo.com', 'hash15', 'Oliver', 'Scott', '555-0115', 'Customer'),
('penelope_c', 'penelope.cruz@gmail.com', 'hash16', 'Penelope', 'Cruz', '555-0116', 'Customer'),
('quinn_f', 'quinn.fisher@gmail.com', 'hash17', 'Quinn', 'Fisher', '555-0117', 'Customer'),
('admin_user', 'admin@ecommerce.com', 'adminhash', 'System', 'Admin', '555-0001', 'Admin'),
('support_user', 'support@ecommerce.com', 'supphash', 'Support', 'Agent', '555-0002', 'Support'),
('inv_manager', 'inventory@ecommerce.com', 'invhash', 'Inventory', 'Manager', '555-0003', 'InventoryManager');

-- 3. Seed Products (30)
INSERT INTO Products (category_id, product_name, description, price, stock_quantity) VALUES
(1, 'Smartphone X', 'Flagship 5G device', 999.99, 50),
(1, 'Laptop Pro 15', 'High performance workstation', 1499.99, 20),
(1, 'Wireless Earbuds', 'Noise cancelling headphones', 149.99, 150),
(1, 'Smart Watch Series 5', 'Fitness tracker watch', 299.99, 2),
(1, 'Bluetooth Speaker', 'Waterproof outdoor speaker', 79.99, 80),
(1, '4K Ultra Smart TV 55', 'Stunning visual clarity display', 599.99, 12),
(2, 'Classic Denim Jacket', 'Timeless fashion outer layer', 89.99, 45),
(2, 'Slim Fit Chinos', 'Comfortable business casual pants', 49.99, 60),
(2, 'Running Shoes Max', 'Breathable athletic sneakers', 120.00, 35),
(2, 'Graphic Cotton T-Shirt', '100% organic cotton tee', 24.99, 200),
(2, 'Wool Winter Coat', 'Warm double-breasted insulation', 179.99, 15),
(2, 'Leather Dress Belt', 'Genuine top-grain leather strap', 34.99, 90),
(3, 'Air Fryer XL', 'Oil-free rapid convection cooker', 129.99, 25),
(3, 'Blender Express', 'High-speed smoothie extraction mixer', 59.99, 40),
(3, 'Coffee Maker Pod System', 'Single-serve espresso maker', 89.99, 3),
(3, 'Memory Foam Pillow', 'Ergonomic neck support bedding', 39.99, 75),
(3, 'Stainless Steel Cookware Set', '10-piece kitchen pans', 249.99, 18),
(3, 'Robot Vacuum Cleaner', 'Automated floor sweep mapping navigation', 320.00, 8),
(4, 'SQL for Absolute Beginners', 'Comprehensive database tutorial', 29.99, 120),
(4, 'Mastering Backend Systems', 'Advanced guide to scaling microservices', 49.99, 50),
(4, 'The Fiction Novel Collection', 'Hardcover compilation anthology', 19.99, 85),
(4, 'Data Structures & Algorithms', 'In-depth guide for dynamic system design', 55.00, 40),
(4, 'Introduction to Financial Freedom', 'Personal wealth asset building tactics', 15.99, 110),
(4, 'Digital Marketing Essentials', 'Modern growth hacking strategies', 27.50, 65),
(5, 'Hydrating Face Moisturizer', 'All-day organic hydration skin formula', 22.00, 95),
(5, 'Anti-Aging Vitamin C Serum', 'Brightening facial serum skincare boost', 35.50, 4),
(5, 'Matte Long-wear Lipstick', 'Velvet finish rich coloration pigment', 18.00, 110),
(5, 'Exfoliating Charcoal Scrub', 'Deep pore detoxifying wash blend', 14.50, 85),
(5, 'Mineral Protection Sunscreen', 'SPF 50 broad spectrum defense block', 26.00, 70),
(5, 'Luxury Argan Hair Oil', 'Nourishing dry hair repair treatment', 42.00, 30);

-- 4. Seed Orders (20)
INSERT INTO Orders (user_id, total_amount, order_status, shipping_address, order_date) VALUES
(1, 1149.98, 'Delivered', '123 Elm St, NY', '2026-07-01 10:00:00'),
(2, 149.99, 'Delivered', '456 Oak St, CA', '2026-07-02 11:30:00'),
(3, 1549.98, 'Delivered', '789 Pine St, TX', '2026-07-03 14:15:00'),
(4, 599.99, 'Shipped', '101 Cedar Rd, FL', '2026-07-05 09:00:00'),
(5, 74.98, 'Processing', '202 Maple Av, IL', '2026-07-06 16:45:00'),
(6, 129.99, 'Pending', '303 Birch Dr, WA', '2026-07-17 08:30:00'),
(7, 349.98, 'Delivered', '404 Walnut Ln, CO', '2026-07-08 12:00:00'),
(8, 29.99, 'Delivered', '505 Cherry St, MI', '2026-07-09 10:15:00'),
(9, 189.98, 'Shipped', '606 Ash Blvd, OH', '2026-07-10 15:20:00'),
(10, 320.00, 'Pending', '707 Beech Ct, GA', '2026-07-17 09:15:00'),
(11, 49.99, 'Delivered', '808 Willow Way, NC', '2026-06-15 11:00:00'),
(12, 104.98, 'Delivered', '909 Hickory Pl, VA', '2026-06-20 14:00:00'),
(13, 22.00, 'Cancelled', '111 Aspen Dr, AZ', '2026-07-11 17:00:00'),
(14, 999.99, 'Delivered', '222 Cypress Rd, NV', '2026-07-12 13:45:00'),
(15, 299.99, 'Processing', '333 Poplar St, OR', '2026-07-13 10:30:00'),
(1, 159.98, 'Delivered', '123 Elm St, NY', '2026-07-14 09:00:00'),
(2, 59.99, 'Delivered', '456 Oak St, CA', '2026-07-15 16:00:00'),
(3, 42.00, 'Pending', '789 Pine St, TX', '2026-07-17 09:25:00'),
(4, 215.49, 'Delivered', '101 Cedar Rd, FL', '2026-07-16 11:15:00'),
(5, 1499.99, 'Shipped', '202 Maple Av, IL', '2026-07-16 12:30:00');

-- 5. Seed Order Items (50)
INSERT INTO Order_Items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 999.99), (1, 3, 1, 149.99), (2, 3, 1, 149.99), (3, 2, 1, 1499.99), 
(3, 8, 1, 49.99), (4, 6, 1, 599.99), (5, 8, 1, 49.99), (5, 10, 1, 24.99), 
(6, 13, 1, 129.99), (7, 4, 1, 299.99), (7, 8, 1, 49.99), (8, 19, 1, 29.99), 
(9, 11, 1, 179.99), (9, 21, 1, 19.99), (10, 18, 1, 320.00), (11, 20, 1, 49.99), 
(12, 14, 1, 59.99), (12, 21, 1, 19.99), (12, 27, 1, 18.00), (13, 25, 1, 22.00), 
(14, 1, 1, 999.99), (15, 4, 1, 299.99), (16, 5, 2, 79.99), (17, 14, 1, 59.99), 
(18, 30, 1, 42.00), (19, 13, 1, 129.99), (19, 7, 1, 89.99), (19, 28, 1, 14.50), 
(20, 2, 1, 1499.99), (1, 10, 2, 24.99), (2, 12, 1, 34.99), (3, 24, 1, 27.50), 
(4, 29, 2, 26.00), (5, 25, 1, 22.00), (7, 26, 1, 35.50), (9, 27, 2, 18.00), 
(11, 19, 1, 29.99), (14, 5, 1, 79.99), (15, 9, 1, 120.00), (16, 22, 1, 34.99), 
(17, 23, 1, 15.99), (19, 12, 1, 34.99), (20, 10, 1, 24.99), (6, 25, 1, 22.00), 
(8, 28, 1, 14.50), (10, 29, 1, 26.00), (12, 30, 1, 42.00), (13, 26, 1, 35.50), 
(18, 27, 1, 18.00), (2, 22, 1, 34.99);

-- 6. Seed Payments (20)
INSERT INTO Payments (order_id, amount, payment_method, payment_status) VALUES
(1, 1149.98, 'Credit Card', 'Completed'),
(2, 149.99, 'PayPal', 'Completed'),
(3, 1549.98, 'Stripe', 'Completed'),
(4, 599.99, 'Bank Transfer', 'Completed'),
(5, 74.98, 'Credit Card', 'Completed'),
(6, 129.99, 'PayPal', 'Pending'),
(7, 349.98, 'Stripe', 'Completed'),
(8, 29.99, 'Credit Card', 'Completed'),
(9, 189.98, 'PayPal', 'Completed'),
(10, 320.00, 'Bank Transfer', 'Pending'),
(11, 49.99, 'Credit Card', 'Completed'),
(12, 104.98, 'PayPal', 'Completed'),
(13, 22.00, 'Stripe', 'Failed'),
(14, 999.99, 'Credit Card', 'Completed'),
(15, 299.99, 'Bank Transfer', 'Completed'),
(16, 159.98, 'PayPal', 'Completed'),
(17, 59.99, 'Credit Card', 'Completed'),
(18, 42.00, 'Stripe', 'Pending'),
(19, 215.49, 'Credit Card', 'Completed'),
(20, 1499.99, 'Bank Transfer', 'Completed');

-- 7. Seed Reviews (25)
INSERT INTO Reviews (user_id, product_id, rating, comment) VALUES
(1, 1, 5, 'Perfect smartphone. Fast and brilliant display!'),
(2, 3, 4, 'Great sound output, comfort could be improved.'),
(3, 2, 5, 'Expensive beast! Speeds up my daily developer workflow.'),
(4, 6, 4, 'Terrific picture quality but dashboard UI is laggy.'),
(5, 8, 4, 'Great fit, stylish design for basic office wear.'),
(6, 13, 5, 'Super clean air-fryer operations! Chicken tastes perfect.'),
(7, 4, 3, 'Battery life runs short if tracking metrics.'),
(8, 19, 5, 'Exactly what I needed to master relational databases.'),
(9, 11, 5, 'Incredibly warm and heavy material coat.'),
(10, 18, 4, 'Cleans the floor completely. Avoids obstacles.'),
(11, 20, 5, 'A masterpiece explanation of scaling systems.'),
(12, 14, 4, 'Very good morning smoothie blending machine.'),
(13, 25, 1, 'Caused dynamic redness, do not recommend.'),
(14, 5, 5, 'Louder than it looks! Bass packs an authentic punch.'),
(15, 9, 4, 'Comfortable athletic sole sneakers.'),
(1, 10, 4, 'Simple cool design fabric print cotton tee.'),
(2, 22, 5, 'Sturdy buckle, fine cut real leather strip belt.'),
(3, 24, 4, 'Valuable strategies inside for marketing setups.'),
(4, 29, 5, 'Zero white cast residue face protection block.'),
(5, 21, 3, 'Interesting plot lines, text print font is small.'),
(6, 26, 4, 'Brightened skin spots over two weeks usage.'),
(7, 27, 5, 'Beautiful deep coloration long wear velvet lipstick.'),
(8, 28, 4, 'Deeply refreshing face charcoal scrub mix.'),
(9, 30, 5, 'Leaves fine hair silky with pleasant argan aroma.'),
(10, 12, 4, 'Solid hold clothing dress belt.');

-- 8. Seed Wishlist (20)
INSERT INTO Wishlist (user_id, product_id) VALUES
(1, 2), (1, 6), (2, 1), (3, 5), (4, 12),
(5, 15), (6, 20), (7, 18), (8, 2), (9, 3),
(10, 4), (11, 6), (12, 7), (13, 8), (14, 9),
(15, 10), (16, 11), (17, 13), (2, 14), (3, 25);

-- INSERT: Customer adds an item to their shopping cart
INSERT INTO Cart (user_id, product_id, quantity) VALUES (1, 3, 2);

-- SELECT: Fetch specific items from inventory catalog
SELECT * FROM Products WHERE price <= 100.00;

-- UPDATE: Admin updates a product price
UPDATE Products SET price = 1399.99 WHERE product_id = 2;

-- DELETE: Warehouse removes an item from cart
DELETE FROM Cart WHERE product_id = 15; 

-- INSERT: Customer adds an item to their shopping cart
INSERT INTO Cart (user_id, product_id, quantity) VALUES (1, 3, 2);

-- SELECT: Fetch specific items from inventory catalog
SELECT * FROM Products WHERE price <= 100.00;

-- UPDATE: Admin updates a product price
UPDATE Products SET price = 1399.99 WHERE product_id = 2;

-- DELETE: Warehouse removes an item from cart
DELETE FROM Cart WHERE product_id = 15;