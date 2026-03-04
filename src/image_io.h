#ifndef IMAGE_IO_H
#define IMAGE_IO_H

#include <string>
#include <vector>
#include <cstdint>

/**
 * @brief Simple PPM Image structure
 */
struct PPMImage {
    int width;
    int height;
    int channels; // 3 for RGB, 1 for Grayscale
    std::vector<uint8_t> data;
};

/**
 * @brief Utility for reading and writing PPM images
 */
class ImageIO {
public:
    static bool readPPM(const std::string& filename, PPMImage& image);
    static bool writePPM(const std::string& filename, const PPMImage& image);
};

#endif // IMAGE_IO_H
