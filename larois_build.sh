#!/bin/bash

# Environment variable
echo " "
echo -e "Environment variable prepared.\n"

LLVM_PATH="/home/joaquimiguel/toolchains/zyc-clang-15.0.7/bin/"

HOST_BUILD_ENV="ARCH=arm64 \
                CC=${LLVM_PATH}clang \
                CROSS_COMPILE=${LLVM_PATH}aarch64-linux-gnu- \
                LLVM=1 \
                LLVM_IAS=1 \
                PATH=$LLVM_PATH:$PATH \
                -j$(nproc --all)"

KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

OUT_DIR="$(pwd)/out"
BOOT_DIR="$OUT_DIR/arch/arm64/boot"
DTS_DIR="$BOOT_DIR/dts/vendor/qcom"
AK3_DIR="$(pwd)/AnyKernel3"
DEFCONFIG="vendor/kona-larois_defconfig vendor/samsung/kona-sec-common.config vendor/samsung/r8q.config"

# Clear old build
echo -e "Old build cleaned up.\n"

rm -rf "$AK3_DIR/Image"
rm -rf "$AK3_DIR/kona.dtb"
rm -rf "$AK3_DIR/dtbo.img"
rm -rf .version .local

# Execute make clean && mrproper question
read -p "Execute make clean && mrproper? (Y/n): " r
case "$r" in Y|y) make clean && make mrproper;; N|n) echo "Aborted.";; esac

# Clear /out question
echo " "

read -p "Execute rm -rf out? (Y/n): " r
case "$r" in Y|y) "rm -rf $OUT_DIR";; N|n) echo "Aborted.";; esac

# Build defconfig
echo " "
echo -e "Building defconfig...\n"

make O="$OUT_DIR" $HOST_BUILD_ENV $DEFCONFIG

# Starting compilation
echo " "
echo -e "Starting compilation...\n"

make -j12 O="$OUT_DIR" $KERNEL_MAKE_ENV $HOST_BUILD_ENV dtbo.img

make -j12 O="$OUT_DIR" $KERNEL_MAKE_ENV $HOST_BUILD_ENV Image

ls "$BOOT_DIR"

# Package Kernel
echo " "
echo -e "Preparing zip...\n"

cp "$BOOT_DIR/Image" "$AK3_DIR/Image"
cp "$BOOT_DIR/dtbo.img" "$AK3_DIR/dtbo.img"
cat $(find "$DTS_DIR" -type f -name "*.dtb" | sort) > "$BOOT_DIR/kona.dtb"
cp "$BOOT_DIR/kona.dtb" "$AK3_DIR/kona.dtb"

build_date=$(date +%Y%m%d)
gitsha=$(git rev-parse --short=7 HEAD)

cd "$AK3_DIR" || exit 1
rm -f *.zip

zip -r9 "Larois-${build_date}-${gitsha}-r8q.zip" .

# Build completed
echo " "
echo "Build finished sucessfully."
