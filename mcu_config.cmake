#config file to provide configuration options for target device

set(TARGET_CONFIG_LINKER_SCRIPT "/home/carl/Desktop/Dev/cmake/linker.ld")
set(TARGET_CONFIG_ARCH_OPTIONS "-mlittle-endian --specs=nosys.specs -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16")

#add_definitions(ARM_MATH_CM4)