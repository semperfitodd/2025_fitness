import logging
import os
from decimal import Decimal

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")
aggregates_table = dynamodb.Table(os.environ["AGGREGATES_TABLE"])


def consolidate_aggregate(user, stream_records):
    """
    Consolidate all updates from the stream into a single JSON object for the user.
    """
    consolidated_data = {
        "exercise_data": {},
        "yearly_total": 0
    }

    for record in stream_records:
        new_image = record["dynamodb"]["NewImage"]
        exercise_volumes = new_image["exercise_volumes"]["M"]
        exercise_reps = new_image["exercise_reps"]["M"]

        for exercise, volume_data in exercise_volumes.items():
            volume = float(volume_data["N"])
            reps = int(exercise_reps[exercise]["N"])

            if exercise not in consolidated_data["exercise_data"]:
                consolidated_data["exercise_data"][exercise] = {
                    "total_volume": 0,
                    "total_reps": 0
                }

            consolidated_data["exercise_data"][exercise]["total_volume"] += volume
            consolidated_data["exercise_data"][exercise]["total_reps"] += reps
            consolidated_data["yearly_total"] += volume

    logger.info(
        f"Consolidated data for user: {user}, Exercises: {consolidated_data['exercise_data']}, "
        f"Yearly Total: {consolidated_data['yearly_total']}"
    )
    return consolidated_data


def update_aggregate(user, consolidated_data):
    """
    Write the consolidated data to a single row in the aggregates table.
    """
    try:
        logger.info(f"Updating single row for user: {user}")
        aggregates_table.put_item(
            Item={
                "user": user,
                "exercise_data": consolidated_data["exercise_data"],
                "yearly_total": Decimal(str(consolidated_data["yearly_total"]))
            }
        )
    except Exception as e:
        logger.error(f"Failed to update aggregate for user {user}: {e}", exc_info=True)


def lambda_handler(event, context):
    """
    Handle DynamoDB stream events and consolidate updates into a single row per user.
    """
    try:
        logger.info("Received DynamoDB stream event: %s", event)

        # Group records by user
        user_records = {}
        for record in event["Records"]:
            if record["eventName"] in ["INSERT", "MODIFY"]:
                user = record["dynamodb"]["NewImage"]["user"]["S"]
                if user not in user_records:
                    user_records[user] = []
                user_records[user].append(record)

        # Process each user and update their row
        for user, records in user_records.items():
            consolidated_data = consolidate_aggregate(user, records)
            update_aggregate(user, consolidated_data)

        return {
            "statusCode": 200,
            "body": "Aggregates updated successfully",
        }

    except Exception as e:
        logger.error("Error processing stream event: %s", e, exc_info=True)
        return {
            "statusCode": 500,
            "body": f"Error: {str(e)}",
        }
