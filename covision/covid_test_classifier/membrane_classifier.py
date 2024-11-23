"""
TODO:
"""
import logging

import torch

from covision.classification.src_cla.transformations_cla import PreprocessMembraneZones
from covision.classification.src_cla.utils_cla.miscellaneous import crop_zones
from covision.covid_test_classifier.prediction_result import PredictionResult


def classify_membrane(args, membrane, model)-> PredictionResult:
    """
    Takes a raw image of a membrane and log whether it corresponds to a positive, negative or invalid LFA test.
    """

    if model.training:
        model.eval()

    # Crop relevant zones
    zones = crop_zones(args, membrane)
    # Apply transformation
    transformation = PreprocessMembraneZones()
    zones = transformation(zones)
    # Run inference
    with torch.no_grad():
        y_pred = model(zones)
    # Binarize prediction
    binary_pred = (y_pred > 0.5).squeeze().to(int).tolist()
    # To string
    pred_str = str(binary_pred[0]) + str(binary_pred[1])
    # Map to diagnosis
    result = args.diagnosis_map[pred_str]
    if result == 1:
        result = PredictionResult.POSITIVE
    elif result == 0:
        result = PredictionResult.NEGATIVE
    elif result == 99:
        result = PredictionResult.INVALID
    logging.info(f"Result: {result}, prediction: {pred_str}")
    return result
