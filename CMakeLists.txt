cmake_minimum_required(VERSION 3.18)


option(USE_HAL_DRIVER "Option to use HAL DRIVER" ON)

project(test 
    LANGUAGES C ASM
)


add_library(cmsis_core INTERFACE)
target_include_directories(cmsis_core INTERFACE "STM32CubeF4/Drivers/CMSIS/Include")


add_library(cmsis_device STATIC)
set(cmsis_device_root "STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/")
target_include_directories(cmsis_device PUBLIC "${cmsis_device_root}/Include")
target_sources(cmsis_device PRIVATE "${cmsis_device_root}/Source/Templates/gcc/startup_stm32f411xe.s")
target_sources(cmsis_device PUBLIC "${cmsis_device_root}/Source/Templates/system_stm32f4xx.c")
target_compile_definitions(cmsis_device PUBLIC "STM32F411xE")

target_link_libraries(cmsis_device PUBLIC cmsis_core)



#[[
add_library(stm32_hal STATIC)

target_sources(stm32_hal PRIVATE "STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c")
target_sources(stm32_hal PRIVATE "STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f411xe.s")

target_link_libraries(stm32_hal PUBLIC "STM32CubeF4/Drivers/CMSIS/Lib/GCC/libarm_cortexM4l_math.a")
#target_link_libraries(stm32_hal PUBLIC "STM32CubeF4/Drivers/CMSIS/Lib/GCC/libarm_cortexM4lf_math.a")


target_include_directories(stm32_hal PUBLIC  "STM32CubeF4/Drivers/CMSIS/Include/")
target_include_directories(stm32_hal PUBLIC  "STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Include/")
target_include_directories(stm32_hal PUBLIC  "STM32CubeF4/Drivers/CMSIS/Lib/GCC")

target_include_directories(stm32_hal PUBLIC "STM32CubeF4/Drivers/STM32F4xx_HAL_Driver/Inc/")
target_include_directories(stm32_hal PUBLIC "STM32CubeF4/Drivers/STM32F4xx_HAL_Driver/Inc/Legacy")

target_compile_definitions(stm32_hal PRIVATE "STM32F411xE")

target_compile_definitions(stm32_hal PRIVATE "ARM_MATH_CM4")


if(USE_HAL_DRIVER)
    set(CUBE_SRC_REGEX ".*_hal*\\.c$")
else()
    set(CUBE_SRC_REGEX ".*_ll*\\.c$")
endif(USE_HAL_DRIVER)
file(GLOB_RECURSE cube_sources "STM32CubeF4/Drivers/STM32F4xx_HAL_Driver/Src/${CUBE_SRC_REGEX}")
foreach(src_file ${cube_sources})
    string(REGEX MATCH ".*template.c" SOURCE_FILE_IS_TEMPLATE ${src_file})
    if(SOURCE_FILE_IS_TEMPLATE)
        list(REMOVE_ITEM cube_sources ${src_file})
    endif() 
endforeach(src_file ${cube_sources})

target_sources(stm32_hal PRIVATE "${cube_sources}")


target_precompile_headers(stm32_hal
  PUBLIC
    <stdint.h>
  PRIVATE
)

target_include_directories(stm32_hal PUBLIC "STM32CubeF4/Drivers/CMSIS/DSP/Include")

file(GLOB_RECURSE dsp_sources 
    "STM32CubeF4/Drivers/CMSIS/DSP/Source/*.c" 
    "STM32CubeF4/Drivers/CMSIS/DSP/Source/*.S" 
    "STM32CubeF4/Drivers/CMSIS/DSP/Source/*.s"
)
target_sources(stm32_hal PRIVATE ${dsp_sources})

#]]


#[[
add_executable(firmware)
target_sources(firmware PUBLIC main.c)
target_link_libraries(firmware PRIVATE stm32_hal)

#]]