-- Insert sample customers
INSERT INTO customers VALUES
(1, 'Ana Petrović', 'ana.petrovic@email.com', 'Serbia', 'Belgrade', '2023-01-15'),
(2, 'Marko Jovanović', 'marko.jovanovic@email.com', 'Serbia', 'Novi Sad', '2023-02-20'),
(3, 'Jovana Nikolić', 'jovana.nikolic@email.com', 'Serbia', 'Niš', '2023-03-10'),
(4, 'Stefan Đorđević', 'stefan.djordjevic@email.com', 'Serbia', 'Belgrade', '2023-04-05'),
(5, 'Milica Stojanović', 'milica.stojanovic@email.com', 'Serbia', 'Kragujevac', '2023-05-12');

-- Insert sample products
INSERT INTO products VALUES
(1, 'Laptop Dell XPS 13', 'Electronics', 1299.99, 900.00),
(2, 'iPhone 14 Pro', 'Electronics', 1099.99, 750.00),
(3, 'Sony Headphones WH-1000XM5', 'Electronics', 399.99, 250.00),
(4, 'Samsung 4K TV 55"', 'Electronics', 799.99, 550.00),
(5, 'Office Chair Ergonomic', 'Furniture', 299.99, 150.00),
(6, 'Standing Desk', 'Furniture', 499.99, 300.00),
(7, 'Running Shoes Nike', 'Sports', 129.99, 70.00),
(8, 'Yoga Mat Premium', 'Sports', 49.99, 20.00);

-- Insert sample orders
INSERT INTO orders VALUES
(1, 1, '2024-01-10', 1699.98, 'Completed'),
(2, 2, '2024-01-15', 1099.99, 'Completed'),
(3, 3, '2024-02-01', 449.98, 'Completed'),
(4, 1, '2024-02-14', 799.99, 'Completed'),
(5, 4, '2024-03-05', 929.97, 'Completed'),
(6, 5, '2024-03-20', 299.99, 'Cancelled'),
(7, 2, '2024-04-10', 549.98, 'Completed'),
(8, 3, '2024-04-25', 1599.98, 'Completed');

-- Insert sample order items
INSERT INTO order_items VALUES
(1, 1, 1, 1, 1299.99),
(2, 1, 3, 1, 399.99),
(3, 2, 2, 1, 1099.99),
(4, 3, 3, 1, 399.99),
(5, 3, 8, 1, 49.99),
(6, 4, 4, 1, 799.99),
(7, 5, 7, 3, 129.99),
(8, 5, 8, 4, 49.99),
(9, 6, 5, 1, 299.99),
(10, 7, 6, 1, 499.99),
(11, 7, 8, 1, 49.99),
(12, 8, 1, 1, 1299.99),
(13, 8, 5, 1, 299.99);