#!/bin/bash

# Setup Environment
mkdir -p include src data/input logs
# Clear old log file
rm -f logs/execution.log

# Download Libraries (STB Image)
if [ ! -f include/stb_image.h ]; then
    echo "Downloading STB libraries..." | tee -a logs/execution.log
    wget -q https://raw.githubusercontent.com/nothings/stb/master/stb_image.h -P include/
    wget -q https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h -P include/
fi

# Download Dataset (Flower Photos)
if [ -z "$(ls -A data/input)" ]; then
    echo "Downloading dataset..." | tee -a logs/execution.log
    wget -q https://storage.googleapis.com/download.tensorflow.org/example_images/flower_photos.tgz
    tar -xzf flower_photos.tgz
    # Move a subset of images to keep the demo quick
    mv flower_photos/daisy/*.jpg data/input/
    rm -rf flower_photos flower_photos.tgz
    echo "Dataset ready." | tee -a logs/execution.log
fi

# Compile
echo "--- Compiling ---" | tee -a logs/execution.log
rm -f batch_proc
make 2>&1 | tee -a logs/execution.log

if [ ! -f ./batch_proc ]; then
    echo "Compilation failed." | tee -a logs/execution.log
    exit 1
fi

# Run 3 Different Modes
echo "--- Running Multi-Filter Showcase ---" | tee -a logs/execution.log

# 1. Grayscale
echo "Running Filter: Grayscale..." | tee -a logs/execution.log
./batch_proc data/input data/output_gray gray | tee -a logs/execution.log

# 2. Blur
echo "Running Filter: Blur..." | tee -a logs/execution.log
./batch_proc data/input data/output_blur blur | tee -a logs/execution.log

# 3. Mirror
echo "Running Filter: Mirror..." | tee -a logs/execution.log
./batch_proc data/input data/output_mirror mirror | tee -a logs/execution.log

echo "All filters applied. Results in data/output_* folders." | tee -a logs/execution.log
echo "Log saved to logs/execution.log"