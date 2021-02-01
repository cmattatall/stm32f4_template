cmake_minimum_required(VERSION 3.16)

add_executable(firmware)
target_sources(firmware PUBLIC main.c)
target_link_libraries(firmware PRIVATE cmsis_device)
target_link_libraries(firmware PRIVATE stm32_hal)
target_link_libraries(firmware PRIVATE cmsis_dsp)
target_link_libraries(firmware PRIVATE freeRTOS)