from numba import cuda
import numpy as np

@cuda.jit
def hello_cuda(data):
    pos = cuda.grid(1)
    if pos < data.size:
        data[pos] += 1

def main():
    data = np.zeros(10)
    threadsperblock = 32
    blockspergrid = 1
    
    try:
        d_data = cuda.to_device(data)
        hello_cuda[blockspergrid, threadsperblock](d_data)
        result = d_data.copy_to_host()
        print("CUDA Result:", result)
        print("Numba CUDA is Working!")
    except Exception as e:
        print("Numba CUDA failed:", e)

if __name__ == "__main__":
    main()
