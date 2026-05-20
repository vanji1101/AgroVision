import os
import shutil
import random
import json
from pathlib import Path
from PIL import Image
from collections import defaultdict

# Setup paths
BASE_DIR = Path(r"D:\Project Niral\AgroVision\backend")
RAW_DIR = BASE_DIR / "dataset" / "raw"
CLEAN_DIR = BASE_DIR / "dataset" / "clean"
SPLIT_DIR = BASE_DIR / "dataset" / "split"
MODELS_DIR = BASE_DIR / "models"
SUMMARY_FILE = BASE_DIR / "dataset" / "dataset_summary.txt"

# Ensure clean state
if CLEAN_DIR.exists():
    shutil.rmtree(CLEAN_DIR)
if SPLIT_DIR.exists():
    shutil.rmtree(SPLIT_DIR)

# Max images per class for balancing
MAX_IMAGES_PER_CLASS = 1000

CLASS_MAPPING = {
    "Tomato_Healthy": ("Tomato", ["healthy"]),
    "Tomato_Early_Blight": ("Tomato", ["early_blight"]),
    "Tomato_Late_Blight": ("Tomato", ["late_blight"]),
    
    "Brinjal_Healthy": ("Brinjal", ["healthy", "normal", "healthy leaf"]),
    "Brinjal_Leaf_Spot": ("Brinjal", ["leaf spot", "leaf_spot"]),
    "Brinjal_Mosaic": ("Brinjal", ["mosaic"]),
    
    "Paddy_Healthy": ("Paddy", ["normal"]),
    "Paddy_Brown_Spot": ("Paddy", ["brown_spot"]),
    "Paddy_Leaf_Blast": ("Paddy", ["blast"]),
    "Paddy_Bacterial_Leaf_Blight": ("Paddy", ["bacterial_leaf_blight"]),
    
    "Corn_Healthy": ("Corn", ["healthy"]),
    "Corn_Common_Rust": ("Corn", ["common_rust", "rust"]),
    "Corn_Leaf_Blight": ("Corn", ["blight"]),
    
    "Sugarcane_Healthy": ("Sugarcane", ["healthy"]),
    "Sugarcane_Rust": ("Sugarcane", ["rust"]),
    "Sugarcane_Red_Rot": ("Sugarcane", ["redrot", "red_rot"]),
    
    "Potato_Healthy": ("Potato", ["healthy"]),
    "Potato_Early_Blight": ("Potato", ["early_blight"]),
    "Potato_Late_Blight": ("Potato", ["late_blight"]),
}

def is_valid_image(filepath):
    try:
        with Image.open(filepath) as img:
            img.verify() # Verify structure
        return True
    except Exception:
        return False

def prepare_datasets():
    print("Starting dataset preparation...")
    
    collected_images = defaultdict(list)
    
    # 1 & 2: Scan and detect
    for class_name, (crop, keywords) in CLASS_MAPPING.items():
        crop_dir = RAW_DIR / crop
        if not crop_dir.exists():
            print(f"WARNING: Directory for {crop} not found at {crop_dir}.")
            continue
            
        for root, dirs, files in os.walk(crop_dir):
            root_lower = root.lower()
            if "augmented" in root_lower:
                continue
                
            folder_name = os.path.basename(root).lower()
            
            # Allow matching the parent directory if the current one is just a file container
            # Actually, standard is to match the folder name
            match = any(kw.lower() in folder_name for kw in keywords)
            
            if match:
                for file in files:
                    if file.lower().endswith(('.png', '.jpg', '.jpeg', '.webp', '.JPG', '.JPEG', '.PNG')):
                        collected_images[class_name].append(os.path.join(root, file))

    summary_lines = []
    summary_lines.append("Dataset Preparation Summary\n===========================\n")
    
    class_indices = {}
    
    for idx, (class_name, img_paths) in enumerate(CLASS_MAPPING.items()):
        class_indices[str(idx)] = class_name
        
        paths = collected_images.get(class_name, [])
        print(f"[{class_name}] Found {len(paths)} raw images.")
        
        # 5. Remove corrupted
        valid_paths = []
        corrupted = 0
        for p in paths:
            if is_valid_image(p):
                valid_paths.append(p)
            else:
                corrupted += 1
                
        # 6. Balance class
        random.shuffle(valid_paths)
        balanced_paths = valid_paths[:MAX_IMAGES_PER_CLASS]
        
        print(f"[{class_name}] Valid: {len(valid_paths)}, Corrupted: {corrupted}, Selected: {len(balanced_paths)}")
        
        # 7 & 8: Split Dataset
        total_selected = len(balanced_paths)
        if total_selected == 0:
            print(f"WARNING: No valid images found for {class_name}!")
            summary_lines.append(f"{class_name}: 0 images")
            continue
            
        train_end = int(0.7 * total_selected)
        val_end = int(0.9 * total_selected)
        
        train_paths = balanced_paths[:train_end]
        val_paths = balanced_paths[train_end:val_end]
        test_paths = balanced_paths[val_end:]
        
        splits = {
            "train": train_paths,
            "val": val_paths,
            "test": test_paths
        }
        
        for split_name, split_paths in splits.items():
            split_class_dir = SPLIT_DIR / split_name / class_name
            os.makedirs(split_class_dir, exist_ok=True)
            
            # Save to clean dir as well if requested
            clean_class_dir = CLEAN_DIR / class_name
            os.makedirs(clean_class_dir, exist_ok=True)
            
            for i, p in enumerate(split_paths):
                ext = os.path.splitext(p)[1]
                new_filename = f"{class_name}_{i}{ext}"
                
                # Copy to split
                split_dest = split_class_dir / new_filename
                shutil.copy(p, split_dest)
                
                # Copy to clean
                clean_dest = clean_class_dir / f"{split_name}_{new_filename}"
                shutil.copy(p, clean_dest)
                
        # summary stats
        summary_lines.append(f"{class_name}: Total {total_selected} | Train: {len(train_paths)} | Val: {len(val_paths)} | Test: {len(test_paths)}")
    
    # 9. Generate metadata
    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    with open(MODELS_DIR / "class_indices.json", "w") as f:
        json.dump(class_indices, f, indent=4)
        
    (BASE_DIR / "dataset").mkdir(parents=True, exist_ok=True)
    with open(SUMMARY_FILE, "w") as f:
        f.write("\n".join(summary_lines))
        
    print("\nFinal Class-wise Image Count:")
    for line in summary_lines[2:]:
        print(line)
        
    print("\nDataset preparation completed successfully!")

if __name__ == "__main__":
    prepare_datasets()
