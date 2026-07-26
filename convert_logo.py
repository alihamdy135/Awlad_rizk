import os
from PIL import Image

src_image = r"C:\Users\Dell\.gemini\antigravity\brain\083130c1-5de0-4f5c-9ca3-d47da5720b14\awlad_rizk_logo_monogram_1785106617066.jpg"

def process_and_save(img, path, size=None):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if size:
        resized_img = img.resize(size, Image.LANCZOS)
        resized_img.save(path, format="PNG")
    else:
        img.save(path, format="PNG")

with Image.open(src_image) as img:
    # Convert to RGBA to ensure it can be saved as PNG properly
    img = img.convert("RGBA")
    
    # Backend paths
    process_and_save(img, r"d:\Ahmed Project\awlad-rizk\backend\public\logo.png")
    process_and_save(img, r"d:\Ahmed Project\awlad-rizk\backend\public\favicon.ico", size=(64, 64))
    
    # Flutter Web paths
    process_and_save(img, r"d:\Ahmed Project\awlad-rizk\flutter\web\favicon.png", size=(64, 64))
    process_and_save(img, r"d:\Ahmed Project\awlad-rizk\flutter\web\icons\Icon-192.png", size=(192, 192))
    process_and_save(img, r"d:\Ahmed Project\awlad-rizk\flutter\web\icons\Icon-512.png", size=(512, 512))
    process_and_save(img, r"d:\Ahmed Project\awlad-rizk\flutter\web\icons\Icon-maskable-192.png", size=(192, 192))
    process_and_save(img, r"d:\Ahmed Project\awlad-rizk\flutter\web\icons\Icon-maskable-512.png", size=(512, 512))
    
    # Flutter App Assets
    process_and_save(img, r"d:\Ahmed Project\awlad-rizk\flutter\assets\images\logo.png")

print("All logos converted and saved successfully!")
