import json
import logging
import os
import re
from decimal import Decimal
from datetime import datetime, timedelta

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
raw_data_table = dynamodb.Table(os.environ['RAW_DATA_TABLE'])
aggregates_table = dynamodb.Table(os.environ['AGGREGATES_TABLE'])


class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)


def validate_user_email(email):
    """Validate user email format"""
    if not email or not isinstance(email, str):
        raise ValueError("User email is required and must be a string")
    
    email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if not re.match(email_pattern, email):
        raise ValueError("Invalid email format")
    
    if len(email) > 254:  # RFC 5321 limit
        raise ValueError("Email address too long")
    
    return email.strip().lower()


def validate_date(date_str):
    """Validate date format and range"""
    if not date_str or not isinstance(date_str, str):
        raise ValueError("Date is required and must be a string")
    
    try:
        date_obj = datetime.strptime(date_str, '%Y-%m-%d')
    except ValueError:
        raise ValueError("Invalid date format. Use YYYY-MM-DD")
    
    today = datetime.now().date()
    one_year_ago = today - timedelta(days=365)
    
    if date_obj.date() > today:
        raise ValueError("Date cannot be in the future")
    
    if date_obj.date() < one_year_ago:
        raise ValueError("Date cannot be more than 1 year ago")
    
    return date_str


def validate_exercises(exercises):
    """Validate exercises array"""
    if not isinstance(exercises, list):
        raise ValueError("Exercises must be an array")
    
    if len(exercises) == 0:
        raise ValueError("At least one exercise is required")
    
    if len(exercises) > 50:
        raise ValueError("Maximum 50 exercises per workout")
    
    validated_exercises = []
    for i, exercise in enumerate(exercises):
        if not isinstance(exercise, dict):
            raise ValueError(f"Exercise {i+1} must be an object")
        
        name = exercise.get('name')
        if not name or not isinstance(name, str) or len(name.strip()) == 0:
            raise ValueError(f"Exercise {i+1} must have a valid name")
        
        if len(name) > 100:
            raise ValueError(f"Exercise {i+1} name too long (max 100 characters)")
        
        weight = exercise.get('weight')
        if not isinstance(weight, (int, float)) or weight < 0:
            raise ValueError(f"Exercise {i+1} weight must be a positive number")
        
        if weight > 10000:
            raise ValueError(f"Exercise {i+1} weight seems unrealistic (max 10,000 lbs)")
        
        reps = exercise.get('reps')
        if not isinstance(reps, int) or reps < 0:
            raise ValueError(f"Exercise {i+1} reps must be a positive integer")
        
        if reps > 1000:
            raise ValueError(f"Exercise {i+1} reps seem unrealistic (max 1,000)")
        
        validated_exercises.append({
            'name': name.strip(),
            'weight': Decimal(str(weight)),
            'reps': int(reps)
        })
    
    return validated_exercises


def calculate_volume(exercises):
    logger.info("Calculating volumes and reps for exercises.")
    total_volume = Decimal('0')
    exercise_volumes = {}
    exercise_reps = {}

    for exercise in exercises:
        name = exercise['name'].lower()
        weight = exercise['weight']  # Already Decimal from validation
        reps = int(exercise['reps'])

        volume = weight * Decimal(str(reps))
        total_volume += volume

        exercise_volumes[name] = exercise_volumes.get(name, Decimal('0')) + volume
        exercise_reps[name] = exercise_reps.get(name, 0) + reps

    logger.info(f"Total volume: {total_volume}, Exercise volumes: {exercise_volumes}, Exercise reps: {exercise_reps}")
    return total_volume, exercise_volumes, exercise_reps


def update_aggregates(user, exercise_volumes, exercise_reps, total_volume):
    logger.info("Updating aggregates table.")
    for exercise_name, volume in exercise_volumes.items():
        reps = exercise_reps[exercise_name]
        logger.info(f"Updating aggregate for user: {user}, exercise: {exercise_name}, Volume: {volume}, Reps: {reps}")
        aggregates_table.update_item(
            Key={'user': user, 'exercise_name': exercise_name},
            UpdateExpression="ADD total_volume :v, total_reps :r",
            ExpressionAttributeValues={
                ':v': volume,  # Already Decimal
                ':r': Decimal(str(reps))
            }
        )

    logger.info(f"Updating total_lifted for user: {user} with volume: {total_volume}")
    aggregates_table.update_item(
        Key={'user': user, 'exercise_name': 'total_lifted'},
        UpdateExpression="ADD total_volume :v",
        ExpressionAttributeValues={
            ':v': total_volume  # Already Decimal
        }
    )


def lambda_handler(event, context):
    try:
        logger.info("Received event: %s", event)
        body = json.loads(event['body'])

        # Validate input data
        user = validate_user_email(body.get('user'))
        date = validate_date(body.get('date'))
        exercises = validate_exercises(body.get('exercises', []))

        logger.info("Processing exercises for user: %s, date: %s", user, date)

        # Fetch existing data for the specific user and date
        existing_data = raw_data_table.get_item(Key={'user': user, 'date': date}).get('Item')

        if existing_data:
            logger.info("Found existing data for the same user and date. Adjusting aggregates.")
            previous_exercise_volumes = existing_data['exercise_volumes']
            previous_exercise_reps = existing_data['exercise_reps']
            previous_total_volume = existing_data['total_volume']

            # Subtract previous contributions from aggregates
            for exercise_name, previous_volume in previous_exercise_volumes.items():
                previous_reps = previous_exercise_reps[exercise_name]
                aggregates_table.update_item(
                    Key={'user': user, 'exercise_name': exercise_name},
                    UpdateExpression="ADD total_volume :v, total_reps :r",
                    ExpressionAttributeValues={
                        ':v': -previous_volume,  # Convert to negative Decimal
                        ':r': Decimal(str(-int(previous_reps)))
                    }
                )

            aggregates_table.update_item(
                Key={'user': user, 'exercise_name': 'total_lifted'},
                UpdateExpression="ADD total_volume :v",
                ExpressionAttributeValues={
                    ':v': -previous_total_volume  # Convert to negative Decimal
                }
            )

        # Calculate new contributions
        total_volume, exercise_volumes, exercise_reps = calculate_volume(exercises)

        # Write raw data for the specific date
        raw_data_item = {
            'user': user,
            'date': date,
            'exercise': 'DAILY_SUMMARY',
            'raw_exercises': exercises,
            'total_volume': total_volume,  # Already Decimal
            'exercise_volumes': exercise_volumes,  # Already Decimal values
            'exercise_reps': exercise_reps
        }
        raw_data_table.put_item(Item=raw_data_item)
        logger.info("Successfully wrote raw data to table.")

        # Update aggregates with new contributions
        update_aggregates(user, exercise_volumes, exercise_reps, total_volume)

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Workout recorded successfully',
                'user': user,
                'date': date,
                'total_volume': float(total_volume),
                'exercise_volumes': {k: float(v) for k, v in exercise_volumes.items()},
                'exercise_reps': exercise_reps
            }, cls=DecimalEncoder)
        }

    except ValueError as e:
        logger.warning("Validation error: %s", e)
        return {
            'statusCode': 400,
            'body': json.dumps({'error': str(e)})
        }
    except Exception as e:
        logger.error("Error processing event: %s", e, exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'})
        }
