set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(TOOLCHAIN_PREFIX arm-none-eabi)

if(MINGW OR CYGWIN OR WIN32)
    set(UTIL_SEARCH_COMMAND where)
elseif(UNIX AND NOT APPLE)
    set(UTIL_SEARCH_COMMAND which)
elseif(APPLE)
    set(UTIL_SEARCH_COMMAND which)
else()
    message(FATAL_ERROR "SYSTEM : ${CMAKE_HOST_SYSTEM_NAME} not supported")
endif()

set(TOOLCHAIN_GCC_EXE ${TOOLCHAIN_PREFIX}-gcc)
execute_process(
    COMMAND ${UTIL_SEARCH_COMMAND} ${TOOLCHAIN_GCC_EXE}
    OUTPUT_VARIABLE TOOLCHAIN_GCC_SYMLINK_PATH
    RESULT_VARIABLE TOOLCHAIN_GCC_SYMLINK_NOT_FOUND
    ECHO_OUTPUT_VARIABLE
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(TOOLCHAIN_GCC_SYMLINK_NOT_FOUND)
    message(FATAL_ERROR "Could not find ${TOOLCHAIN_GCC_EXE}")
endif(TOOLCHAIN_GCC_SYMLINK_NOT_FOUND)

if(MINGW OR CYGWIN OR WIN32)
    # win32 doesn't have the concept of symbolic links
    set(TOOLCHAIN_GCC_TRUE_PATH ${TOOLCHAIN_GCC_SYMLINK_PATH})
elseif(UNIX AND NOT APPLE)
    execute_process(
        COMMAND readlink -f ${TOOLCHAIN_GCC_SYMLINK_PATH}
        OUTPUT_VARIABLE TOOLCHAIN_GCC_TRUE_PATH
        RESULT_VARIABLE TOOLCHAIN_GCC_TRUE_PATH_NOT_FOUND
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
elseif(APPLE)
    message(FATAL_ERROR "Apple not supported yet")
else()
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} not supported")
endif()


if(NOT TOOLCHAIN_GCC_TRUE_PATH)
    message(FATAL_ERROR "TOOLCHAIN_GCC_TRUE_PATH not defined. Something went wrong during toolchain configuration")
endif(NOT TOOLCHAIN_GCC_TRUE_PATH)

if(TOOLCHAIN_GCC_TRUE_PATH_NOT_FOUND)
    message(FATAL_ERROR "Could not follow symlink from ${TOOLCHAIN_GCC_SYMLINK_PATH}")
endif(TOOLCHAIN_GCC_TRUE_PATH_NOT_FOUND)

get_filename_component(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_GCC_TRUE_PATH} DIRECTORY)
get_filename_component(TOOLCHAIN_ROOT ${TOOLCHAIN_BIN_DIR} DIRECTORY)
list(APPEND BINUTILS_SEARCH_HINTS "${TOOLCHAIN_BIN_DIR}")


# SEARCH OPTIONS
set(CMAKE_SYSROOT "${TOOLCHAIN_ROOT}/${TOOLCHAIN_PREFIX}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# BINUTILS NAMES
set(CMAKE_C_COMPILER_NAME ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_ASM_COMPILER_NAME ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER_NAME ${TOOLCHAIN_PREFIX}-g++)
set(CMAKE_OBJCOPY_NAME ${TOOLCHAIN_PREFIX}-objcopy)
set(CMAKE_OBJDUMP_NAME ${TOOLCHAIN_PREFIX}-objdump)
set(CMAKE_SIZE_NAME ${TOOLCHAIN_PREFIX}-size)
set(CMAKE_GDB_NAME ${TOOLCHAIN_PREFIX}-gdb) 


find_program(
    CMAKE_C_COMPILER 
    NAMES ${CMAKE_C_COMPILER_NAME}
    HINTS ${BINUTILS_SEARCH_HINTS}
    REQUIRED
)

find_program(
    CMAKE_ASM_COMPILER 
    ${CMAKE_ASM_COMPILER_NAME}
    HINTS ${BINUTILS_SEARCH_HINTS} 
    REQUIRED
)

find_program(
    CMAKE_CXX_COMPILER 
    NAMES ${CMAKE_CXX_COMPILER_NAME}
    HINTS ${BINUTILS_SEARCH_HINTS} 
    REQUIRED
)

find_program(
    CMAKE_OBJCOPY 
    NAMES ${CMAKE_OBJCOPY_NAME}
    HINTS ${BINUTILS_SEARCH_HINTS} 
    REQUIRED
)

find_program(
    CMAKE_OBJDUMP 
    NAMES ${CMAKE_OBJDUMP_NAME}
    HINTS ${BINUTILS_SEARCH_HINTS} 
    REQUIRED
)

find_program(
    CMAKE_SIZE 
    NAMES ${CMAKE_SIZE_NAME}
    HINTS ${BINUTILS_SEARCH_HINTS} 
    REQUIRED
)

find_program(
    CMAKE_GDB 
    NAMES ${CMAKE_GDB_NAME}
    HINTS ${BINUTILS_SEARCH_HINTS} 
    REQUIRED
)

set(STATIC_LIBRARY_SUFFIX ".static")
set(CMAKE_STATIC_LIBRARY_SUFFIX_C ${STATIC_LIBRARY_SUFFIX})
set(CMAKE_STATIC_LIBRARY_SUFFIX_CXX ${STATIC_LIBRARY_SUFFIX})
mark_as_advanced(CMAKE_STATIC_LIBRARY_SUFFIX_C)
mark_as_advanced(CMAKE_STATIC_LIBRARY_SUFFIX_CXX)
mark_as_advanced(STATIC_LIBRARY_SUFFIX)

# @todo THIS SHOULD BE LATER MADE PART OF A CMAKE.IN CONFIG FILE 
# reference for options https://gcc.gnu.org/onlinedocs/gcc/ARM-Options.html
set(arch_options "-mlittle-endian --specs=nosys.specs -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16")

set(shared_options "-ffunction-sections -fdata-sections")
set(LINKER_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/linker_script.ld")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-Wl,--gc-sections,-T,${LINKER_SCRIPT},-Map=my_mapfile.out")
set(CMAKE_ASM_FLAGS_INIT "${arch_options} ${shared_options}")
set(CMAKE_C_FLAGS_INIT "${arch_options} ${shared_options}")
set(CMAKE_CXX_FLAGS_INIT "${arch_options} ${shared_options} -fno-rtti -fno-exceptions")


if(NOT COMMAND _add_executable)
function(add_executable executable)
    _add_executable(${executable} ${ARGN})

    set(executable_output_name "${executable}.elf")
    set_target_properties(${executable} PROPERTIES OUTPUT_NAME ${executable_output_name})

    if(NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
        set(RUNTIME_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    elseif(CMAKE_BUILD_TYPE)
        string(TO_UPPER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE_UPPER)
        if(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE_UPPER})
            set(RUNTIME_OUTPUT_DIR "${CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE_UPPER}}")
        endif(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE_UPPER})
    else()
        set(RUNTIME_OUTPUT_DIR "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
    endif(NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)

    set(RUNTIME_OUTPUT_OBJDUMP_DIR "${RUNTIME_OUTPUT_DIR}/objdump/${executable}")

    if(NOT EXISTS "${RUNTIME_OUTPUT_DIR}")
        file(MAKE_DIRECTORY "${RUNTIME_OUTPUT_DIR}")
    elseif(NOT IS_DIRECTORY "${RUNTIME_OUTPUT_DIR}")
        file(REMOVE_RECURSE "${RUNTIME_OUTPUT_DIR}")
        file(MAKE_DIRECTORY "${RUNTIME_OUTPUT_DIR}")
    endif()

    if(NOT EXISTS "${RUNTIME_OUTPUT_OBJDUMP_DIR}")
        file(MAKE_DIRECTORY "${RUNTIME_OUTPUT_OBJDUMP_DIR}")
    elseif(NOT IS_DIRECTORY "${RUNTIME_OUTPUT_OBJDUMP_DIR}")
        file(REMOVE_RECURSE "${RUNTIME_OUTPUT_OBJDUMP_DIR}")
        file(MAKE_DIRECTORY "${RUNTIME_OUTPUT_OBJDUMP_DIR}")
    endif()

    add_custom_target(${executable}_postbuild ALL DEPENDS ${executable})
    add_custom_command( 
        TARGET ${executable}_postbuild
        POST_BUILD
        DEPENDS ${executable}
        COMMENT "Built executable \"${executable}\" with the following size:"
        COMMAND ${CMAKE_SIZE} -B "${RUNTIME_OUTPUT_DIR}/${executable_output_name}"
    )

    add_custom_command( 
        TARGET ${executable}_postbuild
        POST_BUILD
        DEPENDS ${executable}
        COMMENT "Produced ihex output from ${executable}"
        COMMAND ${CMAKE_OBJCOPY} -O ihex -I elf32-little "${RUNTIME_OUTPUT_DIR}/${executable_output_name}" "${RUNTIME_OUTPUT_OBJDUMP_DIR}/${executable}.hex"
        BYPRODUCTS "${RUNTIME_OUTPUT_OBJDUMP_DIR}/${executable}.hex"
    )

    add_custom_command( 
        TARGET ${executable}_postbuild
        POST_BUILD
        DEPENDS ${executable}
        COMMENT "Produced binary output from ${executable}"
        COMMAND ${CMAKE_OBJCOPY} -O binary -I elf32-little "${RUNTIME_OUTPUT_DIR}/${executable_output_name}" "${RUNTIME_OUTPUT_OBJDUMP_DIR}/${executable}.bin"
        BYPRODUCTS "${RUNTIME_OUTPUT_OBJDUMP_DIR}/${executable}.bin"
    )

    add_custom_command( 
        TARGET ${executable}_postbuild
        POST_BUILD
        DEPENDS ${executable}
        COMMENT "Produced list file from ${executable}"
        COMMAND ${CMAKE_OBJDUMP} -xh "${RUNTIME_OUTPUT_DIR}/${executable_output_name}" > "${RUNTIME_OUTPUT_OBJDUMP_DIR}/${executable}.lss"
        BYPRODUCTS "${RUNTIME_OUTPUT_OBJDUMP_DIR}/${executable}.lss"
    )

endfunction(add_executable executable)
endif(NOT COMMAND _add_executable)





if(NOT COMMAND _add_library)
function(add_library library)
    _add_library(${library} ${ARGN})

    set(${library}_POSTBUILD_OBJDUMP OFF)
    get_target_property(type ${library} TYPE)
    if(type STREQUAL STATIC_LIBRARY)
        set(libbase "lib${library}")
        set(libname "${libbase}${STATIC_LIBRARY_SUFFIX}")
        set(${library}_POSTBUILD_OBJDUMP ON)
    elseif(type STREQUAL MODULE_LIBRARY)
        set(libbase "lib${library}")
        set(libname "${libbase}${MODULE_LIBRARY_SUFFIX}")
        set(${library}_POSTBUILD_OBJDUMP ON)
    elseif(type STREQUAL SHARED_LIBRARY)
        set(libbase "lib${library}")
        set(libname "${libbase}${SHARED_LIBRARY_SUFFIX}")
        set(${library}_POSTBUILD_OBJDUMP ON)
    elseif(type STREQUAL OBJECT_LIBRARY)
        set(libbase "lib${library}")
        set(libname "${libbase}${OBJECT_LIBRARY_SUFFIX}")
        set(${library}_POSTBUILD_OBJDUMP ON)
    endif()

    if(${library}_POSTBUILD_OBJDUMP)

        if(CMAKE_LIBRARY_OUTPUT_DIRECTORY)
            set(LIBRARY_OUTPUT_DIR "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
        elseif(CMAKE_BUILD_TYPE)
            string(TO_UPPER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE_UPPER)
            if(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE_UPPER})
                set(LIBRARY_OUTPUT_DIR "${CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE_UPPER}}")
            endif(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CMAKE_BUILD_TYPE_UPPER})
        else()
            set(LIBRARY_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}")
        endif()

        message("LIBRARY_OUTPUT_DIR = ${LIBRARY_OUTPUT_DIR}")

        set(LIBRARY_OBJDUMP_OUTPUT_DIR "${LIBRARY_OUTPUT_DIR}/objdump/${library}")

        if(NOT EXISTS "${LIBRARY_OUTPUT_DIR}")
            file(MAKE_DIRECTORY "${LIBRARY_OUTPUT_DIR}")
        elseif(NOT IS_DIRECTORY "${LIBRARY_OUTPUT_DIR}")
            file(REMOVE_RECURSE "${LIBRARY_OUTPUT_DIR}")
            file(MAKE_DIRECTORY "${LIBRARY_OUTPUT_DIR}")
        endif()
        
        if(NOT EXISTS "${LIBRARY_OBJDUMP_OUTPUT_DIR}")
            file(MAKE_DIRECTORY "${LIBRARY_OBJDUMP_OUTPUT_DIR}")
        elseif(NOT IS_DIRECTORY "${LIBRARY_OBJDUMP_OUTPUT_DIR}")
            file(REMOVE_RECURSE "${LIBRARY_OBJDUMP_OUTPUT_DIR}")
            file(MAKE_DIRECTORY "${LIBRARY_OBJDUMP_OUTPUT_DIR}")
        endif()


        # post build tasks
        add_custom_target(${library}_postbuild ALL DEPENDS ${library})
        add_custom_command( 
            TARGET ${library}_postbuild
            POST_BUILD
            DEPENDS ${library}
            COMMENT "Generating lss file for ${library} using ${CMAKE_OBJDUMP}"
            COMMAND ${CMAKE_OBJDUMP} -xh "${LIBRARY_OUTPUT_DIR}/${libname}" > "${LIBRARY_OBJDUMP_OUTPUT_DIR}/${libname}.lss"
            BYPRODUCTS "${LIBRARY_OBJDUMP_OUTPUT_DIR}/${libname}.lss"
        )

    endif(${library}_POSTBUILD_OBJDUMP)
endfunction(add_library library)
endif(NOT COMMAND _add_library)