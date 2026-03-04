#!/bin/bash

# Configuration
INPUT_DIR="data/input"
OUTPUT_DIR="data/output"
EXECUTABLE="./image_processor"

echo "--- CUDA at Scale Independent Project: Batch Image Processing ---"

# 1. Build
echo "[1/3] Building project..."
make clean
make all
if [ $? -ne 0 ]; then
    echo "Error: Build failed."
    exit 1
fi

# 2. Run Processing
echo "[2/3] Running GPU processing pipeline..."
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory $INPUT_DIR not found. Please run generate_data.py if needed."
    exit 1
fi

# Time the execution
START_TIME=$(date +%s.%N)
$EXECUTABLE "$INPUT_DIR" "$OUTPUT_DIR" > execution_log.txt 2>&1
END_TIME=$(date +%s.%N)

# 3. Verification & Submission Prep
echo "[3/3] Verification and Submission Prep..."
echo "Execution Log saved to execution_log.txt"
if [ -f "execution_log.txt" ]; then
    cat execution_log.txt
fi

# Calculate runtime
RUNTIME=$(echo "$END_TIME - $START_TIME" | bc 2>/dev/null || echo "unknown")
echo "------------------------------------------------"
echo "Pipeline completed in $RUNTIME seconds."
echo "Processed images are in $OUTPUT_DIR"
echo "------------------------------------------------"

# Create submission.zip on Linux
echo "Creating submission.zip..."
zip -r submission.zip src data Makefile run.sh README.md description.txt generate_data.py execution_log.txt
echo "Done. You can now download submission.zip for upload."
