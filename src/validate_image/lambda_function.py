import boto3
import json
import base64
import os

from helper import generate_message
from mypy_boto_bedrock import BedrockRuntimeClient

bedrock_client: BedrockRuntimeClient = boto3.client(
    "bedrock-runtime", region_name="us-east-1"
)
sqs_client = boto3.client("sqs")
s3_client = boto3.client("s3")

success_queue_url = os.environ.get("SUCCESS_QUEUE")
failure_queue_url = os.environ.get("FAILURE_QUEUE")
failure_bucket = os.environ.get("FAIL_BUCKET")

with open("animal.jpeg", "rb") as image_file:
    content_image = base64.b64encode(image_file.read()).decode("utf8")


def lambda_handler(event, context):
    # headers = event['headers']['X-Forwarded-For']
    # client_ips = headers.split(',')

    key = "default_failure_file"
    response = {"key": "default_failure_response"}

    try:
        bucket = event["Records"][0]["s3"]["bucket"]["name"]
        key = event["Records"][0]["s3"]["object"]["key"]

        response = s3_client.get_object(Bucket=bucket, Key=key)
        file_obj = base64.b64encode(response["Body"].read()).decode("utf-8")

        message_mm = [
            {
                "role": "user",
                "content": [
                    {
                        "type": "image",
                        "source": {
                            "type": "base64",
                            "media_type": "image/jpeg",
                            "data": content_image,
                        },
                    },
                    {"type": "text", "text": "What is in this image?"},
                ],
            }
        ]

        response = generate_message(
            bedrock_client,
            model_id="anthropic.claude-3-sonnet-20240229-v1:0",
            messages=message_mm,
            max_tokens=512,
            temp=0.5,
            top_p=0.9,
        )

        print(json.dumps(response["content"][0], indent=3))

        sqs_client.send_message(QueueUrl="", MessageBody=response)

        statusCode = 200
        body = {
            "statusCode": statusCode,
            "message": "Success",
        }

        return {"statusCode": statusCode, "body": json.dumps(body)}

    except Exception as e:
        statusCode = 401
        body = {
            "statusCode": statusCode,
            "message": str(e),
        }

        s3_client.put_object(
            Bucket=failure_bucket, Key=f"{key}.txt", Body=json.dumps(response, indent=3)
        )
        return {"statusCode": statusCode, "body": json.dumps(body)}
