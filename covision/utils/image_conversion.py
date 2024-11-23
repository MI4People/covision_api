import numpy as np
import cv2
import base64


def read_and_encode_image(image_path):
    """
    Read an image from a file and encode it as a base64 string
    """
    # Read the image using OpenCV
    image = cv2.imread(image_path)

    # Encode the image as a byte array
    success, encoded_image = cv2.imencode('.jpg', image)
    if not success:
        raise Exception("Could not encode image")

    # Convert the byte array to a base64 string
    encoded_image_str = base64.b64encode(encoded_image).decode('utf-8')
    return encoded_image_str


def decode_base64_image(encoded_image_str):
    """
    Decode an image from a base64 string
    """
    # Decode the base64 string to a byte array
    image_data = base64.b64decode(encoded_image_str)
    # Convert the byte array to a NumPy array
    nparr = np.frombuffer(image_data, np.uint8)
    # Decode the NumPy array to an image
    image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    return image


if __name__ == '__main__':
    img_path = "/Users/houkun/tmp/pic/image001.png"
    image = cv2.imread(img_path)
    height, width, channels = image.shape
    print(f"Image dimensions: {width}x{height} with {channels} channels")
    encoded_image_str = read_and_encode_image(img_path)
    image = decode_base64_image(encoded_image_str)
    # Process the image (example: get dimensions)
    height, width, channels = image.shape
    print(f"Image dimensions: {width}x{height} with {channels} channels")
