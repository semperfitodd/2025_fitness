import json
import logging
import os
from decimal import Decimal

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
raw_data_table = dynamodb.Table(os.environ['RAW_DATA_TABLE'])
aggregates_table = dynamodb.Table(os.environ['AGGREGATES_TABLE'])


def calculate_volume(exercises):
    logger.info("Calculating volumes and reps for exercises.")
    total_volume = 0
    exercise_volumes = {}
    exercise_reps = {}

    for exercise in exercises:
        name = exercise['name'].lower()
        weight = float(exercise['weight'])
        reps = int(exercise['reps'])

        volume = weight * reps
        total_volume += volume

        exercise_volumes[name] = exercise_volumes.get(name, 0) + volume
        exercise_reps[name] = exercise_reps.get(name, 0) + reps

    logger.info(f"Total volume: {total_volume}, Exercise volumes: {exercise_volumes}, Exercise reps: {exercise_reps}")
    return total_volume, exercise_volumes, exercise_reps


def update_aggregates(exercise_volumes, exercise_reps, total_volume):
    logger.info("Updating aggregates table.")
    for exercise_name, volume in exercise_volumes.items():
        reps = exercise_reps[exercise_name]
        logger.info(f"Updating aggregate for exercise: {exercise_name}, Volume: {volume}, Reps: {reps}")
        aggregates_table.update_item(
            Key={'exercise_name': exercise_name},
            UpdateExpression="ADD total_volume :v, total_reps :r",
            ExpressionAttributeValues={
                ':v': Decimal(str(volume)),
                ':r': Decimal(str(reps))
            }
        )

    logger.info(f"Updating total_lifted with volume: {total_volume}")
    aggregates_table.update_item(
        Key={'exercise_name': 'total_lifted'},
        UpdateExpression="ADD total_volume :v",
        ExpressionAttributeValues={
            ':v': Decimal(str(total_volume))
        }
    )


def lambda_handler(event, context):
    try:
        logger.info("Received event: %s", event)
        body = json.loads(event['body'])

        date = body.get('date')
        exercises = body['exercises']

        logger.info("Processing exercises for date: %s", date)

        existing_data = raw_data_table.get_item(Key={'date': date, 'exercise': 'DAILY_SUMMARY'})
        if 'Item' in existing_data:
            logger.info("Found existing data for the same date. Adjusting aggregates.")
            previous_exercise_volumes = existing_data['Item']['exercise_volumes']
            previous_exercise_reps = existing_data['Item']['exercise_reps']

            for exercise_name, previous_volume in previous_exercise_volumes.items():
                previous_reps = previous_exercise_reps[exercise_name]
                aggregates_table.update_item(
                    Key={'exercise_name': exercise_name},
                    UpdateExpression="ADD total_volume :v, total_reps :r",
                    ExpressionAttributeValues={
                        ':v': Decimal(str(-float(previous_volume))),
                        ':r': Decimal(str(-int(previous_reps)))
                    }
                )

            previous_total_volume = existing_data['Item']['total_volume']
            aggregates_table.update_item(
                Key={'exercise_name': 'total_lifted'},
                UpdateExpression="ADD total_volume :v",
                ExpressionAttributeValues={
                    ':v': Decimal(str(-float(previous_total_volume)))
                }
            )

        total_volume, exercise_volumes, exercise_reps = calculate_volume(exercises)

        raw_data_item = {
            'date': date,
            'exercise': 'DAILY_SUMMARY',
            'raw_exercises': exercises,
            'total_volume': Decimal(str(total_volume)),
            'exercise_volumes': {k: Decimal(str(v)) for k, v in exercise_volumes.items()},
            'exercise_reps': exercise_reps
        }
        raw_data_table.put_item(Item=raw_data_item)
        logger.info("Successfully wrote raw data to table.")

        update_aggregates(exercise_volumes, exercise_reps, total_volume)

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Workout recorded successfully',
                'date': date,
                'total_volume': float(total_volume),
                'exercise_volumes': {k: float(v) for k, v in exercise_volumes.items()},
                'exercise_reps': exercise_reps
            })
        }

    except Exception as e:
        logger.error("Error processing event: %s", e, exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }