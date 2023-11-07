#ifndef __ann_h__
#define __ann_h__

#define SIMULATED 1

#include "images.h"

float K1[32][784]  = {{}};  // kernels
float B1[32]       = {};
float K2[10][32]   = {{}};
float B2[10]       = {};

float X1[784]      = {};    // image input
float X2[32]       = {};    // output of first layer
float X3[32]       = {};    // output of nonlinear
float X4[10]       = {};    // output of second layer

float dK1[32][784] = {{}};  // difference buffers
float dK2[10][32]  = {{}};
float dB1[32]      = {};
float dB2[10]      = {};
float dX1[784]     = {};
float dX2[32]      = {};

void cpy_im(int index) {
    for (int i = 0; i < 784; ++i) {
        X1[i]=IM[index][i];
    }
}

#if SIMULATED
#include <math.h>
float simulated_nonlinearity(float in) {
    static const float Lo=2.51;
    static const float Le=2.33;
    static const float Psat=0.65;
    return Lo * in * exp(-Le/(1+in/Psat));
}
#endif

void nonlinearity() {
    for (int i = 0; i < 32; ++i) {
        #if SIMULATED
            X2[i]=simulated_nonlinearity(X1[i]);
        #endif
    }
}

int max_index() {
    float max = X4[0];
    float mi  = 0;
    for (int i = 0; i < 10; ++i)
        if (max < X4[i]) {
            max = X4[i];
            mi = i;
        }
    return mi;
}

int forward_propagation (int index) {
    // computes forward propagation
    // index selects an single image and loads
    // into X1
    cpy_im(index);

    // dot and store into X2
    //
    for (int i = 0; i < 32; ++i) {
        float acc=0.0;
        for (int j = 0; j < 784; ++j) {
            acc += X1[j]*K1[i][j];
        }
        X2[i]=acc+B1[i];
    }

    // nonlinearity
    nonlinearity ();

    // dot and store into X3
    //
    for (int i = 0; i < 10; ++i) {
        float acc=0.0;
        for (int j = 0; j < 32; ++j) {
            acc += X3[j]*K2[i][j];
        }
        X4[i]=acc+B2[i];
    }

    // classify
    return max_index();
}

#endif
