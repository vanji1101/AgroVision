# =============================================================
# routes/crop_disease.py
# FastAPI router that handles crop disease image uploads and
# returns prediction results with treatment suggestions.
#
# Endpoint: POST /api/crop-disease/predict
# =============================================================

import os
import uuid
from pathlib import Path

from fastapi import APIRouter, File, HTTPException, UploadFile, status
from fastapi.responses import JSONResponse

from services import prediction_service
from services.treatment_service import get_treatment_info
from utils.image_preprocessing import preprocess_image
from utils.logger import get_logger

logger = get_logger(__name__)

router = APIRouter(prefix="/api/crop-disease", tags=["Crop Disease Detection"])

# ---------------------------------------------------------------------------
# Directory where uploaded images are saved temporarily
# (Optional – useful for debugging; delete files after processing if privacy
#  is a concern.)
# ---------------------------------------------------------------------------
UPLOAD_DIR = Path(__file__).resolve().parent.parent / "uploads"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

# Allowed MIME types and file extensions
ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/jpg", "image/png"}
ALLOWED_EXTENSIONS    = {".jpg", ".jpeg", ".png"}

# Maximum upload size: 10 MB
MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024


# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

def _validate_file(file: UploadFile) -> None:
    """
    Validate that the uploaded file is an allowed image type.

    Raises:
        HTTPException 415 if the content-type or extension is not allowed.
    """
    ext = Path(file.filename or "").suffix.lower()
    
    # Check MIME type sent by the client. Allow octet-stream if extension is valid.
    if file.content_type not in ALLOWED_CONTENT_TYPES and file.content_type != "application/octet-stream":
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail=(
                f"Unsupported file type '{file.content_type}'. "
                "Only JPG, JPEG, and PNG images are accepted."
            ),
        )

    # Double-check using file extension
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail=(
                f"Invalid file extension '{ext}'. "
                "Allowed extensions: .jpg, .jpeg, .png"
            ),
        )


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@router.get(
    "/",
    summary="Crop Disease Module Info",
    description="Returns basic info about the crop disease prediction module.",
)
def crop_disease_info():
    """Quick status check for the crop disease module."""
    return {
        "module":      "Crop Disease Detection",
        "version":     "1.0.0",
        "model_ready": prediction_service.is_model_loaded(),
        "endpoint":    "POST /api/crop-disease/predict",
        "accepted_formats": ["jpg", "jpeg", "png"],
    }


@router.post(
    "/predict",
    summary="Predict Crop Disease",
    description=(
        "Upload a crop leaf image (JPG/JPEG/PNG, max 10 MB). "
        "Returns predicted crop name, disease, confidence score, "
        "treatment suggestion, and prevention tips."
    ),
)
async def predict_crop_disease(
    image: UploadFile = File(
        ...,
        description="Crop leaf image file (JPG, JPEG, or PNG)",
    ),
    language: str = "en"
):
    """
    **Workflow**
    1. Validate file type (MIME + extension).
    2. Read raw bytes and check size limit.
    3. Preprocess: resize → RGB → normalize → batch.
    4. Run model inference.
    5. Fetch treatment & prevention info.
    6. Return structured JSON response.
    """

    # ── Step 1: Validate file type ────────────────────────────────────────
    _validate_file(image)

    # ── Step 2: Read bytes ────────────────────────────────────────────────
    image_bytes = await image.read()

    if len(image_bytes) == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="The uploaded file is empty. Please upload a valid image.",
        )

    if len(image_bytes) > MAX_FILE_SIZE_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=(
                f"File size exceeds the 10 MB limit "
                f"({len(image_bytes) / (1024*1024):.1f} MB uploaded)."
            ),
        )

    # ── Step 3: Save to uploads/ (optional, for debugging) ───────────────
    safe_filename = f"{uuid.uuid4().hex}{Path(image.filename or 'upload').suffix.lower()}"
    save_path = UPLOAD_DIR / safe_filename
    try:
        with open(save_path, "wb") as f:
            f.write(image_bytes)
        logger.info(f"Image saved temporarily: {save_path}")
    except Exception as exc:
        # Non-fatal – log the warning but continue prediction
        logger.warning(f"Could not save uploaded image to disk: {exc}")

    # ── Step 4: Preprocess image ──────────────────────────────────────────
    # preprocess_image() raises HTTPException 400 for corrupt images
    img_array = preprocess_image(image_bytes)

    # ── Step 5: Run model prediction ─────────────────────────────────────
    try:
        result = prediction_service.predict(img_array)
    except RuntimeError as exc:
        # Model not loaded (missing .h5 file, TF not installed, etc.)
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(exc),
        )
    except Exception as exc:
        logger.error(f"Unexpected prediction error: {exc}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred during prediction. Check server logs.",
        )

    # ── Step 6: Generate Treatment & Prevention Advisory ───────────────────
    from services.llm_advisory_service import generate_disease_advisory
    advisory_result = generate_disease_advisory(
        crop=result["crop"],
        disease=result["disease"],
        confidence=result["confidence"],
        raw_label=result["raw_label"],
        language=language
    )

    logger.info(f"Final Crop Disease Prediction API Response:")
    logger.info(f"  Crop: {result['crop']}")
    logger.info(f"  Disease: {result['disease']}")
    logger.info(f"  Confidence: {result['confidence']}%")
    logger.info(f"  Advisory Source: {advisory_result['advisory_source']}")

    # ── Step 7: Build and return response ────────────────────────────────
    return JSONResponse(
        status_code=status.HTTP_200_OK,
        content={
            "status":          "success",
            "crop":            result["crop"],
            "disease":         result["disease"],
            "confidence":      result["confidence"],
            "treatment":       advisory_result["treatment"],
            "prevention":      advisory_result["prevention"],
            "advisory_source": advisory_result["advisory_source"],
        },
    )
