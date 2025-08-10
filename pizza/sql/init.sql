-- init.sql: Create DB, tables and sample data for Pizza Shop
CREATE DATABASE IF NOT EXISTS pizza_shop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pizza_shop;

-- users
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  address TEXT DEFAULT NULL,
  role ENUM('user','admin') NOT NULL DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- products
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  image VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- vouchers
CREATE TABLE vouchers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  type ENUM('percent','fixed') NOT NULL,
  value DECIMAL(10,2) NOT NULL,
  uses INT DEFAULT 0,
  max_uses INT DEFAULT 0,
  expires_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- orders
CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  discount DECIMAL(10,2) DEFAULT 0,
  voucher_code VARCHAR(50) DEFAULT NULL,
  address TEXT,
  payment_method VARCHAR(50) DEFAULT 'cod',
  payment_status ENUM('pending','paid','failed') DEFAULT 'pending',
  status ENUM('pending','preparing','shipped','cancelled') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- order_items
CREATE TABLE order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT,
  name VARCHAR(150),
  crust VARCHAR(50),
  size VARCHAR(50),
  price DECIMAL(10,2),
  quantity INT,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- -- sample admin (password: password123)
-- INSERT INTO users (name, email, password, role) VALUES
-- ('Admin','admin@example.com',
--  '$2y$10$e0NRGf0YzQdWv7oZ4KJzOO0xInkfT5c1qk2hZk7k.g1zS7ZzK5m6S', 'admin');

-- -- sample products
-- INSERT INTO products (name, description, price, image) VALUES
-- ('Margherita','Classic pizza with tomato, mozzarella and basil', 7.50, 'uploads/margherita.jpg'),
-- ('Pepperoni','Pepperoni, cheese and tomato sauce', 9.00, 'uploads/pepperoni.jpg'),
-- ('Hawaiian','Ham, pineapple and cheese', 9.50, 'uploads/hawaiian.jpg');

-- -- sample voucher: 10% off, max uses 100
-- INSERT INTO vouchers (code, type, value, uses, max_uses, expires_at) VALUES
-- ('WELCOME10','percent',10.00,0,100, NULL);
