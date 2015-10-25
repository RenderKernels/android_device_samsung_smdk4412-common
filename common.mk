PRODUCT_KERNEL_SOURCE := kernel/samsung/smdk4x12
CROSS_COMPILE := $(ANDROID_BUILD_TOP)/toolchains/arm-cortex_a9-linux-gnueabihf-linaro_4.9/bin/arm-cortex_a9-linux-gnueabihf-
ARCH := arm
ZIMAGE := arch/arm/boot/zImage
ZIP_FILES_DIR := device/samsung/smdk4412/zip_files_dir
TARGET_REQUIRES_DTB := true

include vendor/render/configs/common.mk
