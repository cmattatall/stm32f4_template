# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.18

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Disable VCS-based implicit rules.
% : %,v


# Disable VCS-based implicit rules.
% : RCS/%


# Disable VCS-based implicit rules.
% : RCS/%,v


# Disable VCS-based implicit rules.
% : SCCS/s.%


# Disable VCS-based implicit rules.
% : s.%


.SUFFIXES: .hpux_make_needs_suffix_list


# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/bin/cmake

# The command to remove a file.
RM = /usr/local/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/carl/Desktop/tmp

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/carl/Desktop/tmp/build

# Include any dependencies generated for this target.
include CMakeFiles/cmsis_device.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/cmsis_device.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/cmsis_device.dir/flags.make

CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f411xe.s.obj: CMakeFiles/cmsis_device.dir/flags.make
CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f411xe.s.obj: ../STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f411xe.s
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/carl/Desktop/tmp/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building ASM object CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f411xe.s.obj"
	/opt/gcc-arm-none-eabi-9-2019-q4-major/bin/arm-none-eabi-gcc --sysroot=/opt/gcc-arm-none-eabi-9-2019-q4-major/arm-none-eabi $(ASM_DEFINES) $(ASM_INCLUDES) $(ASM_FLAGS) -o CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f411xe.s.obj -c /home/carl/Desktop/tmp/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f411xe.s

CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c.obj: CMakeFiles/cmsis_device.dir/flags.make
CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c.obj: ../STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/carl/Desktop/tmp/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Building C object CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c.obj"
	/opt/gcc-arm-none-eabi-9-2019-q4-major/bin/arm-none-eabi-gcc --sysroot=/opt/gcc-arm-none-eabi-9-2019-q4-major/arm-none-eabi $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c.obj -c /home/carl/Desktop/tmp/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c

CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c.i"
	/opt/gcc-arm-none-eabi-9-2019-q4-major/bin/arm-none-eabi-gcc --sysroot=/opt/gcc-arm-none-eabi-9-2019-q4-major/arm-none-eabi $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/carl/Desktop/tmp/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c > CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c.i

CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c.s"
	/opt/gcc-arm-none-eabi-9-2019-q4-major/bin/arm-none-eabi-gcc --sysroot=/opt/gcc-arm-none-eabi-9-2019-q4-major/arm-none-eabi $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/carl/Desktop/tmp/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c -o CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c.s

# Object files for target cmsis_device
cmsis_device_OBJECTS = \
"CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f411xe.s.obj" \
"CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c.obj"

# External object files for target cmsis_device
cmsis_device_EXTERNAL_OBJECTS =

libcmsis_device.a: CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f411xe.s.obj
libcmsis_device.a: CMakeFiles/cmsis_device.dir/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c.obj
libcmsis_device.a: CMakeFiles/cmsis_device.dir/build.make
libcmsis_device.a: CMakeFiles/cmsis_device.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/carl/Desktop/tmp/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Linking C static library libcmsis_device.a"
	$(CMAKE_COMMAND) -P CMakeFiles/cmsis_device.dir/cmake_clean_target.cmake
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/cmsis_device.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/cmsis_device.dir/build: libcmsis_device.a

.PHONY : CMakeFiles/cmsis_device.dir/build

CMakeFiles/cmsis_device.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/cmsis_device.dir/cmake_clean.cmake
.PHONY : CMakeFiles/cmsis_device.dir/clean

CMakeFiles/cmsis_device.dir/depend:
	cd /home/carl/Desktop/tmp/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/carl/Desktop/tmp /home/carl/Desktop/tmp /home/carl/Desktop/tmp/build /home/carl/Desktop/tmp/build /home/carl/Desktop/tmp/build/CMakeFiles/cmsis_device.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/cmsis_device.dir/depend

