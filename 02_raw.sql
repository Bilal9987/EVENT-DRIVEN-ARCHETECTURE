-- RAW LAYER: stores data exactly as it arrives, no transformation

CREATE DATABASE IF NOT EXISTS EVENT_PIPELINE;
CREATE SCHEMA IF NOT EXISTS EVENT_PIPELINE.RAW;

USE DATABASE EVENT_PIPELINE;
USE SCHEMA RAW;

CREATE TABLE IF NOT EXISTS raw_data (
  file_name STRING,
  load_time TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  raw_json VARIANT
);

-- Load new files from S3 into RAW
COPY INTO raw_data (file_name, raw_json)
FROM (SELECT METADATA$FILENAME, $1 FROM @s3_stage)
FILE_FORMAT = json_format;

-- Verify
SELECT * FROM raw_data ORDER BY load_time DESC;
