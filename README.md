# CUDA Multi-Filter Image Processor

## Project Description
This project is a high-performance, GPU-accelerated image processing tool capable of applying multiple signal processing filters (Grayscale, Gaussian Blur, and Geometric Mirroring) to large datasets in batch.

Built using C++ and the NVIDIA NPP (NVIDIA Performance Primitives) library, this tool demonstrates how to leverage the GPU for different classes of image operations:
* Color Conversion: Efficient RGB-to-Grayscale transformation.
* Convolution Filtering: 2D Box/Blur filtering using neighbor pixels.
* Geometric Transformation: Memory-level image mirroring/flipping.

The project features a fully automated pipeline (run.sh) that handles data ingestion, compilation, execution of all three modes, and result visualization.

## Prerequisites
To run this project, you need an environment with an NVIDIA GPU.

* Hardware: NVIDIA GPU (Compute Capability 3.5+)
* Software:
    * CUDA Toolkit (10.0+)
    * GCC/G++ Compiler
    * Python 3 (for visualization)
    * make build system

## CLI Usage (Manual)
If you compile the project manually using make, you can use the tool from the command line with specific flags.

Syntax:
./batch_proc <INPUT_DIR> <OUTPUT_DIR> <FILTER_MODE>

Modes:
* gray: Converts image to single-channel Grayscale (Uses nppiRGBToGray_8u_C3C1R)
* blur: Applies a 5x5 Box Filter Convolution (Uses nppiFilterBox_8u_C3R)
* mirror: Horizontally flips the image (Uses nppiMirror_8u_C3R)

## Proof of Execution
The automated pipeline generates a visual artifact capstone_showcase.png that demonstrates the successful application of all three filters on a sample image.

* Input Data: Google/TensorFlow "Flower Photos" Dataset.
* Throughput: Processes batches of high-resolution images using GPU device memory.
* Artifacts:
    * logs/execution.log (Console output)
    * capstone_showcase.png (Visual verification)
