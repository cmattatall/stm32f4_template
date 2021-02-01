#!/bin/bash
#brief example bash script so I don't have to manually type in the cmake generation + build commands
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake && cmake --build build
