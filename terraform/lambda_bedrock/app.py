import boto3
import json
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

def lambda_handler(event, context):
    bedrock_client = boto3.client('bedrock-runtime')

    messages = [
        {
            "role": "user",
            "content": (
                "You are a helpful assistant.\n\nMale, 45 years old, 6'3\" and 225 lbs, consistently working out for 29 years. "
                "Strong but with arthritis in knees and poor flexibility. Home gym equipment: dumbbells (up to 50 lbs), barbell, squat rack, pull-up bar, ring dips, "
                "assault bike, medicine ball, bench, 50-lb sandbag, and landmine accessories. "
                "Goal: Improve mobility, especially hips and shoulders, and achieve 15 million lbs total volume this year (~40,000 lbs/day). "
                "Preferences: Perform 2-4 exercises per workout in rounds (same exercises repeated each round). Each workout should include at least one barbell and one bodyweight exercise. "
                "Workout duration: ~45 minutes, including warmup and cooldown.\n\n"
                "Please provide a workout plan structured with the following sections:\n"
                "- Warmup: Include exercises to prepare for the main workout.\n"
                "- Main Workout: Specify exercises, sets, reps, and weights.\n"
                "- Cooldown: Include exercises to aid recovery and improve flexibility.\n"
                "- Total Volume Estimation: Calculate the approximate total weight lifted.\n"
                "- Notes: Provide additional helpful insights or tips for the workout."
            )
        }
    ]

    try:
        logger.info("Sending messages to Bedrock model")
        response = bedrock_client.invoke_model(
            modelId="anthropic.claude-3-5-sonnet-20240620-v1:0",
            contentType="application/json",
            accept="application/json",
            body=json.dumps({
                "messages": messages,
                "max_tokens": 1024,
                "temperature": 0.7,
                "anthropic_version": "bedrock-2023-05-31"
            })
        )

        response_body = json.loads(response['body'].read().decode('utf-8'))
        output = response_body.get('content', 'No response from the model')
        logger.info("Received response from model")

        return {
            'statusCode': 200,
            'body': json.dumps({
                'workout_plan': output
            })
        }
    except Exception as e:
        logger.error("Error occurred while invoking the model", exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }
