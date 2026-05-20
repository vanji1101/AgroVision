import os
import json
import numpy as np
import tensorflow as tf  # type: ignore
import keras
from keras import layers, models

# ─── Configuration ────────────────────────────────────────────────────────────
DATA_DIR          = r"D:\Project Niral\AgroVision\backend\dataset\split"
TRAIN_DIR         = os.path.join(DATA_DIR, "train")
VAL_DIR           = os.path.join(DATA_DIR, "val")
MODEL_SAVE_PATH   = r"D:\Project Niral\AgroVision\backend\models\crop_disease_model_phase1.h5"
CLASS_IDX_PATH    = r"D:\Project Niral\AgroVision\backend\models\class_indices.json"

IMG_SIZE   = (224, 224)
BATCH_SIZE = 32
EPOCHS     = 10
LR         = 1e-4

os.makedirs(os.path.dirname(MODEL_SAVE_PATH), exist_ok=True)

# ─── 1. Load datasets ─────────────────────────────────────────────────────────
print("Loading datasets...")
train_ds = keras.utils.image_dataset_from_directory(
    TRAIN_DIR, image_size=IMG_SIZE, batch_size=BATCH_SIZE,
    label_mode="categorical", shuffle=True, seed=42
)
val_ds = keras.utils.image_dataset_from_directory(
    VAL_DIR, image_size=IMG_SIZE, batch_size=BATCH_SIZE,
    label_mode="categorical", shuffle=False
)

class_names = train_ds.class_names
num_classes = len(class_names)
print(f"Total classes: {num_classes}")
print(f"Classes: {class_names}")

# ─── 2. Save class_indices.json (index → name) ────────────────────────────────
class_indices = {str(i): name for i, name in enumerate(class_names)}
with open(CLASS_IDX_PATH, "w") as f:
    json.dump(class_indices, f, indent=4)
print(f"class_indices.json saved to {CLASS_IDX_PATH}")

# ─── 3. Data augmentation ─────────────────────────────────────────────────────
# Using only simple spatial augmentations to avoid corrupting image values
augment = keras.Sequential([
    layers.RandomFlip("horizontal_and_vertical"),
    layers.RandomRotation(0.2),
    layers.RandomZoom(0.2),
], name="augmentation")

AUTOTUNE = tf.data.AUTOTUNE

def preprocess(image, label):
    # image_dataset_from_directory yields float32 in [0, 255]
    # preprocess_input expects this and scales to [-1, 1]
    return keras.applications.mobilenet_v2.preprocess_input(image), label

def augment_and_preprocess(image, label):
    # Apply augmentations which preserve [0, 255] float32 range
    image = augment(image, training=True)
    return keras.applications.mobilenet_v2.preprocess_input(image), label

train_ds = train_ds.map(augment_and_preprocess, num_parallel_calls=AUTOTUNE).prefetch(AUTOTUNE)
val_ds   = val_ds.map(preprocess, num_parallel_calls=AUTOTUNE).prefetch(AUTOTUNE)

# ─── 4. Build model (Phase 1) ─────────────────────────────────────────────────
base_model = keras.applications.MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights="imagenet"
)
base_model.trainable = False

inputs  = layers.Input(shape=(224, 224, 3))
x       = base_model(inputs, training=False)
x       = layers.GlobalAveragePooling2D()(x)
x       = layers.Dropout(0.3)(x)
outputs = layers.Dense(num_classes, activation="softmax")(x)

model = keras.Model(inputs, outputs)
model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=LR),
    loss="categorical_crossentropy",
    metrics=["accuracy"]
)
model.summary()

# ─── 5. Callbacks ─────────────────────────────────────────────────────────────
early_stop = keras.callbacks.EarlyStopping(
    monitor="val_loss", patience=3, restore_best_weights=True, verbose=1
)

# ─── 6. Train ─────────────────────────────────────────────────────────────────
print(f"\nStarting Phase 1 Training (Frozen base, LR={LR}, Epochs={EPOCHS})...")
history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=EPOCHS,
    callbacks=[early_stop],
    verbose=1
)

# ─── 7. Save final model ──────────────────────────────────────────────────────
model.save(MODEL_SAVE_PATH)
print(f"\nPhase 1 Model saved to {MODEL_SAVE_PATH}")
