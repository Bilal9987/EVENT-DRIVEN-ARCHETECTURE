<img width="1757" height="1202" alt="architecture_diagram" src="https://github.com/user-attachments/assets/786631a7-d79b-43ce-9555-53874ab42a82" />

Event-Driven Data Pipeline (Lambda → S3 → Snowflake)

This is a small data engineering project I built to understand how event-driven pipelines actually work in practice  not just in theory. It takes data, drops it into a data lake, and pushes it through a proper RAW → STAGE → FINAL flow inside Snowflake.

What this project actually does

In simple words:


An AWS Lambda function generates/extracts data (currently generating fake sales data name, city, product, price, quantity).
That data gets dumped as a JSON file into an S3 bucket, organized by date so nothing gets messy.
Snowflake connects to that S3 bucket (securely, no hardcoded keys — using a Storage Integration + IAM role) and pulls the data in.
Inside Snowflake, the data moves through three stages:

RAW = exactly what came in, untouched. This is the safety net  if anything breaks downstream, I can always rebuild from here.
STAGE =  the JSON gets broken into clean, proper columns (name, city, product, price, quantity).
FINAL = the data gets summarized into something actually useful, like total revenue per city.

That's it. Simple pipeline, but it follows the same pattern real companies use for their data warehouses.

Why I built it this way

I could've just dumped everything into one table and called it a day, but that's not how real pipelines work. Keeping RAW separate means I never lose the original data even if my transformation logic has a bug. STAGE keeps things clean without me committing to business logic too early. FINAL is what I'd actually hand off to someone asking "which city sells the most?"

Project structure

├── README.md
├── lambda/
│   └── lambda_function.py     → the function that generates data & pushes to S3
├── sql/
│   ├── 01_storage_integration.sql   → connects Snowflake to S3
│   ├── 02_raw.sql                   → RAW table + load
│   ├── 03_stage.sql                 → STAGE table + cleaning
│   └── 04_final.sql                 → FINAL table + aggregation
└── docs/
    └── ARCHITECTURE.md         → the deeper technical write-up, if you want details

How to actually run this

1. Deploy the Lambda

Update the BUCKET variable in lambda_function.py with your own bucket name, then:

bashzip function.zip lambda_function.py

aws lambda create-function 
  function-name fake-data-generator 
  runtime python3.11 
  role arn:aws:iam::<account-id>:role/lambda-s3-writer 
  handler lambda_function.lambda_handler 
  zip-file fileb://function.zip 
  timeout 30 
  memory-size 128

2. Create your S3 bucket

bashaws s3 mb s3://your-bucket-name --region us-east-1

3. Run the SQL files in Snowflake, in this order

01_storage_integration.sql → 02_raw.sql → 03_stage.sql → 04_final.sql

The first script is the tricky one  it involves setting up trust between AWS and Snowflake. I wrote out every single step (with the exact error I ran into) in docs/ARCHITECTURE.md, so if you get stuck there, that's the file to check.

A few honest notes


Right now the "extraction" is fake data this was built as a learning project, not a production pipeline connected to a real business source. Swapping in a real API or database is straightforward though; only the Lambda code needs to change.
Loading from RAW → STAGE → FINAL is still manual (COPY INTO + INSERT). Next thing I want to add is Snowpipe so new files get picked up automatically, and Tasks so STAGE/FINAL refresh themselves.
No secrets or AWS keys are committed here. If you're cloning this, plug in your own bucket name and role ARN before running anything.
