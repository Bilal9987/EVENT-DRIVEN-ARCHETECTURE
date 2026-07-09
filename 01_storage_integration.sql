-- Connects Snowflake to your S3 bucket securely (no hardcoded AWS keys)

CREATE STORAGE INTEGRATION s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<account-id>:role/<your-role-name>'
  STORAGE_ALLOWED_LOCATIONS = ('s3://<your-bucket-name>/raw/');

-- Run this next and copy STORAGE_AWS_IAM_USER_ARN + STORAGE_AWS_EXTERNAL_ID
-- into your AWS IAM role's trust policy
DESC INTEGRATION s3_int;

-- Optional: pull just the two values you need, cleanly
SELECT "property", "property_value"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "property" IN ('STORAGE_AWS_IAM_USER_ARN', 'STORAGE_AWS_EXTERNAL_ID');

-- Once the AWS trust policy is updated, create the file format + stage
CREATE FILE FORMAT IF NOT EXISTS json_format
  TYPE = JSON
  STRIP_OUTER_ARRAY = TRUE;

CREATE STAGE IF NOT EXISTS s3_stage
  URL = 's3://<your-bucket-name>/raw/'
  STORAGE_INTEGRATION = s3_int
  FILE_FORMAT = json_format;

-- Test the connection — should list files from your S3 bucket
LIST @s3_stage;
