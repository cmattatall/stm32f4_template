#!/bin/bash
#brief example bash script so I don't have to manually type in the cmake generation + build commands
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=arm_none_eabi_toolchain.cmake -DTARGET_CONFIG_FILE=./mcu_config.cmake && cmake --build build
