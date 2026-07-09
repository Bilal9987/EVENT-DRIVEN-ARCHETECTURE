-- FINAL LAYER: business-ready, aggregated data for reporting/analytics

CREATE TABLE IF NOT EXISTS final_data (
  city STRING,
  total_orders NUMBER,
  total_quantity_sold NUMBER,
  total_revenue FLOAT,
  updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO final_data (city, total_orders, total_quantity_sold, total_revenue)
SELECT
  city,
  COUNT(*) AS total_orders,
  SUM(quantity) AS total_quantity_sold,
  SUM(price * quantity) AS total_revenue
FROM stage_data
GROUP BY city;

-- Verify
SELECT * FROM final_data ORDER BY total_revenue DESC;

-- ============================================================
-- Extra analytics queries (run against stage_data or final_data)
-- ============================================================

-- Best-selling product
SELECT product, SUM(quantity) AS total_quantity_sold
FROM stage_data
GROUP BY product
ORDER BY total_quantity_sold DESC;

-- Average order value
SELECT ROUND(AVG(price * quantity), 2) AS avg_order_value
FROM stage_data;

-- Top spenders
SELECT name AS customer_name, SUM(price * quantity) AS total_spent
FROM stage_data
GROUP BY customer_name
ORDER BY total_spent DESC;
