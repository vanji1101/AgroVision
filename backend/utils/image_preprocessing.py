# =============================================================
# utils/image_preprocessing.py
# Utility functions to preprocess an uploaded image so it is
# ready for inference by a Keras / TensorFlow model.
# =============================================================

import io
import numpy as np
from PIL import Image, UnidentifiedImageError
from fastapi import HTTPException, status


# Target spatial dimensions expected by most MobileNet / EfficientNet backbones
TARGET_SIZE: tuple[int, int] = (224, 224)


def load_and_validate_image(image_bytes: bytes) -> Image.Image:
    """
    Load raw bytes into a PIL Image and verify it is a genuine image.

    Args:
        image_bytes: Raw bytes read from the uploaded file.

    Returns:
        A PIL Image object in RGB mode.

    Raises:
        HTTPException 400 if the bytes do not represent a valid image.
    """
    try:
        # Open from in-memory buffer (no disk I/O needed)
        image = Image.open(io.BytesIO(image_bytes))

        # Force-load the image data to catch corrupt / truncated files early
        image.verify()

        # Re-open after verify() (verify() exhausts the file pointer)
        image = Image.open(io.BytesIO(image_bytes))
    except (UnidentifiedImageError, Exception):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Uploaded file is not a valid or supported image. "
                   "Please upload a JPG, JPEG, or PNG file.",
        )

    return image


def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """
    Full preprocessing pipeline for a single crop-leaf image.

    Steps
    -----
    1. Decode bytes → PIL Image
    2. Convert to RGB  (handles grayscale / RGBA / palette mode images)
    3. Resize to 224 × 224
    4. Convert to float32 NumPy array
    5. Normalize pixel values to [0, 1]
    6. Expand dims → shape (1, 224, 224, 3)  ready for model.predict()

    Args:
        image_bytes: Raw bytes of the uploaded image file.

    Returns:
        NumPy array with shape (1, 224, 224, 3), dtype float32.
    """
    # Step 1 – Load & validate
    image = load_and_validate_image(image_bytes)

    # Step 2 – Ensure RGB (model was trained on 3-channel images)
    image = image.convert("RGB")

    # Step 3 – Resize to model input size
    try:
        resample_filter = Image.Resampling.LANCZOS
    except AttributeError:
        resample_filter = getattr(Image, "LANCZOS")
    image = image.resize(TARGET_SIZE, resample=resample_filter)

    # Step 4 – Convert PIL Image → NumPy array  [224, 224, 3]
    img_array = np.array(image, dtype=np.float32)

    # Step 5 – Normalize: scale pixel values from [0, 255] → [-1.0, 1.0]
    # MobileNetV2 expects input in [-1, 1]
    img_array = (img_array / 127.5) - 1.0

    # Step 6 – Add batch dimension: [224, 224, 3] → [1, 224, 224, 3]
    img_array = np.expand_dims(img_array, axis=0)

    return img_array
