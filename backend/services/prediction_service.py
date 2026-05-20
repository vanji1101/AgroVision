# =============================================================
# services/prediction_service.py
# Loads the trained Keras model + class index map once at
# startup, then exposes a single predict() function used by
# the route handler.
# =============================================================

import json
import os
from pathlib import Path

import numpy as np
from utils.logger import get_logger

logger = get_logger(__name__)

# ---------------------------------------------------------------------------
# Paths (relative to the backend/ directory where uvicorn is launched)
# ---------------------------------------------------------------------------
BASE_DIR   = Path(__file__).resolve().parent.parent          # …/backend/
MODEL_PATH = BASE_DIR / "models" / "best_model.keras"
INDEX_PATH = BASE_DIR / "models" / "class_indices.json"


# ---------------------------------------------------------------------------
# Module-level singletons – loaded once, reused for every request
# ---------------------------------------------------------------------------
_model        = None   # Keras model  (None = not yet loaded / missing)
_class_map    = None   # {str(index): "Crop___Disease_Label"}
_load_error   = None   # Human-readable error message if loading failed


def _load_model_and_classes() -> None:
    """
    Attempt to load the Keras model and class-index JSON.
    Sets module globals _model, _class_map, or _load_error.
    Called once during application startup.
    """
    global _model, _class_map, _load_error

    # ── 1. Check that both required files exist ──────────────────────────
    if not MODEL_PATH.exists():
        _load_error = (
            f"Model file not found at '{MODEL_PATH}'. "
            "Please place your trained 'crop_disease_model.h5' in the "
            "backend/models/ directory and restart the server."
        )
        logger.error(_load_error)
        return

    if not INDEX_PATH.exists():
        _load_error = (
            f"Class-index file not found at '{INDEX_PATH}'. "
            "Please ensure 'class_indices.json' exists in backend/models/."
        )
        logger.error(_load_error)
        return

    # ── 2. Load class indices ─────────────────────────────────────────────
    try:
        with open(INDEX_PATH, "r", encoding="utf-8") as f:
            _class_map = json.load(f)        # {"0": "Apple___Apple_scab", …}
        logger.info(f"Loaded {len(_class_map)} class labels from class_indices.json")
    except Exception as exc:
        _load_error = f"Failed to parse class_indices.json: {exc}"
        logger.error(_load_error)
        return

    # ── 3. Load Keras model (TensorFlow import is lazy to keep startup fast
    #       on machines without a GPU) ──────────────────────────────────────
    try:
        # Import here so the rest of the app works even without TensorFlow
        import tensorflow as tf  # type: ignore  # noqa: F401 – side-effect import
        import keras

        _model = keras.models.load_model(str(MODEL_PATH))
        logger.info(f"Crop disease model loaded successfully from '{MODEL_PATH}'")
    except Exception as exc:
        _load_error = f"Failed to load Keras model: {exc}"
        logger.error(_load_error)
        _model = None


def initialize() -> None:
    """Public entry point called from main.py startup event."""
    _load_model_and_classes()


# ---------------------------------------------------------------------------
# Prediction helper
# ---------------------------------------------------------------------------

def _parse_label(raw_label: str) -> tuple[str, str]:
    """
    Split a PlantVillage-style label like 'Tomato___Early_blight' into
    (crop_name, disease_name).

    Returns:
        ("Tomato", "Early Blight")  – underscores replaced with spaces,
        title-cased for display.
    """
    if raw_label.startswith("pepper_bell_"):
        crop = "Pepper Bell"
        disease_raw = raw_label[len("pepper_bell_"):]
    else:
        parts = raw_label.split("_", 1)
        crop = parts[0].replace("_", " ").strip().title()
        disease_raw = parts[1] if len(parts) > 1 else "Unknown"
        
    disease = disease_raw.replace("_", " ").strip().title()
    return crop, disease


def predict(img_array: np.ndarray) -> dict:
    """
    Run inference on a pre-processed image array.

    Args:
        img_array: NumPy array of shape (1, 224, 224, 3), float32, values in [0, 1].

    Returns:
        dict with keys: raw_label, crop, disease, confidence

    Raises:
        RuntimeError if the model is not loaded.
    """
    # Guard: model or class map not available
    if _model is None or _class_map is None:
        raise RuntimeError(
            _load_error or "Model or class map is not loaded. Check server logs for details."
        )

    # ── Run inference ────────────────────────────────────────────────────
    predictions = _model.predict(img_array, verbose=0)   # shape: (1, num_classes)
    pred_index  = int(np.argmax(predictions[0]))
    confidence  = float(np.max(predictions[0])) * 100    # percentage

    # ── Map index → label ────────────────────────────────────────────────
    raw_label = _class_map.get(str(pred_index), f"Unknown_Class_{pred_index}")
    crop, disease = _parse_label(raw_label)

    logger.info(
        f"Prediction → class={pred_index} | label={raw_label} | "
        f"confidence={confidence:.2f}%"
    )

    return {
        "raw_label": raw_label,
        "crop":      crop,
        "disease":   disease,
        "confidence": round(confidence, 2),
    }


def is_model_loaded() -> bool:
    """Returns True if the model loaded successfully."""
    return _model is not None


def get_load_error() -> str | None:
    """Returns the human-readable load error, or None if model is fine."""
    return _load_error
