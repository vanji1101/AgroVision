import os
import json
import random
import numpy as np
import tensorflow as tf  # type: ignore
import keras
from keras.utils import load_img, img_to_array

# ─── Configuration ────────────────────────────────────────────────────────────
MODEL_PATH       = r"D:\Project Niral\AgroVision\backend\models\best_model.keras"
CLASS_IDX_PATH   = r"D:\Project Niral\AgroVision\backend\models\class_indices.json"
TEST_DIR         = r"D:\Project Niral\AgroVision\backend\dataset\split\test"
IMG_SIZE         = (224, 224)

print("=" * 70)
print("  DEBUG: Model Predictions (Phase 1)")
print("=" * 70)

# ─── 1. Load Model & Indices ──────────────────────────────────────────────────
if not os.path.exists(MODEL_PATH):
    print(f"[ERROR] Model NOT found at: {MODEL_PATH}")
    exit(1)

model = keras.models.load_model(MODEL_PATH)
with open(CLASS_IDX_PATH) as f:
    class_indices = json.load(f)

idx_to_class = {int(k): v for k, v in class_indices.items()}
num_classes = len(idx_to_class)

# ─── 2. Sample 10 Random Images ───────────────────────────────────────────────
samples = []
class_dirs = [d for d in os.listdir(TEST_DIR) if os.path.isdir(os.path.join(TEST_DIR, d))]

# Get 10 random images across different classes
for _ in range(10):
    cls_name = random.choice(class_dirs)
    cls_dir = os.path.join(TEST_DIR, cls_name)
    imgs = [f for f in os.listdir(cls_dir) if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
    if imgs:
        chosen = random.choice(imgs)
        samples.append((os.path.join(cls_dir, chosen), cls_name))

print("Preprocessing Method: tf.keras.applications.mobilenet_v2.preprocess_input")
print("-" * 70)

# ─── 3. Run Predictions ───────────────────────────────────────────────────────
for i, (img_path, actual_class) in enumerate(samples, 1):
    # Load and preprocess exactly as training
    img = load_img(img_path, target_size=IMG_SIZE)
    img_array = img_to_array(img)
    # img_array is [0, 255] float32
    img_array = keras.applications.mobilenet_v2.preprocess_input(img_array)
    # img_array is now [-1, 1] float32
    img_array = np.expand_dims(img_array, axis=0)

    preds = model.predict(img_array, verbose=0)[0]
    
    # Get top 3 predictions
    top3_indices = np.argsort(preds)[-3:][::-1]
    
    predicted_class = idx_to_class[top3_indices[0]]
    confidence = preds[top3_indices[0]] * 100
    
    print(f"Sample {i}: {os.path.basename(img_path)}")
    print(f"Actual Class:    {actual_class}")
    print(f"Predicted Class: {predicted_class} ({confidence:.2f}%)")
    
    print("Top 3 Predictions:")
    for idx in top3_indices:
        print(f"  - {idx_to_class[idx]}: {preds[idx]*100:.2f}%")
    print("-" * 70)
