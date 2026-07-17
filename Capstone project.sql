DROP DATABASE IF EXISTS Ecommerce_db;
DROP DATABASE IF EXISTS Ecommerce_db;
CREATE DATABASE Ecommerce_db;
USE Ecommerce_db;

-- 1. Users
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL DEFAULT 'First',
    last_name VARCHAR(50) NOT NULL DEFAULT 'Last',
    role ENUM('Customer', 'Admin', 'Support', 'InventoryManager') DEFAULT 'Customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Categories
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

-- 3. Products
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE SET NULL,
    INDEX idx_prod_name (product_name)
);

-- 4. Cart
CREATE TABLE Cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    UNIQUE (user_id, product_id)
);

-- 5. Orders
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    order_status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    shipping_address TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE RESTRICT
);

-- 6. Order Items
CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE RESTRICT
);

-- 7. Payments
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    payment_method ENUM('Credit Card', 'PayPal', 'Stripe') NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE
);

-- 8. Reviews
CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    UNIQUE (user_id, product_id)
);

-- 9. Wishlist
CREATE TABLE Wishlist (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    UNIQUE (user_id, product_id)
);

-- 10. Audit Logs
CREATE TABLE Audit_Logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    action_performed VARCHAR(20) NOT NULL,
    record_id INT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- MODULE 5: CRUD Operations
INSERT INTO Cart (user_id, product_id, quantity) VALUES (1, 2, 2);
SELECT * FROM Products WHERE price < 100.00;
UPDATE Products SET price = 949.99 WHERE product_id = 1;
DELETE FROM Cart WHERE user_id = 1;

-- MODULE 6: Business Queries
SELECT * FROM Orders WHERE user_id = 1;
SELECT product_name, stock_quantity FROM Products WHERE stock_quantity <= 5;
SELECT IFNULL(SUM(amount), 0.00) FROM Payments WHERE payment_status='Completed';
SELECT user_id, username FROM Users WHERE user_id NOT IN (SELECT DISTINCT user_id FROM Orders);
SELECT product_id, COUNT(*) FROM Order_Items GROUP BY product_id ORDER BY COUNT(*) DESC LIMIT 1;
SELECT category_name, SUM(oi.quantity * oi.unit_price) FROM Order_Items oi JOIN Products p ON oi.product_id = p.product_id JOIN Categories c ON p.category_id = c.category_id GROUP BY category_name ORDER BY 2 DESC LIMIT 1;

-- MODULE 7: Joins
SELECT o.order_id, u.username, p.product_name FROM Order_Items oi INNER JOIN Orders o ON oi.order_id = o.order_id INNER JOIN Users u ON o.user_id = u.user_id INNER JOIN Products p ON oi.product_id = p.product_id;
SELECT c.category_name, p.product_name FROM Categories c LEFT JOIN Products p ON c.category_id = p.category_id;
SELECT oi1.order_id, oi1.product_id, oi2.product_id FROM Order_Items oi1 JOIN Order_Items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id;

-- MODULE 8: Subqueries
SELECT product_name FROM Products WHERE price > (SELECT AVG(price) FROM Products);
SELECT user_id FROM Orders GROUP BY user_id ORDER BY SUM(total_amount) DESC LIMIT 1;
SELECT product_name FROM Products WHERE product_id NOT IN (SELECT DISTINCT product_id FROM Order_Items);

-- MODULE 9: Views
CREATE OR REPLACE VIEW View_Customer_Orders AS 
SELECT u.username, COUNT(o.order_id) AS total_orders, IFNULL(SUM(o.total_amount), 0) AS total_spent FROM Users u LEFT JOIN Orders o ON u.user_id = o.user_id GROUP BY u.username;

CREATE OR REPLACE VIEW View_Low_Stock AS 
SELECT product_name, stock_quantity FROM Products WHERE stock_quantity < 10;

CREATE OR REPLACE VIEW View_Sales_Summary AS 
SELECT p.product_name, IFNULL(SUM(oi.quantity), 0) AS units_sold FROM Products p LEFT JOIN Order_Items oi ON p.product_id = oi.product_id GROUP BY p.product_name;

-- MODULE 10: Stored Procedures
DELIMITER //
CREATE PROCEDURE AddProduct(IN cat_id INT, IN name_p VARCHAR(100), IN price_p DECIMAL(10,2), IN stock_p INT)
BEGIN
    INSERT INTO Products(category_id, product_name, price, stock_quantity) VALUES (cat_id, name_p, price_p, stock_p);
END //

CREATE PROCEDURE GetUserOrders(IN uid INT)
BEGIN
    SELECT * FROM Orders WHERE user_id = uid;
END //
DELIMITER ;

-- MODULE 11: Triggers
DELIMITER //
CREATE TRIGGER LogProductDelete AFTER DELETE ON Products FOR EACH ROW
BEGIN
    INSERT INTO Audit_Logs(table_name, action_performed, record_id) VALUES ('Products', 'DELETE', OLD.product_id);
END //

CREATE TRIGGER BlockNegativeStock BEFORE UPDATE ON Products FOR EACH ROW
BEGIN
    IF NEW.stock_quantity < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock cannot fall below zero';
    END IF;
END //
DELIMITER ;

-- MODULE 12: Transactions (TCL)
START TRANSACTION;
INSERT INTO Orders (user_id, total_amount, order_status, shipping_address) VALUES (1, 89.99, 'Pending', '123 Elm St');
SET @oid = LAST_INSERT_ID();

SAVEPOINT ItemsAttached;
INSERT INTO Order_Items (order_id, product_id, quantity, unit_price) VALUES (@oid, 2, 1, 89.99);
UPDATE Orders SET order_status = 'Cancelled' WHERE order_id = @oid;
COMMIT;

-- MODULE 13 & 14: String & Date Functions
SELECT UPPER(username), CONCAT(first_name, ' ', last_name), SUBSTRING_INDEX(email, '@', -1) FROM Users;
SELECT * FROM Orders WHERE DATE(order_date) = CURDATE();
SELECT * FROM Orders WHERE order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY);

-- MODULE 15: Database Control Language (DCL)
CREATE USER IF NOT EXISTS 'inventory_mgr'@'localhost' IDENTIFIED BY 'SecurePass123!';
GRANT SELECT, INSERT, UPDATE ON shopsphere_db.Products TO 'inventory_mgr'@'localhost';
FLUSH PRIVILEGES;


-- Switch to the correct project database container
USE shopsphere_db;

-- Now run your insert statement
INSERT INTO Cart (user_id, product_id, quantity) 
VALUES (1, 2, 2);
show tables