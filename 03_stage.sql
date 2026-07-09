-- STAGE LAYER: cleaned, typed data extracted from RAW's JSON column

CREATE TABLE IF NOT EXISTS stage_data (
  record_id STRING,
  name STRING,
  city STRING,
  product STRING,
  price FLOAT,
  quantity NUMBER,
  order_date TIMESTAMP_NTZ,
  loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO stage_data (record_id, name, city, product, price, quantity, order_date)
SELECT
  raw_json:id::STRING,
  raw_json:name::STRING,
  raw_json:city::STRING,
  raw_json:product::STRING,
  raw_json:price::FLOAT,
  raw_json:quantity::NUMBER,
  raw_json:order_date::TIMESTAMP_NTZ
FROM raw_data;

-- Verify
SELECT * FROM stage_data ORDER BY loaded_at DESC;
