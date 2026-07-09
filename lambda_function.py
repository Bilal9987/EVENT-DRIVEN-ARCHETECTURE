import json
import boto3
import random
import uuid
from datetime import datetime, timezone

s3 = boto3.client("s3")

BUCKET = "your-bucket-name"  # TODO: replace with your S3 bucket name

# Sample values used to generate fake records
NAMES = ["Ali", "Ahmed", "Sara", "Fatima", "Bilal", "Hassan", "Ayesha", "Usman", "Zainab", "Omar"]
CITIES = ["Islamabad", "Lahore", "Karachi", "Peshawar", "Multan", "Quetta"]
PRODUCTS = ["Laptop", "Mobile", "Headphones", "Keyboard", "Monitor", "Charger"]


def generate_fake_record():
    return {
        "id": str(uuid.uuid4()),
        "name": random.choice(NAMES),
        "city": random.choice(CITIES),
        "product": random.choice(PRODUCTS),
        "price": round(random.uniform(500, 50000), 2),
        "quantity": random.randint(1, 10),
        "order_date": datetime.now(timezone.utc).isoformat(),
    }


def lambda_handler(event, context):
    try:
        num_records = 50
        records = [generate_fake_record() for _ in range(num_records)]

        now = datetime.now(timezone.utc)
        key = f"raw/{now:%Y/%m/%d}/fake_data_{now:%H%M%S}.json"

        s3.put_object(
            Bucket=BUCKET,
            Key=key,
            Body=json.dumps(records),
            ContentType="application/json",
        )

        print(f"Success: {num_records} records uploaded to s3://{BUCKET}/{key}")
        return {
            "statusCode": 200,
            "body": json.dumps({"status": "ok", "records_generated": num_records, "s3_key": key}),
        }

    except Exception as e:
        print(f"ERROR: {e}")
        raise
