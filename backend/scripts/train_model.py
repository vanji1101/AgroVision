"""
train_model.py
==============
Trains a MobileNetV2 transfer-learning model on the cleaned split dataset.

Two-phase strategy
  Phase 1 - Frozen base (feature extraction), up to 15 epochs, LR = 1e-4
  Phase 2 - Fine-tune top layers of base,     up to 20 epochs, LR = 1e-5

preprocess_input from tensorflow.keras.applications.mobilenet_v2 is applied
consistently to ALL splits (train / val / test) so the model always sees
pixel values in the [-1, 1] range expected by MobileNetV2.

Outputs
  backend/models/best_model.keras       -- best checkpoint (val_accuracy)
  backend/models/class_indices.json     -- rebuilt from actual split folder order
  backend/models/training_history.json  -- epoch-wise loss/accuracy logs
"""

import os
import sys
import json
import numpy as np

# Force UTF-8 output on Windows so box-drawing chars don't crash
if sys.platform == "win32" and hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

import tensorflow as tf  # type: ignore
import keras
from keras import layers
from keras.applications.mobilenet_v2 import preprocess_input

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"

# --------------------------------------------------------------------------- #
# Paths
# --------------------------------------------------------------------------- #
BASE_DIR        = r"D:\Project Niral\AgroVision\backend"
DATA_DIR        = os.path.join(BASE_DIR, "dataset", "split")
TRAIN_DIR       = os.path.join(DATA_DIR, "train")
VAL_DIR         = os.path.join(DATA_DIR, "val")
TEST_DIR        = os.path.join(DATA_DIR, "test")
MODEL_SAVE_PATH = os.path.join(BASE_DIR, "models", "best_model.keras")
CLASS_IDX_PATH  = os.path.join(BASE_DIR, "models", "class_indices.json")
HISTORY_PATH    = os.path.join(BASE_DIR, "models", "training_history.json")
LOG_DIR         = os.path.join(BASE_DIR, "models", "tb_logs")

# --------------------------------------------------------------------------- #
# Hyper-parameters
# --------------------------------------------------------------------------- #
IMG_SIZE      = (224, 224)
BATCH_SIZE    = 32
PHASE1_EPOCHS = 15
PHASE2_EPOCHS = 20
FINE_TUNE_AT  = 100   # freeze base layers 0..99, unfreeze 100+

os.makedirs(os.path.dirname(MODEL_SAVE_PATH), exist_ok=True)
os.makedirs(LOG_DIR, exist_ok=True)

print("=" * 60)
print("AgroVision - MobileNetV2 Training Script")
print("=" * 60)
print(f"TensorFlow : {tf.__version__}")
gpus = tf.config.list_physical_devices("GPU")
print(f"GPUs found : {len(gpus)}")
if gpus:
    for g in gpus:
        print(f"  - {g.name}")
print()

# --------------------------------------------------------------------------- #
# 1. Load datasets
# --------------------------------------------------------------------------- #
print("-- Loading datasets --")
train_ds_raw = keras.utils.image_dataset_from_directory(
    TRAIN_DIR,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode="categorical",
    shuffle=True,
    seed=42,
)
val_ds_raw = keras.utils.image_dataset_from_directory(
    VAL_DIR,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode="categorical",
    shuffle=False,
)
test_ds_raw = keras.utils.image_dataset_from_directory(
    TEST_DIR,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode="categorical",
    shuffle=False,
)

class_names = train_ds_raw.class_names
num_classes = len(class_names)
print(f"\nClasses detected : {num_classes}")
for i, c in enumerate(class_names):
    print(f"  [{i:02d}] {c}")

# Rebuild class_indices.json to match the actual split folder order
class_idx = {str(i): name for i, name in enumerate(class_names)}
with open(CLASS_IDX_PATH, "w") as f:
    json.dump(class_idx, f, indent=4)
print(f"\nclass_indices.json saved -> {CLASS_IDX_PATH}")

# --------------------------------------------------------------------------- #
# 2. Preprocessing + Augmentation
#
# preprocess_input maps [0, 255] float32 -> [-1, 1] as required by MobileNetV2.
# Augmentation runs BEFORE preprocess_input on [0,255] values.
# --------------------------------------------------------------------------- #
augment = keras.Sequential(
    [
        layers.RandomFlip("horizontal"),
        layers.RandomRotation(0.15),
        layers.RandomZoom(0.15),
        layers.RandomBrightness(0.1),
        layers.RandomContrast(0.1),
    ],
    name="augmentation",
)

AUTOTUNE = tf.data.AUTOTUNE


def apply_preprocess(image, label):
    """Cast to float32 and apply MobileNetV2 preprocess_input."""
    return preprocess_input(tf.cast(image, tf.float32)), label


def augment_and_preprocess(image, label):
    """Augment first (on [0,255] range), then preprocess_input -> [-1,1]."""
    image = augment(image, training=True)
    return preprocess_input(tf.cast(image, tf.float32)), label


train_ds = (
    train_ds_raw
    .map(augment_and_preprocess, num_parallel_calls=AUTOTUNE)
    .prefetch(AUTOTUNE)
)
val_ds = (
    val_ds_raw
    .map(apply_preprocess, num_parallel_calls=AUTOTUNE)
    .prefetch(AUTOTUNE)
)
test_ds = (
    test_ds_raw
    .map(apply_preprocess, num_parallel_calls=AUTOTUNE)
    .prefetch(AUTOTUNE)
)

# --------------------------------------------------------------------------- #
# 3. Build model
# --------------------------------------------------------------------------- #
print("\n-- Building MobileNetV2 model --")
base_model = keras.applications.MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights="imagenet",
)
base_model.trainable = False

inputs  = layers.Input(shape=(224, 224, 3), name="input_image")
x       = base_model(inputs, training=False)
x       = layers.GlobalAveragePooling2D(name="gap")(x)
x       = layers.BatchNormalization(name="bn_head")(x)
x       = layers.Dropout(0.3, name="dropout_head")(x)
outputs = layers.Dense(num_classes, activation="softmax", name="predictions")(x)

model = keras.Model(inputs, outputs, name="AgroVision_MobileNetV2")
model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=1e-4),
    loss="categorical_crossentropy",
    metrics=["accuracy"],
)
model.summary(line_length=90)

# --------------------------------------------------------------------------- #
# 4. Shared callbacks
# --------------------------------------------------------------------------- #
checkpoint = keras.callbacks.ModelCheckpoint(
    filepath=MODEL_SAVE_PATH,
    monitor="val_accuracy",
    save_best_only=True,
    verbose=1,
)
tensorboard = keras.callbacks.TensorBoard(log_dir=LOG_DIR, histogram_freq=0)

# --------------------------------------------------------------------------- #
# 5. Phase 1 - Feature Extraction (frozen base)
# --------------------------------------------------------------------------- #
print("\n-- Phase 1: Transfer Learning (frozen base) --")
early_stop_p1 = keras.callbacks.EarlyStopping(
    monitor="val_loss", patience=4, restore_best_weights=True, verbose=1
)
reduce_lr_p1 = keras.callbacks.ReduceLROnPlateau(
    monitor="val_loss", factor=0.5, patience=2, min_lr=1e-7, verbose=1
)

history_p1 = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=PHASE1_EPOCHS,
    callbacks=[checkpoint, early_stop_p1, reduce_lr_p1, tensorboard],
    verbose=1,
)

# --------------------------------------------------------------------------- #
# 6. Phase 2 - Fine-tuning (unfreeze top layers of base)
# --------------------------------------------------------------------------- #
print("\n-- Phase 2: Fine-Tuning (top base layers unfrozen) --")
base_model.trainable = True

for layer in base_model.layers[:FINE_TUNE_AT]:
    layer.trainable = False

trainable_count = sum(1 for l in base_model.layers if l.trainable)
print(f"Trainable base layers: {trainable_count} / {len(base_model.layers)}")

model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=1e-5),
    loss="categorical_crossentropy",
    metrics=["accuracy"],
)

early_stop_p2 = keras.callbacks.EarlyStopping(
    monitor="val_loss", patience=5, restore_best_weights=True, verbose=1
)
reduce_lr_p2 = keras.callbacks.ReduceLROnPlateau(
    monitor="val_loss", factor=0.5, patience=3, min_lr=1e-8, verbose=1
)

history_p2 = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=PHASE2_EPOCHS,
    callbacks=[checkpoint, early_stop_p2, reduce_lr_p2, tensorboard],
    verbose=1,
)

# --------------------------------------------------------------------------- #
# 7. Save combined training history
# --------------------------------------------------------------------------- #
combined_history = {}
for key in history_p1.history:
    combined_history[f"p1_{key}"] = [float(v) for v in history_p1.history[key]]
for key in history_p2.history:
    combined_history[f"p2_{key}"] = [float(v) for v in history_p2.history[key]]

with open(HISTORY_PATH, "w") as f:
    json.dump(combined_history, f, indent=2)
print(f"\nTraining history saved -> {HISTORY_PATH}")

# --------------------------------------------------------------------------- #
# 8. Final evaluation on test set (using best saved checkpoint)
# --------------------------------------------------------------------------- #
print("\n-- Final Evaluation on Test Set --")
best_model = keras.models.load_model(MODEL_SAVE_PATH)
test_loss, test_acc = best_model.evaluate(test_ds, verbose=1)
print(f"\n{'=' * 40}")
print(f"  Test Loss     : {test_loss:.4f}")
print(f"  Test Accuracy : {test_acc * 100:.2f}%")
print(f"{'=' * 40}")

# --------------------------------------------------------------------------- #
# 9. Per-class accuracy on test set
# --------------------------------------------------------------------------- #
print("\n-- Per-class Accuracy on Test Set --")
y_true, y_pred = [], []
for images, labels in test_ds:
    preds = best_model.predict(images, verbose=0)
    y_true.extend(np.argmax(labels.numpy(), axis=1))
    y_pred.extend(np.argmax(preds, axis=1))

y_true = np.array(y_true)
y_pred = np.array(y_pred)

print(f"{'Class':<35} {'Correct':>8} {'Total':>8} {'Acc%':>8}")
print("-" * 65)
for idx, cname in enumerate(class_names):
    mask    = y_true == idx
    total   = mask.sum()
    correct = (y_pred[mask] == idx).sum()
    acc     = correct / total * 100 if total > 0 else 0.0
    print(f"  {cname:<33} {correct:>8} {total:>8} {acc:>7.1f}%")

overall = (y_true == y_pred).mean() * 100
print("-" * 65)
print(f"  {'OVERALL':<33} {(y_true == y_pred).sum():>8} {len(y_true):>8} {overall:>7.1f}%")

print(f"\n[DONE] Best model saved -> {MODEL_SAVE_PATH}")
print("Training complete.")
