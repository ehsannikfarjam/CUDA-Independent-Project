NVCC = nvcc
CXX = g++

# Handle environment differences between Windows and Linux
# If CUDA_PATH is not set (typical on Linux), use /usr/local/cuda
CUDA_ROOT ?= /usr/local/cuda
ifdef CUDA_PATH
    CUDA_ROOT = $(CUDA_PATH)
endif

CUDA_INC = -I"$(CUDA_ROOT)/include"
CUDA_LIB = -L"$(CUDA_ROOT)/lib64" -L"$(CUDA_ROOT)/lib/x64" -L"$(CUDA_ROOT)/lib"

# Libraries for NPP (Order matters for linking)
LIBS = -lnppif -lnppig -lnppim -lnppist -lnppidei -lnppicc -lnppial -lnppc -lcudart

CXXFLAGS = -O3 -std=c++17
NVCCFLAGS = -O3 -std=c++17

TARGET = image_processor
SRC_DIR = src
OBJ_DIR = obj

SRCS = $(SRC_DIR)/main.cu $(SRC_DIR)/image_io.cpp
OBJS = $(OBJ_DIR)/main.o $(OBJ_DIR)/image_io.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(NVCC) $(NVCCFLAGS) -o $@ $^ $(CUDA_LIB) $(LIBS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) $(CUDA_INC) -c -o $@ $<

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cu
	mkdir -p $(OBJ_DIR)
	$(NVCC) $(NVCCFLAGS) $(CUDA_INC) -c -o $@ $<

clean:
	rm -rf $(OBJ_DIR)
	rm -f $(TARGET)
