import json
import logging
import os
from decimal import Decimal

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
aggregates_table = dynamodb.Table(os.environ['AGGREGATES_TABLE'])


class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)


def scan_aggregates():
    try:
        logger.info("Scanning aggregates table.")
        response = aggregates_table.scan()
        logger.info(f"Scan result: {response['Items']}")
        return response['Items']
    except Exception as e:
        logger.error(f"Error scanning aggregates table: {e}", exc_info=True)
        raise


def lambda_handler(event, context):
    try:
        logger.info(f"Received event: {event}")

        data = scan_aggregates()

        response_body = json.dumps(data, cls=DecimalEncoder)
        logger.info(f"Response body: {response_body}")

        return {
            'statusCode': 200,
            'body': response_body
        }

    except Exception as e:
        logger.error(f"Error in lambda_handler: {e}", exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
