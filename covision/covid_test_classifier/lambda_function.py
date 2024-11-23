import json
import logging
import os
import sys

import boto3

from covision.covid_test_classifier.covid_test_result_predictor import CovidTestResultPredictor
from covision.utils.constants import PROJECT_ROOT
from covision.utils.image_conversion import read_and_encode_image


logger = logging.getLogger()
logger.setLevel(logging.INFO)
predictor = CovidTestResultPredictor()


# def predict():
#     image_full_path = PROJECT_ROOT + "/covid_test_classifier/sample_images/image001.png"
#     with open(image_full_path, "rb") as image_file:
#         image = image_file.read()
#     # predictor.predict(image_full_path)
#
#     encode_image = read_and_encode_image(image_full_path)
#     predictor.predict_from_base64(encode_image)

def is_authorized(token):
    """
    Check if the request is authorized by comparing the token with the one in the config file
    """
    ssm_client = boto3.client('ssm')
    # Check for the password in headers
    parameter_name = os.environ.get('API_PASSWORD_NAME', "DEFAULT_API_PASSWORD_NAME")
    logging.info(f"Retrieving token from parameter store: {parameter_name}")
    response = ssm_client.get_parameter(Name=parameter_name, WithDecryption=True)
    expected_token = response['Parameter']['Value']
    return token == expected_token

def handler(event, context):
    print(f"received event: {event}")
    try:
        body = json.loads(event["body"])
        base64_image = body['image_data']
        request_token = event.get("headers", {}).get("x-api-password", "")
        if not is_authorized(request_token):
            return {
                "statusCode": 401,
                "body": json.dumps({"error_message": "Unauthorized"})
            }
        result = predictor.predict_from_base64(base64_image)
        return {
            "statusCode": 200,
            "body": json.dumps({"result": result})
        }
    except Exception as e:
        logger.error(f"Error: {e}")
        return {
                "statusCode": 500,
                "body": json.dumps({"error_message": "Internal Server Error: " + str(e)})
            }

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO, stream=sys.stdout, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', force=True)
    image_full_path = PROJECT_ROOT + "/covid_test_classifier/sample_images/image001.png"
    encode_image = read_and_encode_image(image_full_path)
    event = {
        'image_data': encode_image
    }

    logger.info(f"project root: {PROJECT_ROOT}")
    handler(event, None)