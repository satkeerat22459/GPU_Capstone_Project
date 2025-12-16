#!/bin/bash

# Setup Environment
mkdir -p include src data/input logs

# Download Libraries (STB Image) if missing
if [ ! -f include/stb_image.h ]; then
    echo "Downloading STB libraries..."
    wget -q https://raw.githubusercontent.com/nothings/stb/master/stb_image.h -P include/
    wget -q https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h -P include/
fi

# Download Dataset (Flower Photos)
if [ -z "$(ls -A data/input)" ]; then
    echo "Downloading dataset..."
    wget -q https://storage.googleapis.com/download.tensorflow.org/example_images/flower_photos.tgz
    tar -xzf flower_photos.tgz
    # Move a subset of images to keep the demo quick
    mv flower_photos/daisy/*.jpg data/input/
    rm -rf flower_photos flower_photos.tgz
    echo "Dataset ready."
fi

# Compile
echo "--- Compiling ---"
rm -f batch_proc
make

if [ ! -f ./batch_proc ]; then
    echo "❌ Compilation failed."
    exit 1
fi

# Run 3 Different Modes
echo "--- Running Multi-Filter Showcase ---"

# 1. Grayscale
echo "Running Filter: Grayscale..."
./batch_proc data/input data/output_gray gray

# 2. Blur
echo "Running Filter: Blur..."
./batch_proc data/input data/output_blur blur

# 3. Mirror
echo "Running Filter: Mirror..."
./batch_proc data/input data/output_mirror mirror

echo "✅ All filters applied. Results in data/output_* folders."