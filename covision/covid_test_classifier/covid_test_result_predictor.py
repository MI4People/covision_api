import argparse
import logging
import sys

import mlflow
import yaml

from covision.covid_test_classifier.membrane_classifier import classify_membrane
from covision.covid_test_classifier.membrane_extractor import extract_corrected_membrane
from covision.covid_test_classifier.prediction_result import PredictionResult
from covision.utils.constants import PROJECT_ROOT
from covision.utils.image_conversion import decode_base64_image, read_and_encode_image


sys.path.append(PROJECT_ROOT + '/segmentation/src_seg')
sys.path.append(PROJECT_ROOT + '/classification/src_cla')


class CovidTestResultPredictor:
    def __init__(self):
        self.args_seg = self.load_config(PROJECT_ROOT + "/segmentation/config_seg.yaml")
        self.args_cla = self.load_config(PROJECT_ROOT + "/classification/config_cla.yaml")
        self.model_seg = mlflow.pytorch.load_model(model_uri=PROJECT_ROOT + "/covid_test_classifier/models/seg_model/", map_location='cpu')
        self.model_cla = mlflow.pytorch.load_model(model_uri=PROJECT_ROOT + "/covid_test_classifier/models/cla_model/", map_location='cpu')
        logging.getLogger("mlflow").setLevel(logging.ERROR)


    def load_config(self, config_path):
        with open(config_path) as f:
            return argparse.Namespace(**yaml.safe_load(f))

    def predict(self, image_bytes) -> PredictionResult:

        membrane, score_kit, score_membrane = extract_corrected_membrane(self.args_seg, image=image_bytes,
                                                                         model=self.model_seg)
        return classify_membrane(self.args_cla, membrane, self.model_cla).value

    def predict_from_base64(self, image_base64) -> PredictionResult:
        image_bytes = decode_base64_image(image_base64)
        result = self.predict(image_bytes)
        logging.info(f"Predicted result: {result}")
        return result



if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    predictor = CovidTestResultPredictor()
    image_full_path = "sample_images/image001.png"
    with open(image_full_path, "rb") as image_file:
        image = image_file.read()
    # predictor.predict(image_full_path)


    encode_image = read_and_encode_image(image_full_path)
    predictor.predict_from_base64(encode_image)
