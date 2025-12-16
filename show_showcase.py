import matplotlib.pyplot as plt
import cv2
import os
import glob

# Find a sample image name
input_files = glob.glob("data/input/*.jpg")
if not input_files:
    print("No images found!")
    exit()

sample_file = os.path.basename(input_files[0])

# Paths to the different versions
paths = {
    "Original": f"data/input/{sample_file}",
    "Grayscale": f"data/output_gray/{sample_file}",
    "Gaussian Blur": f"data/output_blur/{sample_file}",
    "Mirror Flip": f"data/output_mirror/{sample_file}"
}

# Create Plot
plt.figure(figsize=(15, 5))

for i, (title, path) in enumerate(paths.items()):
    if os.path.exists(path):
        img = cv2.imread(path)
        # Convert BGR to RGB for correct display
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        
        plt.subplot(1, 4, i+1)
        plt.title(title)
        # Use grayscale colormap for the gray image
        plt.imshow(img, cmap='gray' if 'Grayscale' in title else None)
        plt.axis('off')

plt.tight_layout()
plt.savefig("capstone_showcase.png")
print("Showcase image saved to capstone_showcase.png")