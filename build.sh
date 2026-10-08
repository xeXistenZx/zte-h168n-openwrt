#!/bin/sh

# Exit immediately if any command fails
set -e

echo "Cleaning previous workspace..."
rm -rf ./openwrt
mkdir openwrt
cd openwrt

echo "Downloading stable OpenWrt mainline source archive package..."
wget -qO- https://github.com | tar -xz --strip-components=1

echo "Updating and installing OpenWrt package feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# ====================================================================
# INJECTION STEP: Copying your custom work into the updated target folders
# ====================================================================
echo "Injecting ZTE ZXHN H168N V3.5 hardware blueprint..."
cp ../en751221_zte_h168n_v35.dts ./target/linux/en75/dts/

echo "Registering the device inside the target image Makefile..."
cat << 'EOF' >> ./target/linux/en75/image/en751221.mk

define Device/zte_zxhn-h168n-v35
  DEVICE_VENDOR := ZTE
  DEVICE_MODEL := ZXHN H168N
  DEVICE_VARIANT := V3.5
  BOARDNAME := zte,h168n-v3.5
  DEVICE_DTS := en751221_zte_h168n_v35
  SUPPORTED_DEVICES := zte,h168n-v3.5
  KERNEL := kernel-bin | append-dtb
  IMAGE_SIZE := 7680k
endef
TARGET_DEVICES += zte_zxhn-h168n-v35
EOF

# ====================================================================
# SHOPPING LIST: Generating the configuration using updated target tokens
# ====================================================================
echo "Generating compiler configuration list..."
echo '
CONFIG_TARGET_en75=y
CONFIG_TARGET_en75_en751221=y
CONFIG_TARGET_MULTI_PROFILE=y
CONFIG_TARGET_PER_DEVICE_ROOTFS=y

# Build ONLY your targeted ZTE H168N V3.5 image footprint
CONFIG_TARGET_DEVICE_en75_en751221_DEVICE_zte_zxhn-h168n-v35=y
CONFIG_TARGET_DEVICE_PACKAGES_en75_en751221_DEVICE_zte_zxhn-h168n-v35=""

# Essential Core Packages
CONFIG_FEED_luci=y
CONFIG_FEED_packages=y
CONFIG_FEED_routing=y
CONFIG_IMAGEOPT=y

# Updated Ethernet and driver modules for the platform
CONFIG_PACKAGE_kmod-en75xx-eth=y
CONFIG_PACKAGE_kmod-libphy=y
CONFIG_PACKAGE_kmod-mii=y

# Lightweight runtime RAM recovery choices
CONFIG_TARGET_INITRAMFS_COMPRESSION_NONE=y
CONFIG_TARGET_ROOTFS_INITRAMFS=y
' > .config

echo "Validating configuration tree dependencies..."
make defconfig

echo "Launching the compiler using all available CPU cores..."
make "-j$(nproc)"

echo "Renaming snapshot binary for easier local identification..."
cd ./bin/targets/en75/en751221
ls | sed -n -e 's/openwrt-snapshot-\(.*\)-en75-\(.*\)/mv openwrt-snapshot-\1-en75-\2 openwrt-en75-\2/p' | sh

echo "SUCCESS: Your custom firmware is ready!"
