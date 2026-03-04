# CUDA-Independent-Project: Batch Image Edge Detection Suite

This project implements a high-performance batch image processing pipeline using **CUDA** and **NVIDIA Performance Primitives (NPP)**. It is designed to process hundreds of images efficiently by leveraging GPU-accelerated kernels.

## Repository URL
[https://github.com/mohsennikfarjam/CUDA-Independent-Project](https://github.com/mohsennikfarjam/CUDA-Independent-Project)

## Full Terminal Command List

### 1. Data Generation (Optional)
Generates 20 synthetic PPM images for testing if you don't have a dataset ready.
```bash
python generate_data.py
```

### 2. Automated Execution (Linux/Coursera Environment)
Cleans, builds, runs the processing, and generates execution logs automatically.
```bash
bash run.sh
```

### 3. Manual Build and Run
If you prefer to run steps individually:
```bash
# Build the project
make all

# Run the image processor
./image_processor data/input data/output
```

### 4. Create Submission Package (Windows PowerShell)
Prepares the `submission.zip` file for upload to Coursera.
```powershell
Compress-Archive -Path src, data, Makefile, run.sh, README.md, description.txt, generate_data.py -DestinationPath submission.zip -Force
```

## Project Structure
- `src/`: Source code implementation (`main.cu`, `image_io.cpp`).
- `include/`: Header files for image utility and CUDA definitions.
- `data/`:
  - `input/`: Place your raw PPM (P6) images here.
  - `output/`: Processed Sobel edge maps will be saved here.
- `Makefile`: Build system compliant with standard NVCC toolchains.
- `run.sh`: Automated build and execution script for Linux/Coursera environments.
- `generate_data.py`: Utility to generate synthetic test data.

## Scientific Accuracy & Performance
- **Algorithm**: The use of NPP ensures that image processing algorithms follow industry-standard implementations (e.g., Luma weighted grayscale).
- **GPU Acceleration**: By using 2D memory copies (`cudaMemcpy2D`) and NPP's optimized primitive calls, the application achieves high memory throughput and low latency per image.

## License
MIT License
