# =============================================================
# services/treatment_service.py
# Provides dummy treatment suggestions and prevention tips
# based on the predicted disease name.
# =============================================================

# ---------------------------------------------------------------------------
# Disease knowledge base
# Each key is a normalized disease label (lowercase, spaces trimmed).
# Add more entries here as you expand the model's class list.
# ---------------------------------------------------------------------------
DISEASE_INFO: dict[str, dict[str, str]] = {

    # ── Rice ──────────────────────────────────────────────────────────────
    "rice___leaf_blight": {
        "treatment": (
            "Apply copper-based fungicides (e.g., Blitox 50 WP) at 2 g/L. "
            "Drain excess water from the field to reduce humidity. "
            "Remove and destroy severely infected plant debris."
        ),
        "prevention": (
            "Use certified, blight-resistant rice varieties. "
            "Avoid excessive nitrogen fertilization. "
            "Maintain proper field drainage and spacing between plants."
        ),
    },
    "rice___brown_spot": {
        "treatment": (
            "Spray Mancozeb (75 WP) at 2.5 g/L or Iprobenfos at 1 mL/L. "
            "Apply potassium fertilizer to strengthen plant immunity."
        ),
        "prevention": (
            "Use disease-free seeds treated with thiram. "
            "Ensure balanced NPK fertilization. "
            "Avoid water stress during the growing period."
        ),
    },
    "rice___neck_blast": {
        "treatment": (
            "Apply Tricyclazole 75 WP at 0.6 g/L or Isoprothiolane at 1.5 mL/L. "
            "Start spraying at the panicle initiation stage."
        ),
        "prevention": (
            "Use blast-resistant varieties. "
            "Avoid dense planting and excessive nitrogen. "
            "Maintain optimal water levels throughout crop growth."
        ),
    },
    "rice___healthy": {
        "treatment": "No treatment required. Your crop is healthy!",
        "prevention": (
            "Continue regular scouting. "
            "Maintain field hygiene and balanced fertilization."
        ),
    },

    # ── Tomato ────────────────────────────────────────────────────────────
    "tomato___early_blight": {
        "treatment": (
            "Apply Chlorothalonil 75 WP at 2 g/L or Mancozeb 75 WP at 2.5 g/L. "
            "Remove and destroy infected lower leaves immediately."
        ),
        "prevention": (
            "Practice crop rotation (avoid planting tomatoes in the same spot each year). "
            "Use mulch to reduce soil splash. "
            "Water at the base of plants and avoid overhead irrigation."
        ),
    },
    "tomato___late_blight": {
        "treatment": (
            "Spray Metalaxyl + Mancozeb (Ridomil Gold) at 2.5 g/L. "
            "Remove infected plants to stop disease spread."
        ),
        "prevention": (
            "Plant certified disease-free transplants. "
            "Ensure good air circulation between plants. "
            "Avoid working in the field when foliage is wet."
        ),
    },
    "tomato___leaf_mold": {
        "treatment": (
            "Apply Copper fungicide or Chlorothalonil at recommended dose. "
            "Improve greenhouse ventilation if growing indoors."
        ),
        "prevention": (
            "Maintain relative humidity below 85 %. "
            "Use resistant varieties like 'Mountain Fresh'. "
            "Space plants adequately for air movement."
        ),
    },
    "tomato___septoria_leaf_spot": {
        "treatment": (
            "Apply Mancozeb 75 WP or Copper-based fungicides at first sign of spots. "
            "Remove and dispose of infected leaves."
        ),
        "prevention": (
            "Rotate crops every 2–3 years. "
            "Avoid overhead watering. "
            "Stake plants to improve air circulation."
        ),
    },
    "tomato___bacterial_spot": {
        "treatment": (
            "Apply Copper hydroxide (Kocide 3000) at 1.5 g/L. "
            "Avoid working in the field when wet."
        ),
        "prevention": (
            "Use pathogen-free seed and transplants. "
            "Avoid overhead irrigation. "
            "Disinfect tools regularly."
        ),
    },
    "tomato___healthy": {
        "treatment": "No treatment required. Your tomato crop is healthy!",
        "prevention": (
            "Keep monitoring weekly. "
            "Maintain proper spacing and balanced nutrition."
        ),
    },

    # ── Potato ────────────────────────────────────────────────────────────
    "potato___early_blight": {
        "treatment": (
            "Apply Mancozeb 75 WP at 2.5 g/L or Azoxystrobin at 1 mL/L. "
            "Remove infected foliage and avoid overhead irrigation."
        ),
        "prevention": (
            "Use certified seed potatoes. "
            "Rotate crops; avoid planting potatoes after tomatoes. "
            "Ensure adequate potassium levels in the soil."
        ),
    },
    "potato___late_blight": {
        "treatment": (
            "Apply Metalaxyl + Mancozeb (Ridomil Gold) at 2 g/L immediately. "
            "Destroy infected plants and tubers to prevent spread."
        ),
        "prevention": (
            "Plant resistant varieties (e.g., Sarla, Kufri Jyoti). "
            "Avoid excessive irrigation. "
            "Hilling soil around plants can protect tubers."
        ),
    },
    "potato___healthy": {
        "treatment": "No treatment required. Your potato crop is healthy!",
        "prevention": (
            "Continue regular field scouting. "
            "Maintain adequate drainage and balanced fertilization."
        ),
    },

    # ── Corn / Maize ──────────────────────────────────────────────────────
    "corn___common_rust": {
        "treatment": (
            "Apply Propiconazole 25 EC at 1 mL/L or Mancozeb 75 WP at 2.5 g/L. "
            "Start treatment at early signs of rust pustules."
        ),
        "prevention": (
            "Plant rust-resistant hybrids. "
            "Avoid late planting which increases disease exposure. "
            "Monitor fields regularly during high-humidity periods."
        ),
    },
    "corn___northern_leaf_blight": {
        "treatment": (
            "Apply Tebuconazole 25 EC at 1 mL/L. "
            "Remove infected lower leaves to reduce inoculum."
        ),
        "prevention": (
            "Use resistant hybrids. "
            "Practice crop rotation with non-host crops. "
            "Incorporate infected debris into soil after harvest."
        ),
    },
    "corn___gray_leaf_spot": {
        "treatment": (
            "Spray Azoxystrobin + Propiconazole (Quilt Xcel) at 1 mL/L. "
            "Treat at VT/R1 growth stage for best results."
        ),
        "prevention": (
            "Plant resistant hybrids. "
            "Rotate with soybean or wheat. "
            "Minimize leaf wetness duration through proper spacing."
        ),
    },
    "corn___healthy": {
        "treatment": "No treatment required. Your maize crop is healthy!",
        "prevention": (
            "Continue regular monitoring. "
            "Keep field weed-free and maintain balanced NPK."
        ),
    },

    # ── Wheat ─────────────────────────────────────────────────────────────
    "wheat___yellow_rust": {
        "treatment": (
            "Apply Propiconazole 25 EC (Tilt) at 0.1 % solution. "
            "Spray at first appearance of yellow stripes."
        ),
        "prevention": (
            "Grow rust-resistant varieties. "
            "Avoid late sowing. "
            "Monitor crop regularly from tillering stage."
        ),
    },
    "wheat___stem_rust": {
        "treatment": (
            "Apply Triadimefon (Bayleton) at 1 g/L or Propiconazole 25 EC at 1 mL/L. "
            "Treat immediately upon first sign."
        ),
        "prevention": (
            "Use certified resistant seed varieties. "
            "Destroy volunteer wheat plants. "
            "Report unusual outbreaks to local agriculture department."
        ),
    },
    "wheat___healthy": {
        "treatment": "No treatment required. Your wheat crop is healthy!",
        "prevention": (
            "Maintain balanced fertilization. "
            "Scout fields regularly for early disease detection."
        ),
    },

    # ── Apple ─────────────────────────────────────────────────────────────
    "apple___apple_scab": {
        "treatment": (
            "Apply Captan 50 WP at 2.5 g/L or Myclobutanil at 1 g/L. "
            "Begin fungicide program at green tip stage."
        ),
        "prevention": (
            "Rake and destroy fallen leaves to reduce overwintering spores. "
            "Prune trees for better air circulation. "
            "Plant resistant apple varieties."
        ),
    },
    "apple___black_rot": {
        "treatment": (
            "Prune out cankers and mummified fruits. "
            "Apply Captan or Thiophanate-methyl at 2 g/L during the growing season."
        ),
        "prevention": (
            "Remove dead wood and mummified fruits promptly. "
            "Keep orchard clean of debris. "
            "Avoid wounding fruit during harvest."
        ),
    },
    "apple___healthy": {
        "treatment": "No treatment required. Your apple crop is healthy!",
        "prevention": (
            "Continue dormant oil sprays in winter. "
            "Maintain good orchard sanitation."
        ),
    },

    # ── Grape ─────────────────────────────────────────────────────────────
    "grape___black_rot": {
        "treatment": (
            "Apply Myclobutanil (Rally 40 WSP) at 1 g/L or Mancozeb at 2.5 g/L. "
            "Remove and destroy mummified berries."
        ),
        "prevention": (
            "Prune for open canopy to improve air circulation. "
            "Apply protective fungicides from early shoot growth. "
            "Control weeds around vineyard."
        ),
    },
    "grape___leaf_blight": {
        "treatment": (
            "Apply Copper fungicide or Mancozeb 75 WP at 2 g/L. "
            "Reduce irrigation frequency."
        ),
        "prevention": (
            "Avoid overhead irrigation. "
            "Train vines to improve airflow. "
            "Remove infected leaves regularly."
        ),
    },
    "grape___healthy": {
        "treatment": "No treatment required. Your grape crop is healthy!",
        "prevention": (
            "Continue regular pruning and canopy management. "
            "Scout for pests and diseases weekly."
        ),
    },
}

# ---------------------------------------------------------------------------
# Default fallback when disease is not in the knowledge base
# ---------------------------------------------------------------------------
_DEFAULT_INFO: dict[str, str] = {
    "treatment": (
        "Consult your local agricultural extension officer for precise treatment advice. "
        "As a general measure, remove and destroy heavily infected plant parts and "
        "apply a broad-spectrum fungicide/bactericide appropriate for the crop."
    ),
    "prevention": (
        "Practice crop rotation, use certified disease-free seeds, maintain proper "
        "plant spacing for air circulation, and scout fields regularly."
    ),
}


def get_treatment_info(disease_label: str) -> dict[str, str]:
    """
    Returns treatment and prevention info for the given disease label.

    Args:
        disease_label: Raw class label from model output
                       (e.g. 'Tomato___Early_Blight' or 'tomato___early_blight').

    Returns:
        A dict with keys 'treatment' and 'prevention'.
    """
    # Normalize: lowercase + strip whitespace for consistent lookup
    key = disease_label.strip().lower()
    return DISEASE_INFO.get(key, _DEFAULT_INFO)
