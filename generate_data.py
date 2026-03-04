import os
import struct
import random

def create_ppm(filename, width, height):
    with open(filename, 'wb') as f:
        f.write(f"P6\n{width} {height}\n255\n".encode())
        for _ in range(width * height):
            r = random.randint(0, 255)
            g = random.randint(0, 255)
            b = random.randint(0, 255)
            f.write(struct.pack('BBB', r, g, b))

def main():
    input_dir = "data/input"
    if not os.path.exists(input_dir):
        os.makedirs(input_dir)
    
    print(f"Generating 20 sample images in {input_dir}...")
    for i in range(20):
        filename = os.path.join(input_dir, f"img_{i:03d}.ppm")
        # Random sizes to test robustness
        w = random.randint(256, 512)
        h = random.randint(256, 512)
        create_ppm(filename, w, h)
    print("Done.")

if __name__ == "__main__":
    main()
