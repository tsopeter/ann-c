#include <iostream>
#include <fstream>
#include <string>
#include <vector>

void swap(int *x, int *y) {
    auto z = *x;
    *x = *y;
    *y = z;
}

struct cBuffer {
    std::vector<uint8_t> vec;
    int counter;

    unsigned int read_byte () {
        if (counter >= vec.size())
            counter = 0;
        unsigned int x = vec[counter];
        counter++;
        return x;
    }

    unsigned int read_4_byte () {
        unsigned int x[4] = {
            read_byte(), read_byte(), read_byte(), read_byte()
        };

        // swap
        // swap (x+3, x+0);
        // swap (x+2, x+1);

        // combine
        return x[0] | (x[1] << 8) | (x[2] << 16) | (x[3] << 24);

    }
};

cBuffer store_to_buffer (FILE *st) {
    std::vector<uint8_t> vec;
    static constexpr size_t max_len = 1 << 10;
    uint8_t buffer[max_len] = {};

    int len;
    while ((len = std::fread (buffer, sizeof(uint8_t), max_len, st)) > 0) {
        for (size_t i = 0; i < len; ++i) {
            vec.push_back(buffer[i]);
            buffer[i]=0x00;
        }
    }
    return {
        vec, 0
    };
}

int main () {
    FILE *fd0 = std::fopen ("./Images/train-images-idx3-ubyte.gz", "rb");

    if (fd0 == NULL)
        return -1;

    auto vec = store_to_buffer (fd0);

    std::printf("%hhx\n",vec.vec[0]);

    std::fstream fd1 {"src/images.train.h", std::ios_base::out};
    fd1<<"#ifndef __images_train_h__\n";
    fd1<<"#define __images_train_h__\n";

    std::string varname ="TIM1";

    fd1<<"static const float"<<varname<<"[60000][784]={\n";

    // populate with image



    fd1<<"#endif\n";
    std::fclose(fd0);
    fd1.close();
    return 0;
}