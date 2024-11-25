import json
import logging
import os

import boto3

from covision.covid_test_classifier.covid_test_result_predictor import CovidTestResultPredictor
from covision.utils.constants import PROJECT_ROOT
from covision.utils.image_conversion import read_and_encode_image

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s:%(lineno)d - %(levelname)s - %(message)s',
                    force=True)
logger = logging.getLogger(__name__)
# get the root logger
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
    logger.debug(f"received event: {event}")
    bypass_auth = os.environ.get("BYPASS_AUTH", "False").lower() == "true"
    try:
        body = json.loads(event["body"])
        base64_image = body['image_data']
        request_token = event.get("headers", {}).get("x-api-password", "")
        if bypass_auth:
            logger.warning("Bypassing auth")
        else:
            if is_authorized(request_token):
                logger.info("Authorized")
            else:
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
        logger.error(f"Failed to run the handler", exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error_message": "Internal Server Error: " + str(e)})
        }


if __name__ == '__main__':
    image_full_path = PROJECT_ROOT + "/covid_test_classifier/sample_images/image001.png"
    encode_image = read_and_encode_image(image_full_path)
    event = {
        'image_data': encode_image
    }

    logger.info(f"project root: {PROJECT_ROOT}")
    handler(event, None)
