cmake_minimum_required(VERSION 3.18)

option(USE_HAL_API "Option to use HAL DRIVER" ON)
option(USE_LL_API "Option to use the HAL API rather than the LL API" ON)
option(USE_ARM_MATH "Option to use CMSIS ARM MATH DSP LIBRARY" ON)


project(test 
    LANGUAGES C ASM
)


# @todo MAKE FUNCTION OF INPUT CONFIG FILE (per target-dev basis)
set(cmsis_dsp_root "STM32CubeF4/Drivers/CMSIS/DSP")
set(stm32_hal_root "STM32CubeF4/Drivers/STM32F4xx_HAL_Driver")
set(cmsis_device_root "STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/")


execute_process(
    COMMAND "git" "submodule" "update" "--remote" "--recursive"
    RESULT_VARIABLE GIT_SUBMODULE_UPDATE_FAILED
    OUTPUT_VARIABLE GIT_SUBMODULE_UPDATE_OUTPUT
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ECHO_OUTPUT_VARIABLE
)
execute_process(COMMAND "sync")

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# explicit interface target for shared include path dependencies
add_library(project_config INTERFACE)
target_include_directories(project_config INTERFACE "config")


#cmsis core is just a header-only compat layer
add_library(cmsis_core INTERFACE)
target_include_directories(cmsis_core INTERFACE "STM32CubeF4/Drivers/CMSIS/Include")

# cmsis device has stuff populated by vendor
add_library(cmsis_device STATIC)
target_include_directories(cmsis_device PUBLIC "${cmsis_device_root}/Include")
target_sources(cmsis_device PRIVATE "${cmsis_device_root}/Source/Templates/gcc/startup_stm32f411xe.s")
target_sources(cmsis_device PUBLIC "${cmsis_device_root}/Source/Templates/system_stm32f4xx.c")
target_compile_definitions(cmsis_device PUBLIC "STM32F411xE")
target_link_libraries(cmsis_device PUBLIC cmsis_core)


# cmsis dsp
if(USE_ARM_MATH)
    add_library(cmsis_dsp STATIC)
    target_include_directories(cmsis_dsp PUBLIC "${cmsis_dsp_root}/Include")
    file(GLOB_RECURSE cmsis_dsp_sources 
        "${cmsis_dsp_root}/Source/arm_*.c" 
        "${cmsis_dsp_root}/Source/arm_*.s" 
        "${cmsis_dsp_root}/Source/arm_*.S"
    )
    target_sources(cmsis_dsp PUBLIC ${cmsis_dsp_sources})

    # for some reason, the bastards didn't explicitly include stdint in their C files...
    target_precompile_headers(cmsis_dsp PUBLIC <stdint.h>)

    # NOT IDEAL, BUT THE ACTUAL SOURCE FILES DON'T INCLUDE THE DEVICE HEADER...
    # @todo NEED TO FIND A BETTER WAY TO DO THIS IN THE FUTURE      
    target_precompile_headers(cmsis_dsp PUBLIC "${cmsis_device_root}/Include/stm32f4xx.h")

    # get FPU config and defines from device target
    target_link_libraries(cmsis_dsp PUBLIC cmsis_device)

    # @todo SHOULD BE MADE PART OF AN INPUT CMAKE CONFIG FILE
    target_compile_definitions(cmsis_dsp PUBLIC "ARM_MATH_CM4") # this will change based on your processor. 

endif(USE_ARM_MATH)


if(USE_HAL_API OR USE_LL_API)
    add_library(stm32_hal STATIC)

    # @todo SHOULD BE MADE PART OF AN INPUT CMAKE CONFIG FILE
    target_compile_definitions(stm32_hal PRIVATE "STM32F411xE") # this will change based on your processor. 

    target_include_directories(stm32_hal PUBLIC "${stm32_hal_root}/Inc")
    target_include_directories(stm32_hal PUBLIC "${stm32_hal_root}/Inc/Legacy")

    if(USE_HAL_API)
        set(hal_src_glob_expr "*_hal_[^(template_)]*\.c")
    elseif(USE_LL_API)
        set(hal_src_glob_expr "*_ll_[^(template_)]*\.c")
    else()
        message(DEBUG "CMake Developer made a logic error ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE}")
    endif()
    file(GLOB_RECURSE stm32_hal_sources "${stm32_hal_root}/Src/${hal_src_glob_expr}")
    target_sources(stm32_hal PUBLIC ${stm32_hal_sources})
    target_link_libraries(stm32_hal PUBLIC cmsis_device)
    target_link_libraries(stm32_hal PUBLIC project_config)
endif(USE_HAL_API OR USE_LL_API)


add_executable(firmware)
target_sources(firmware PUBLIC main.c)
target_link_libraries(firmware PRIVATE cmsis_device)
target_link_libraries(firmware PRIVATE stm32_hal)
target_link_libraries(firmware PRIVATE cmsis_dsp)

