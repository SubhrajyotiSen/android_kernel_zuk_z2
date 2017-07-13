#!/bin/bash
kernel_version="Beta-1"
kernel_name="Heliox"
device_name="Z2_Plus"
zip_name="$kernel_name-$device_name-$kernel_version.zip"

# ccache
export USE_CCACHE=1
export CCACHE_DIR=/home/ccache/subhrajyoti

export HOME="/home/subhrajyoti"
export CONFIG_FILE="heliox_z2_plus_defconfig"
export ARCH="arm64"
export KBUILD_BUILD_USER="Subhrajyoti"
export KBUILD_BUILD_HOST="Beast"
export TOOLCHAIN_PATH="${HOME}/aarch64-linux-gnu-linaro-7.x"
export CROSS_COMPILE=$TOOLCHAIN_PATH/bin/aarch64-linux-gnu-
export CONFIG_ABS_PATH="arch/${ARCH}/configs/${CONFIG_FILE}"
export objdir="$HOME/kernel/obj"
export sourcedir="$HOME/kernel/zuk"
export anykernel="$HOME/kernel/zuk/anykernel"
compile() {
  make O=$objdir  $CONFIG_FILE -j4
  make O=$objdir -j4
}
clean() {
  make O=$objdir CROSS_COMPILE=${CROSS_COMPILE}  $CONFIG_FILE -j4
  make O=$objdir mrproper
  make O=$objdir clean
}
module_stock(){
  rm -rf $anykernel/modules/
  mkdir $anykernel/modules
  find $objdir -name '*.ko' -exec cp -av {} $anykernel/modules/ \;
  # strip modules
  ${CROSS_COMPILE}strip --strip-unneeded $anykernel/modules/*
  cp -rf $objdir/arch/$ARCH/boot/Image.gz-dtb $anykernel/zImage
}
module(){
  mkdir modules
  find . -name '*.ko' -exec cp -av {} modules/ \;
  # strip modules 
  ${TOOL_CHAIN_PATH}/${CROSS_COMPILE}strip --strip-unneeded modules/*
  #mkdir modules/qca_cld
  #mv modules/wlan.ko modules/qca_cld/qca_cld_wlan.ko
}
dtbuild(){
  cd $sourcedir
  ./tools/dtbToolCM -2 -o $objdir/arch/arm64/boot/dt.img -s 4096 -p $objdir/scripts/dtc/ $objdir/arch/arm64/boot/dts/
}
compile 
cd ../
module
#dtbuild
#cp $objdir/arch/arm64/boot/zImage $sourcedir/zImage
#cp $objdir/arch/arm64/boot/dt.img.lz4 $sourcedir/dt.img
