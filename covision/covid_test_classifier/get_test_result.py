"""
This is the main file that uses the best segmentation and classification models to predict the result of a covid test from its image.
TODO: Make this function accept arguments from console
"""
import base64

import cv2
import yaml
import argparse
import mlflow
import sys
import matplotlib.pyplot as plt

sys.path.append('../segmentation/src_seg')
sys.path.append('../classification/src_cla')

# Custom packages
from membrane_extractor import extract_corrected_membrane
from membrane_classifier import classify_membrane


def get_test_result(image_bytes, show_bool=False, save_bool=False, save_path=None):
    """
    Predict the result of a covid test from an image.
    """
    # Load required arguments
    args_seg_path = "../segmentation/config_seg.yaml"
    args_cla_path = "../classification/config_cla.yaml"
    with open(args_seg_path) as f:
        args_seg = argparse.Namespace(**yaml.safe_load(f))
    with open(args_cla_path) as f:
        args_cla = argparse.Namespace(**yaml.safe_load(f))

    # Load segmentation and classification models (those in production mode)

    # Segmentation
    model_seg_meta = "../segmentation/models_seg/mlruns/models/MaskRCNN_ResNet50_basic/version-1/meta.yaml"
    with open(model_seg_meta) as f:
        model_seg_dir = yaml.safe_load(f)['source']
    model_seg = mlflow.pytorch.load_model(model_uri=model_seg_dir, map_location='cpu')

    # Classification
    model_cla_meta = "../classification/models_cla/mlruns/models/ResNet18_Basic/version-1/meta.yaml"
    with open(model_cla_meta) as f:
        model_cla_dir = yaml.safe_load(f)['source']
    model_cla = mlflow.pytorch.load_model(model_uri=model_cla_dir, map_location='cpu')

    # Extract membrane
    # membrane, score_kit, score_membrane = extract_corrected_membrane(args_seg, image_bytes=image_bytes,model=model_seg)
    membrane, score_kit, score_membrane = extract_corrected_membrane(args_seg, image_path=image_bytes,model=model_seg)

    # Predict and display result
    result_str = classify_membrane(args_cla, membrane, model_cla)
    print(result_str)

    # Display and/or save result image
    if show_bool or save_bool:
        plt.imshow(membrane[:, :, ::-1])
        plt.title(f'{result_str} - scores: (k:{score_kit:.3f}, m:{score_membrane:.3f})')
        plt.axis('off')
        if save_bool:
            plt.savefig(save_path)
        if show_bool:
            plt.show()

    return result_str


if __name__ == '__main__':

    import os
    import argparse
    import logging

    logging.getLogger("mlflow").setLevel(logging.ERROR)

    # Predict result by reading image from command line
    # parser = argparse.ArgumentParser()
    # parser.add_argument('image_path', type=str, help='Path to the test image')
    # image_path = parser.parse_args().image_path

    # get_test_result(image_path, show_bool=True, save_bool=True)

    # Predict result for all images in datasets
    images_path = f"/Users/houkun/tmp/pic/"
    for filename in os.listdir(images_path):
        image_full_path = os.path.join(images_path, filename)
        # Read the image
        # image = cv2.imread(image_full_path)
        with open(image_full_path, "rb") as image_file:
            image = image_file.read()

        # Encode the image to base64
        image_base64 = (base64.b64encode(image))
                        # .decode('utf-8'))
        get_test_result(image_full_path)
        # get_test_result(image_base64, show_bool=True)
