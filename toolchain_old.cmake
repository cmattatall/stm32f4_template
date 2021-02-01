# CMAKE TOOLCHAIN FILE FOR ${TOOLCHAIN_PREFIX}-gcc
# AUTHOR: Carl Mattatall (cmattatall2@gmail.com) 

macro(listToOptionString list_string)
    string(REPLACE ";" "\ " list_as_string "${${list_string}}")
    set(${list_string} ${list_as_string})
endmacro(listToOptionString list)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)
set(CMAKE_CROSSCOMPILING ON)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(TOOLCHAIN_PREFIX arm-none-eabi)
set(CMAKE_C_COMPILER_NAME ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_ASM_COMPILER_NAME ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER_NAME ${TOOLCHAIN_PREFIX}-g++)
set(CMAKE_OBJCOPY_NAME ${TOOLCHAIN_PREFIX}-objcopy)
set(CMAKE_OBJDUMP_NAME ${TOOLCHAIN_PREFIX}-objdump)
set(CMAKE_SIZE_NAME ${TOOLCHAIN_PREFIX}-size)
set(CMAKE_GDB_NAME ${TOOLCHAIN_PREFIX}-gdb) #might also have gdb.py extension

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

if(MINGW OR CYGWIN OR WIN32)
    set(UTIL_SEARCH_CMD where)
elseif(UNIX AND NOT APPLE)
    set(UTIL_SEARCH_CMD which)
elseif(APPLE)
    message(FATAL ERROR "THIS CMAKE TOOLCHAIN DOES NOT HAVE SUPPORT FOR APPLE YET")
endif()

execute_process(
    COMMAND ${UTIL_SEARCH_CMD} ${TOOLCHAIN_PREFIX}-gcc
    OUTPUT_VARIABLE TOOLCHAIN_BIN_SYMLINK_PATH
    OUTPUT_STRIP_TRAILING_WHITESPACE)
if(TOOLCHAIN_BIN_SYMLINK_PATH STREQUAL "")
    message(FATAL_ERROR "${TOOLCHAIN_PREFIX}-gcc could not be found. Please make sure that ${TOOLCHAIN_PREFIX} toolchain is installed")
endif()

if(MINGW OR CYGWIN OR WIN32)
    execute_process(
        COMMAND "(Get-Item ${TOOLCHAIN_BIN_SYMLINK_PATH}).Target"
        OUTPUT_VARIABLE TOOLCHAIN_BINUTILS_PATH
        OUTPUT_STRIP_TRAILING_WHITESPACE)
elseif(UNIX AND NOT APPLE)
    execute_process(
        COMMAND "readlink" "-f" "${TOOLCHAIN_BIN_SYMLINK_PATH}"
        OUTPUT_VARIABLE TOOLCHAIN_BINUTILS_PATH
        OUTPUT_STRIP_TRAILING_WHITESPACE)
elseif(APPLE)
    message(FATAL ERROR "THIS CMAKE TOOLCHAIN DOES NOT HAVE SUPPORT FOR APPLE YET")
endif()

if(TOOLCHAIN_BINUTILS_PATH STREQUAL "")
    message(FATAL_ERROR "FOLLOWING SYMLINKS FROM \"${TOOLCHAIN_BIN_SYMLINK_PATH}\" DID NOT PRODUCE ANY RESULTS")
elseif()
    message("TOOLCHAIN_BINUTILS_PATH = \"${TOOLCHAIN_BINUTILS_PATH}\"")
endif()

get_filename_component(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_BINUTILS_PATH} DIRECTORY)
get_filename_component(TOOLCHAIN_SYSROOT ${TOOLCHAIN_BIN_DIR} DIRECTORY)
set(CMAKE_SYSROOT ${TOOLCHAIN_SYSROOT})

find_program(CMAKE_C_COMPILER ${CMAKE_C_COMPILER_NAME} REQUIRED)
find_program(CMAKE_ASM_COMPILER ${CMAKE_ASM_COMPILER_NAME} REQUIRED)
find_program(CMAKE_CXX_COMPILER ${CMAKE_CXX_COMPILER_NAME} REQUIRED)
find_program(CMAKE_OBJCOPY ${CMAKE_OBJCOPY_NAME} REQUIRED)
find_program(CMAKE_OBJDUMP ${CMAKE_OBJDUMP_NAME} REQUIRED)
find_program(CMAKE_SIZE ${CMAKE_SIZE_NAME} REQUIRED)


#@todo SHOULD PROBABLY BE PROVIDING ARCH OPTIONS VIA A FILE
set(arch_options 
    "-mlittle-endian" 
    "-mthumb" 
    "-mcpu=cortex-m4" 
    "-mfloat-abi=hard" 
    "-mfpu=fpv4-sp-d16"
    )
listToOptionString(arch_options)


# I want to add -fsanitize=address but for some reason is has not yet been ported to arm-none-eabi-gcc 
# https://answers.launchpad.net/gcc-arm-embedded/+question/258875
set(warning_options "-Wall")

set(platform_options 
    "-mthumb-interwork" 
    # emit instructions that support both ARM and THUMB ISA 



    "-ffunction-sections" 
    # generate separate ELF sections for each function in a translation unit
    # THIS LETS US PLACE VECTOR TABLE 
    #using __attribute__(section("name"))

    "-fdata-sections"      
    # generate separate ELF sections for each variable in a translation unit
    
    "--specs=nosys.specs"
    # Don't use newlib or libc calls to generate startup code
    # startup assembly is explicitly provided as a translation unit

    "-ffreestanding"    
    # Do not assume libc symbol existence when linking
    )
listToOptionString(platform_options)

set(CMAKE_C_FLAGS_INIT 
    "${warning_options} ${platform_options} ${arch_options}" 
     CACHE INTERNAL "Initial options for C compiler.")

set(CMAKE_CXX_FLAGS_INIT 
    "${warning_options} ${platform_options} ${arch_options} -fno-rtti -fno-exceptions" 
     CACHE INTERNAL "Base C++ compiler flags")


# Second option enables debugging FreeRTOS threads with openOCD + gdb
set(CMAKE_EXE_LINKER_FLAGS_INIT 
    "-Wl,--gc-sections -Wl,--undefined=uxTopUsedPriority" 
    CACHE INTERNAL "Initial options for executable linker.")