import json
import logging
import os

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

secrets_manager = boto3.client("secretsmanager")


def get_secret(secret_name):
    try:
        response = secrets_manager.get_secret_value(SecretId=secret_name)
        secret = json.loads(response["SecretString"])
        return secret["API_KEY"]
    except Exception as e:
        logger.error(f"Error fetching secret: {e}")
        raise ValueError("Failed to retrieve API key secret")


def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))

    try:
        secret_name = os.environ.get("API_KEY_SECRET")
        if not secret_name:
            logger.error("Missing environment variable: API_KEY_SECRET")
            raise ValueError("API_KEY_SECRET environment variable is not set")

        api_key_secret = get_secret(secret_name)

        headers = event.get("headers", {})
        client_key = headers.get("x-api-key")

        if client_key and client_key.strip() == api_key_secret.strip():
            logger.info("Authorization succeeded")
            return {"isAuthorized": True}
        else:
            logger.info("Authorization failed")
            return {"isAuthorized": False}
    except Exception as e:
        logger.exception("Unexpected error in authorizer")
        return {"isAuthorized": False}
