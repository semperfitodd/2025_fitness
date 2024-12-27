import logging
import os
from decimal import Decimal

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
aggregates_table = dynamodb.Table(os.environ['AGGREGATES_TABLE'])


def update_aggregate(exercise_name, volume, reps, total_lifted_update=False):
    try:
        logger.info(f"Updating aggregate for exercise: {exercise_name}, Volume: {volume}, Reps: {reps}")
        aggregates_table.update_item(
            Key={'exercise_name': exercise_name},
            UpdateExpression="ADD total_volume :v, total_reps :r",
            ExpressionAttributeValues={
                ':v': Decimal(str(volume)),
                ':r': Decimal(str(reps))
            }
        )

        if total_lifted_update:
            logger.info(f"Updating total_lifted with additional volume: {volume}")
            aggregates_table.update_item(
                Key={'exercise_name': 'total_lifted'},
                UpdateExpression="ADD total_volume :v",
                ExpressionAttributeValues={
                    ':v': Decimal(str(volume))
                }
            )

    except Exception as e:
        logger.error(f"Failed to update aggregate for {exercise_name}: {e}", exc_info=True)


def lambda_handler(event, context):
    try:
        logger.info("Received DynamoDB stream event: %s", event)
        for record in event['Records']:
            if record['eventName'] in ['INSERT', 'MODIFY']:
                new_image = record['dynamodb']['NewImage']
                exercise_volumes = new_image['exercise_volumes']['M']
                exercise_reps = new_image['exercise_reps']['M']

                for exercise, volume in exercise_volumes.items():
                    reps = int(exercise_reps[exercise])
                    volume = float(volume['N'])

                    update_aggregate(exercise, volume, reps)

                    update_aggregate('total_lifted', volume, 0, total_lifted_update=True)

        return {
            'statusCode': 200,
            'body': 'Aggregates updated successfully'
        }

    except Exception as e:
        logger.error("Error processing stream event: %s", e, exc_info=True)
        return {
            'statusCode': 500,
            'body': f'Error: {str(e)}'
        }
