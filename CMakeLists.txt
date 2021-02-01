cmake_minimum_required(VERSION 3.18)

option(USE_HAL_API "Option to use HAL DRIVER" ON)
option(USE_LL_API "Option to use the HAL API rather than the LL API" ON)
option(USE_ARM_MATH "Option to use CMSIS ARM MATH DSP LIBRARY" ON)
option(USE_RTOS "Option to use CMSIS FreeRTOS Port (port V2 is default)" ON)
option(RTOS_USE_HEAP_ALLOC "Option to support a dynamic memory allocation scheme within RTOS" OFF)
option(CMAKE_VERBOSE_MAKEFILE "Option to emit verbose makefile info" OFF)
option(CMAKE_CROSSCOMPILING "Option to cross compile" ON)

project(
    PUT_YOUR_TOP_LEVEL_PROJECT_NAME_HERE
    DESCRIPTION "PUT YOUR TOP LEVEL PROJECT DESCRIPTION HERE"
    LANGUAGES C ASM
)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

message("Configuring project : ${PROJECT_NAME}")

# @todo MAKE THESE A FUNCTION OF A DEVICE-PACKAGE-SPECIFIC INPUT CONFIG FILE
set(stm32cube_dir STM32CubeF4)
set(stm32cube_hal_dir STM32F4xx_HAL_Driver)
set(cmsis_device_dir STM32F4xx)


# Make path lengths more readable in script
set(cmsis_dsp_root    "${stm32cube_dir}/Drivers/CMSIS/DSP")
set(stm32_hal_root    "${stm32cube_dir}/Drivers/${stm32cube_hal_dir}")
set(cmsis_device_root "${stm32cube_dir}/Drivers/CMSIS/Device/ST/${cmsis_device_dir}/")
set(freertos_root     "${stm32cube_dir}/Middlewares/Third_Party/FreeRTOS/Source")

set(rtos_port_dir "${freertos_root}/portable")

mark_as_advanced(
    stm32cube_dir
    stm32cube_hal_dir
    cmsis_device_dir
    cmsis_dsp_root
    stm32_hal_root
    cmsis_device_root
    freertos_root
    rtos_port_dir
    rtos_port_common_dir
    rtos_port_compiler_dir
    rtos_port_cpu_dir
)


execute_process(
    COMMAND "git" "submodule" "update" "--remote" "--recursive"
    RESULT_VARIABLE GIT_SUBMODULE_UPDATE_FAILED
    OUTPUT_VARIABLE GIT_SUBMODULE_UPDATE_OUTPUT
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ECHO_OUTPUT_VARIABLE
)
execute_process(COMMAND "sync")


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





## RTOS CONFIGURATION
if(USE_RTOS)

    # shared directories between core and port
    add_library(freeRTOS_shared INTERFACE)
    target_include_directories(freeRTOS_shared INTERFACE "${freertos_root}/include/")
    target_link_libraries(freeRTOS_shared INTERFACE project_config)


    ############################################################################
    # RTOS PORT 
    #(usually this will have to be configured by user based on device)
    ############################################################################
    add_library(freeRTOS_port STATIC )
    target_sources(freeRTOS_port PUBLIC "${rtos_port_dir}/GCC/ARM_CM4F/port.c")
    target_include_directories(freeRTOS_port PUBLIC "${rtos_port_dir}/GCC/ARM_CM4F")
    target_link_libraries(freeRTOS_port PUBLIC freeRTOS_shared)


    ############################################################################
    # RTOS CORE
    ############################################################################
    add_library(freeRTOS STATIC)
    target_include_directories(freeRTOS PUBLIC "${freertos_root}/CMSIS_RTOS_V2/")
    target_sources(freeRTOS PUBLIC
        "${freertos_root}/croutine.c"
        "${freertos_root}/event_groups.c"
        "${freertos_root}/list.c"
        "${freertos_root}/queue.c"
        "${freertos_root}/stream_buffer.c"
        "${freertos_root}/tasks.c"
        "${freertos_root}/timers.c"
    )

    # memory management scheme
    if(RTOS_USE_HEAP_ALLOC)
        target_sources(freeRTOS PUBLIC "${rtos_port_dir}/MemMang/heap_4.c")
    endif(RTOS_USE_HEAP_ALLOC)

    target_link_libraries(freeRTOS PUBLIC freeRTOS_shared)
    target_link_libraries(freeRTOS PUBLIC freeRTOS_port)

endif(USE_RTOS)

add_subdirectory(FolderThatContainsTheMainFirmwareProject)
