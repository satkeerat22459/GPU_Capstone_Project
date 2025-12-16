#include <iostream>
#include <string>
#include <filesystem>
#include <vector>
#include <cuda_runtime.h>
#include <npp.h>
#include <nppi.h>

#define STB_IMAGE_IMPLEMENTATION
#include "../include/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../include/stb_image_write.h"

namespace fs = std::filesystem;

// --- GPU KERNEL WRAPPERS ---

void applyGrayscale(unsigned char* d_src, unsigned char* d_dst, int width, int height) {
    NppiSize oSizeROI = {width, height};
    // RGB to Gray (3 channels -> 1 channel)
    // Note: User must allocate d_dst as 1 channel
    nppiRGBToGray_8u_C3C1R(d_src, width * 3, d_dst, width, oSizeROI);
}

void applyBlur(unsigned char* d_src, unsigned char* d_dst, int width, int height) {
    NppiSize oSizeROI = {width, height};
    NppiSize oMaskSize = {5, 5}; // 5x5 Blur Mask
    NppiPoint oAnchor = {2, 2};  // Center of the mask
    
    // Box Filter (Simple Blur) - 3 channels to 3 channels
    nppiFilterBox_8u_C3R(d_src, width * 3, d_dst, width * 3, oSizeROI, oMaskSize, oAnchor);
}

void applyMirror(unsigned char* d_src, unsigned char* d_dst, int width, int height) {
    NppiSize oSizeROI = {width, height};
    // Horizontal Mirror (Flip) - 3 channels to 3 channels
    nppiMirror_8u_C3R(d_src, width * 3, d_dst, width * 3, oSizeROI, NPP_HORIZONTAL_AXIS);
}

// --- MAIN PROCESSOR ---

void processImage(const fs::path& inputPath, const fs::path& outputPath, std::string filterType) {
    int width, height, channels;
    // Load image
    unsigned char* h_data = stbi_load(inputPath.c_str(), &width, &height, &channels, 3);
    if (!h_data) {
        std::cerr << "Failed to load: " << inputPath << std::endl;
        return;
    }

    int pixelCount = width * height;
    int srcSize = pixelCount * 3;
    int dstSize = pixelCount * 3; // Default to 3 channels (RGB)
    int dstChannels = 3;

    // Adjust output size for Grayscale
    if (filterType == "gray") {
        dstSize = pixelCount * 1;
        dstChannels = 1;
    }

    // Allocate GPU Memory
    Npp8u *d_src = nullptr, *d_dst = nullptr;
    cudaMalloc((void**)&d_src, srcSize);
    cudaMalloc((void**)&d_dst, dstSize);

    // Copy to Device
    cudaMemcpy(d_src, h_data, srcSize, cudaMemcpyHostToDevice);

    // --- APPLY FILTER ---
    if (filterType == "gray") {
        applyGrayscale(d_src, d_dst, width, height);
    } 
    else if (filterType == "blur") {
        applyBlur(d_src, d_dst, width, height);
    } 
    else if (filterType == "mirror") {
        applyMirror(d_src, d_dst, width, height);
    } 
    else {
        // Default to Copy if unknown
        cudaMemcpy(d_dst, d_src, srcSize, cudaMemcpyDeviceToDevice);
    }

    // Copy back to Host
    std::vector<unsigned char> h_result(dstSize);
    cudaMemcpy(h_result.data(), d_dst, dstSize, cudaMemcpyDeviceToHost);

    // Save Image
    stbi_write_jpg(outputPath.c_str(), width, height, dstChannels, h_result.data(), 100);

    // Cleanup
    stbi_image_free(h_data);
    cudaFree(d_src);
    cudaFree(d_dst);

    std::cout << "[INFO] Processed (" << filterType << "): " << inputPath.filename() << std::endl;
}

int main(int argc, char** argv) {
    std::string inputDir = (argc > 1) ? argv[1] : "./data/input";
    std::string outputDir = (argc > 2) ? argv[2] : "./data/output";
    std::string filterType = (argc > 3) ? argv[3] : "gray"; // Default

    fs::create_directories(outputDir);
    
    std::cout << "Starting Batch Processing with Filter: " << filterType << std::endl;

    for (const auto& entry : fs::directory_iterator(inputDir)) {
        if (entry.is_regular_file()) {
            std::string ext = entry.path().extension();
            if (ext == ".jpg" || ext == ".png" || ext == ".jpeg") {
                processImage(entry.path(), fs::path(outputDir) / entry.path().filename(), filterType);
            }
        }
    }
    
    std::cout << "Batch Complete." << std::endl;
    return 0;
}