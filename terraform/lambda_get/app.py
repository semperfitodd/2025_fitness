import json
import logging
import os
from decimal import Decimal
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")
aggregates_table = dynamodb.Table(os.environ["AGGREGATES_TABLE"])


class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)


def query_aggregates_by_user(user_email):
    try:
        response = aggregates_table.query(
            KeyConditionExpression="#user = :user",
            ExpressionAttributeNames={"#user": "user"},
            ExpressionAttributeValues={":user": str(user_email)},
        )
        return response.get("Items", [])
    except Exception as e:
        logger.error(f"Error querying aggregates table for user: {user_email}: {e}")
        raise


def lambda_handler(event, context):
    try:
        logger.info(f"Received event: {json.dumps(event)}")

        # Parse the body of the request
        body = event.get("body")
        if not body:
            logger.error("Missing request body.")
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing request body."}),
            }

        # Ensure body is parsed as JSON
        if isinstance(body, str):
            try:
                body_json = json.loads(body)
            except json.JSONDecodeError:
                logger.error("Invalid JSON in request body.")
                return {
                    "statusCode": 400,
                    "body": json.dumps({"error": "Invalid JSON in request body."}),
                }
        else:
            body_json = body

        # Extract the user field
        user = body_json.get("user")
        if not user:
            logger.error("Missing 'user' field in request body.")
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing 'user' field in request body."}),
            }

        # Query DynamoDB for the user's data
        items = query_aggregates_by_user(user)
        if not items:
            logger.info(f"No data found for user: {user}")
            return {
                "statusCode": 404,
                "body": json.dumps({"error": f"No data found for user: {user}"}),
            }

        # Process the data
        exercise_data = {}
        total_lifted = 0

        for item in items:
            try:
                exercise_name = item["exercise_name"]
                total_volume = item.get("total_volume", 0)
                total_reps = item.get("total_reps", 0)

                if exercise_name == "total_lifted":
                    total_lifted = total_volume
                else:
                    exercise_data[exercise_name] = {
                        "total_volume": total_volume,
                        "total_reps": total_reps,
                    }
            except KeyError as e:
                logger.error(f"Missing key in item: {item}. Error: {e}")
            except TypeError as e:
                logger.error(f"Invalid item structure: {item}. Error: {e}")

        # Build the response
        response_body = {
            "user": user,
            "exercise_data": exercise_data,
            "total_lifted": total_lifted,
        }

        logger.info(f"Response body: {json.dumps(response_body, cls=DecimalEncoder)}")

        return {
            "statusCode": 200,
            "body": json.dumps(response_body, cls=DecimalEncoder),
        }

    except Exception as e:
        logger.error(f"Error in lambda_handler: {e}", exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
        }
