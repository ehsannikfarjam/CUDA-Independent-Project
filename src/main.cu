#include <chrono>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

#include <cuda_runtime.h>
#include <npp.h>

#include "image_io.h"

namespace fs = std::filesystem;

void checkCuda(cudaError_t result) {
  if (result != cudaSuccess) {
    std::cerr << "CUDA Runtime Error: " << cudaGetErrorString(result)
              << std::endl;
    exit(-1);
  }
}

void processImage(const std::string &inputPath, const std::string &outputPath) {
  PPMImage inputImage;
  if (!ImageIO::readPPM(inputPath, inputImage)) {
    return;
  }

  std::cout << "Processing: " << inputPath << " (" << inputImage.width << "x"
            << inputImage.height << ")" << std::endl;

  Npp8u *d_src;
  Npp8u *d_dst;
  size_t srcStep, dstStep;

  int width = inputImage.width;
  int height = inputImage.height;

  // Allocate GPU memory using cudaMallocPitch for better compatibility
  checkCuda(cudaMallocPitch((void **)&d_src, &srcStep,
                            width * 3 * sizeof(Npp8u), height));

  // Intermediate Gray image
  Npp8u *d_gray;
  size_t grayStep;
  checkCuda(cudaMallocPitch((void **)&d_gray, &grayStep,
                            width * 1 * sizeof(Npp8u), height));

  // Output image
  checkCuda(cudaMallocPitch((void **)&d_dst, &dstStep,
                            width * 1 * sizeof(Npp8u), height));

  if (!d_src || !d_gray || !d_dst) {
    std::cerr << "Memory allocation failed" << std::endl;
    return;
  }

  // Copy input data to GPU
  checkCuda(cudaMemcpy2D(d_src, srcStep, inputImage.data.data(), width * 3,
                         width * 3, height, cudaMemcpyHostToDevice));

  // 1. NPP RGB to Gray conversion
  NppiSize size = {width, height};
  NppStatus status =
      nppiRGBToGray_8u_C3C1R(d_src, (int)srcStep, d_gray, (int)grayStep, size);

  if (status != NPP_SUCCESS) {
    std::cerr << "NPP RGBToGray Error: " << status << std::endl;
  } else {
    // 2. NPP Box Filter (Smoothing/Blurring)
    // A 3x3 box filter is a standard GPU-accelerated smoothing operation.
    NppiSize maskSize = {3, 3};
    NppiPoint anchor = {1, 1};
    status = nppiFilterBox_8u_C1R(d_gray, (int)grayStep, d_dst, (int)dstStep,
                                  size, maskSize, anchor);

    if (status != NPP_SUCCESS) {
      std::cerr << "NPP Box Filter Error: " << status << std::endl;
    } else {
      // Copy back to host
      PPMImage outputImage;
      outputImage.width = width;
      outputImage.height = height;
      outputImage.channels = 1;
      outputImage.data.resize(width * height);

      checkCuda(cudaMemcpy2D(outputImage.data.data(), width, d_dst, dstStep,
                             width, height, cudaMemcpyDeviceToHost));
      ImageIO::writePPM(outputPath, outputImage);
      std::cout << "Saved Box-Blurred image: " << outputPath << std::endl;
    }
  }

  cudaFree(d_src);
  cudaFree(d_gray);
  cudaFree(d_dst);
}

int main(int argc, char **argv) {
  std::string inputDir = "data/input";
  std::string outputDir = "data/output";

  if (argc > 1)
    inputDir = argv[1];
  if (argc > 2)
    outputDir = argv[2];

  if (!fs::exists(outputDir)) {
    fs::create_directories(outputDir);
  }

  auto start = std::chrono::high_resolution_clock::now();
  int count = 0;

  for (const auto &entry : fs::directory_iterator(inputDir)) {
    if (entry.path().extension() == ".ppm") {
      std::string inputPath = entry.path().string();
      std::string outputPath =
          (fs::path(outputDir) / entry.path().filename()).string();
      processImage(inputPath, outputPath);
      count++;
    }
  }

  auto end = std::chrono::high_resolution_clock::now();
  std::chrono::duration<double> diff = end - start;

  std::cout << "\nProcessed " << count << " images in " << diff.count()
            << " seconds." << std::endl;

  return 0;
}
