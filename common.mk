PRODUCT_KERNEL_SOURCE := kernel/samsung/smdk4x12
CROSS_COMPILE := $(ANDROID_BUILD_TOP)/toolchains/arm-cortex_a9-linux-gnueabihf-linaro_4.9/bin/arm-cortex_a9-linux-gnueabihf-
ARCH := arm
ZIMAGE := arch/arm/boot/zImage
ZIP_FILES_DIR := device/samsung/smdk4412-common/zip_files_dir

BOARD_KERNEL_BASE := $(shell cat device/samsung/smdk4412-common/boot.img-base)
BOARD_KERNEL_PAGESIZE := $(shell cat device/samsung/smdk4412-common/boot.img-pagesize)
BOARD_KERNEL_CMDLINE := $(shell cat device/samsung/smdk4412-common/boot.img-cmdline)
BOARD_RAMDISK_DIR := device/samsung/smdk4412-common/boot.img-ramdisk

.PHONY: buildzip
buildzip: buildbootimg
		$(mv-modules)
		$(clear_boot-ramdisk)
		$(build-zip)

include vendor/render/configs/common.mk
