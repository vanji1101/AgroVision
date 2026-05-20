# 📂 AgroVision Dataset Setup Guide

This guide explains how to organize and prepare your crop disease datasets for training the AgroVision ML model.

## 🏗️ Directory Structure

```text
backend/
  dataset/
    raw/                       <-- Place downloaded datasets here
      PlantVillage/            <-- Standard PlantVillage folders (e.g., Tomato___Early_blight)
      RiceLeafDisease/         <-- Rice specific folders
      SugarcaneLeafDisease/    <-- Sugarcane specific folders
    clean/                     <-- Generated: Standardized and verified images
    split/                     <-- Generated: Ready for training
      train/ (70%)
      val/   (20%)
      test/  (10%)
  scripts/
    prepare_dataset.py         <-- Run this to process everything
```

## 📥 Where to Place Datasets

1.  **PlantVillage**: Download from Kaggle and extract into `dataset/raw/PlantVillage/`. Ensure folder names look like `Crop___Disease` (e.g., `Potato___Late_blight`).
2.  **Rice Leaf Disease**: Place into `dataset/raw/RiceLeafDisease/`.
3.  **Sugarcane Leaf Disease**: Place into `dataset/raw/SugarcaneLeafDisease/`.

## 🏷️ Standard Naming Convention

To ensure the backend service and treatment logic work correctly, please follow this naming format for class folders:
`CropName___DiseaseName` (Three underscores).

**Examples:**
- `Rice___Brown_Spot`
- `Rice___Healthy`
- `Tomato___Late_Blight`

## ⚙️ How to Prepare the Data

Once you have placed your images in the `raw/` folders, run the preparation script from the `backend/` directory:

```bash
python scripts/prepare_dataset.py
```

### What the script does:
1.  **Class Standardization**: It scans all subfolders in `raw/` and attempts to map them to the standard naming format.
2.  **Corruption Check**: It opens every image to ensure it isn't corrupted.
3.  **Deduplication/Merging**: If the same class (e.g., `Rice___Healthy`) exists in multiple raw sources, they are merged into one.
4.  **Cleaning**: Clean images are copied to `dataset/clean/`.
5.  **Splitting**: Images are randomly shuffled and split into `train/` (70%), `val/` (20%), and `test/` (10%).
6.  **Class Indices**: Generates a new `class_indices.json` based on the processed folders.

## 📊 Summary
After running the script, check the terminal output for a class-by-class breakdown of the image counts. This helps you identify classes that might need more data (data imbalance).
