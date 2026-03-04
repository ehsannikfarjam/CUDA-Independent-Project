#include "image_io.h"
#include <fstream>
#include <iostream>
#include <sstream>

bool ImageIO::readPPM(const std::string &filename, PPMImage &image) {
  std::ifstream ifs(filename, std::ios::binary);
  if (!ifs.is_open()) {
    std::cerr << "Error: Could not open file " << filename << std::endl;
    return false;
  }

  std::string header;
  ifs >> header;
  if (header != "P6") {
    std::cerr << "Error: Only P6 PPM files are supported" << std::endl;
    return false;
  }

  // Skip comments
  char ch;
  ifs.get(ch);
  while (ifs.peek() == '#') {
    std::string comment;
    std::getline(ifs, comment);
  }

  int maxColor;
  ifs >> image.width >> image.height >> maxColor;
  if (maxColor != 255) {
    std::cerr << "Error: Only 8-bit PPM files are supported" << std::endl;
    return false;
  }

  // Finish reading the whitespace after the header
  ifs.get(ch);

  image.channels = 3;
  image.data.resize(image.width * image.height * image.channels);
  ifs.read(reinterpret_cast<char *>(image.data.data()), image.data.size());

  return true;
}

bool ImageIO::writePPM(const std::string &filename, const PPMImage &image) {
  std::ofstream ofs(filename, std::ios::binary);
  if (!ofs.is_open()) {
    std::cerr << "Error: Could not open file for writing: " << filename
              << std::endl;
    return false;
  }

  // P6 for RGB, P5 for Grayscale
  std::string header = (image.channels == 3) ? "P6" : "P5";
  ofs << header << "\n" << image.width << " " << image.height << "\n255\n";

  ofs.write(reinterpret_cast<const char *>(image.data.data()),
            image.data.size());

  return true;
}
