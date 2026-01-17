# 📊 E-Commerce Sales Analysis - SQLite Project

## 📋 Project Overview
This project demonstrates SQL skills through comprehensive analysis of an e-commerce database using SQLite. It covers data cleaning, exploratory analysis, business metrics calculation, and actionable insights generation.

**Skills Demonstrated:**
- Complex SQL queries (JOINs, CTEs, Window Functions, Subqueries)
- Data aggregation and grouping
- Time series analysis
- Customer segmentation
- Business metrics calculation
- Data cleaning and validation

**Tech Stack:** SQLite, VS Code

---

## 🚀 Setup Instructions

### Prerequisites
- VS Code installed
- SQLite extension for VS Code (`SQLite` by alexcvzz)

### Quick Start
1. Clone this repository
2. Open in VS Code
3. Run `schema.sql` to create tables
4. Run `sample_data.sql` to load data
5. Execute queries from `queries.sql`

---

## 🗄️ Database Schema

```sql
-- Create Customers table
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name TEXT NOT NULL,
    email TEXT,
    country TEXT,
    city TEXT,
    registration_date TEXT
);

-- Create Products table
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT,
    price REAL,
    cost REAL
);

-- Create Orders table
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date TEXT,
    total_amount REAL,
    status TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Create Order items table
CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    price_per_unit REAL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

---

## 📥 Sample Data

```sql
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
```

---

## 🔍 Analysis Questions & SQL Solutions

### 1. Revenue Analysis

**Question:** What is the total revenue, average order value, and number of orders by month?

```sql
SELECT 
    STRFTIME('%Y-%m', order_date) AS month,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE status = 'Completed'
GROUP BY STRFTIME('%Y-%m', order_date)
ORDER BY month;
```

**Results:**
```
month    | total_orders | total_revenue | avg_order_value
---------|--------------|---------------|----------------
2024-01  | 2            | 2799.97       | 1399.99
2024-02  | 2            | 1249.97       | 624.99
2024-03  | 1            | 929.97        | 929.97
2024-04  | 2            | 2149.96       | 1074.98
```

---

### 2. Top Performing Products

**Question:** Which products generate the most revenue and profit?

```sql
SELECT 
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS total_revenue,
    ROUND(SUM(oi.quantity * (oi.price_per_unit - p.cost)), 2) AS total_profit,
    ROUND(SUM(oi.quantity * (oi.price_per_unit - p.cost)) / 
          SUM(oi.quantity * oi.price_per_unit) * 100, 2) AS profit_margin_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_profit DESC;
```

---

### 3. Customer Segmentation (RFM Analysis)

**Question:** Segment customers by Recency, Frequency, and Monetary value.

```sql
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        JULIANDAY('now') - JULIANDAY(MAX(o.order_date)) AS recency_days,
        COUNT(o.order_id) AS frequency,
        SUM(o.total_amount) AS monetary_value
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
),
rfm_scores AS (
    SELECT 
        customer_id,
        customer_name,
        CAST(recency_days AS INTEGER) AS recency_days,
        frequency,
        ROUND(monetary_value, 2) AS monetary_value,
        NTILE(3) OVER (ORDER BY recency_days ASC) AS r_score,
        NTILE(3) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(3) OVER (ORDER BY monetary_value DESC) AS m_score
    FROM customer_metrics
)
SELECT 
    customer_name,
    recency_days,
    frequency,
    monetary_value,
    r_score,
    f_score,
    m_score,
    CASE 
        WHEN r_score = 3 AND f_score = 3 AND m_score = 3 THEN 'Champions'
        WHEN r_score >= 2 AND f_score >= 2 AND m_score >= 2 THEN 'Loyal Customers'
        WHEN r_score >= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Potential Loyalists'
        WHEN r_score <= 2 AND f_score >= 2 AND m_score >= 2 THEN 'At Risk'
        WHEN r_score <= 1 AND f_score <= 2 THEN 'Lost Customers'
        ELSE 'New Customers'
    END AS customer_segment
FROM rfm_scores
ORDER BY monetary_value DESC;
```

---

### 4. Product Category Performance

**Question:** Compare performance across product categories.

```sql
SELECT 
    p.category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.price_per_unit), 2) AS revenue,
    ROUND(AVG(oi.quantity * oi.price_per_unit), 2) AS avg_revenue_per_order,
    ROUND(SUM(oi.quantity * (oi.price_per_unit - p.cost)), 2) AS profit
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.category
ORDER BY profit DESC;
```

---

### 5. Customer Retention Analysis

**Question:** What percentage of customers make repeat purchases?

```sql
WITH customer_order_counts AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS order_count
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
SELECT 
    SUM(CASE WHEN order_count = 1 THEN 1 ELSE 0 END) AS one_time_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    COUNT(*) AS total_customers,
    ROUND(CAST(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS REAL) / 
          COUNT(*) * 100, 2) AS repeat_rate_pct
FROM customer_order_counts;
```

---

### 6. Sales Trend Analysis

**Question:** Calculate month-over-month growth rate.

```sql
WITH monthly_sales AS (
    SELECT 
        STRFTIME('%Y-%m', order_date) AS month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY STRFTIME('%Y-%m', order_date)
)
SELECT 
    month,
    ROUND(revenue, 2) AS current_month_revenue,
    LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
    ROUND(((revenue - LAG(revenue) OVER (ORDER BY month)) / 
           LAG(revenue) OVER (ORDER BY month) * 100), 2) AS growth_rate_pct
FROM monthly_sales
ORDER BY month;
```

---

### 7. Geographic Analysis

**Question:** Which cities generate the most revenue?

```sql
SELECT 
    c.city,
    c.country,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.total_amount), 2) AS total_revenue,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY c.city, c.country
ORDER BY total_revenue DESC;
```

---

### 8. Cancellation Rate Analysis

**Question:** What is the order cancellation rate?

```sql
SELECT 
    status,
    COUNT(*) AS order_count,
    ROUND(CAST(COUNT(*) AS REAL) * 100.0 / 
          (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY status
ORDER BY order_count DESC;
```

---

### 9. Customer Lifetime Value (CLV)

**Question:** Calculate average customer lifetime value.

```sql
SELECT 
    ROUND(AVG(customer_value), 2) AS avg_customer_lifetime_value,
    ROUND(MIN(customer_value), 2) AS min_clv,
    ROUND(MAX(customer_value), 2) AS max_clv
FROM (
    SELECT 
        customer_id,
        SUM(total_amount) AS customer_value
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
);
```

---

### 10. Product Affinity Analysis

**Question:** Which products are frequently bought together?

```sql
SELECT 
    p1.product_name AS product_1,
    p2.product_name AS product_2,
    COUNT(*) AS times_bought_together
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id = oi2.order_id 
    AND oi1.product_id < oi2.product_id
JOIN products p1 ON oi1.product_id = p1.product_id
JOIN products p2 ON oi2.product_id = p2.product_id
GROUP BY p1.product_name, p2.product_name
ORDER BY times_bought_together DESC
LIMIT 10;
```

---

## 📈 Key Insights & Business Recommendations

### Insights from Analysis:
1. **Revenue Trends:** Electronics category drives 70%+ of total revenue
2. **Customer Behavior:** Strong repeat purchase rate with key customers
3. **Product Performance:** Laptops and smartphones are top revenue generators
4. **Geographic Concentration:** Belgrade accounts for majority of orders
5. **Product Bundles:** Laptops frequently purchased with accessories

### Recommendations:
1. **Increase Customer Retention:** Implement loyalty program targeting "At Risk" segment
2. **Expand Product Mix:** Diversify beyond electronics to reduce category dependency
3. **Geographic Expansion:** Target underperforming cities with marketing campaigns
4. **Bundle Strategy:** Create package deals for frequently co-purchased items
5. **Reduce Cancellations:** Investigate reasons for cancelled orders

---

## 🛠️ Technical Skills Demonstrated

- ✅ Complex JOINs (INNER, LEFT)
- ✅ Window Functions (NTILE, LAG, OVER)
- ✅ CTEs (Common Table Expressions)
- ✅ Aggregate Functions (SUM, AVG, COUNT)
- ✅ SQLite Date Functions (STRFTIME, JULIANDAY)
- ✅ CASE Statements for segmentation
- ✅ Subqueries
- ✅ Type casting (CAST)
- ✅ Business metrics calculation (RFM, CLV, retention rate, growth rate)

---

## 📁 Project Structure

```
sql-ecommerce-analysis/
│
├── README.md                 # Project documentation
├── database/
│   └── ecommerce.db         # SQLite database file
├── schema.sql               # Table creation scripts
├── sample_data.sql          # Sample data inserts
├── queries.sql              # All analysis queries
└── results/
    └── insights.md          # Analysis findings
```

---

## 🎯 How to Run in VS Code

### Method 1: Using SQLite Extension
1. Install "SQLite" extension by alexcvzz
2. Open Command Palette (Ctrl+Shift+P)
3. Type "SQLite: Open Database" and select `ecommerce.db`
4. Right-click on SQL file → "Run Query"

### Method 2: Using Terminal
```bash
# Create database and run schema
sqlite3 database/ecommerce.db < schema.sql

# Load sample data
sqlite3 database/ecommerce.db < sample_data.sql

# Run specific query
sqlite3 database/ecommerce.db < queries.sql
```

### Method 3: Interactive Mode
```bash
sqlite3 database/ecommerce.db
```
Then paste and run queries directly.

---

## 📊 Sample Query Results

### Revenue by Month
| Month   | Orders | Revenue   | Avg Order Value |
|---------|--------|-----------|-----------------|
| 2024-01 | 2      | 2,799.97  | 1,399.99        |
| 2024-02 | 2      | 1,249.97  | 624.99          |
| 2024-03 | 1      | 929.97    | 929.97          |
| 2024-04 | 2      | 2,149.96  | 1,074.98        |

### Top Products by Profit
| Product              | Category    | Units Sold | Profit    |
|---------------------|-------------|------------|-----------|
| Laptop Dell XPS 13  | Electronics | 2          | 799.98    |
| iPhone 14 Pro       | Electronics | 1          | 349.99    |

---

## 🔗 Connect With Me

**GitHub:** [Your GitHub Profile]  
**LinkedIn:** [Your LinkedIn Profile]  
**Email:** [your.email@example.com]

---

## 📄 License

This project is open source and available under the MIT License.

---

## 🙏 Acknowledgments

This project was created as a portfolio piece to demonstrate SQL analytics skills for junior data analyst positions. The data is fictional and used for educational purposes only.