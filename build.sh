#!/bin/sh

# Exit immediately if any command fails
set -e

REPO=https://github.com
HASH=ba9f212b567ee1cda360ba1fdb98629862ec974b

echo "Cleaning previous workspace..."
rm -rf ./openwrt
mkdir openwrt
cd openwrt

echo "Fetching cjdelisle's verified EcoNet code tree snapshot..."
git init
git remote add origin $REPO
git fetch --depth 1 origin $HASH
git checkout $HASH

echo "Updating and installing OpenWrt package feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# ====================================================================
# INJECTION STEP: This copies your custom work into his tree
# ====================================================================
echo "Injecting ZTE ZXHN H168N V3.5 hardware blueprint..."
cp ../en751221_zte_h168n_v35.dts ./target/linux/econet/dts/

echo "Registering the device inside the target image Makefile..."
cat << 'EOF' >> ./target/linux/econet/image/en751221.mk

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
# SHOPPING LIST: Generating the highly optimised 64MB RAM .config file
# ====================================================================
echo "Generating compiler configuration list..."
echo '
CONFIG_TARGET_econet=y
CONFIG_TARGET_econet_en751221=y
CONFIG_TARGET_MULTI_PROFILE=y
CONFIG_TARGET_PER_DEVICE_ROOTFS=y

# Build ONLY the ZTE H168N V3.5 image
CONFIG_TARGET_DEVICE_econet_en751221_DEVICE_zte_zxhn-h168n-v35=y
CONFIG_TARGET_DEVICE_PACKAGES_econet_en751221_DEVICE_zte_zxhn-h168n-v35=""

# Essential Core Packages (CLI only for initial stability testing)
CONFIG_FEED_luci=y
CONFIG_FEED_packages=y
CONFIG_FEED_routing=y
CONFIG_IMAGEOPT=y

# Drivers needed for your EcoNet Ethernet hardware mapping
CONFIG_PACKAGE_kmod-econet-eth=y
CONFIG_PACKAGE_kmod-libphy=y
CONFIG_PACKAGE_kmod-mii=y

# Lightweight footprint options to maximize free RAM
CONFIG_TARGET_INITRAMFS_COMPRESSION_NONE=y
CONFIG_TARGET_ROOTFS_INITRAMFS=y
' > .config

echo "Validating configuration tree dependencies..."
make defconfig

echo "Launching the compiler using all available CPU cores..."
make "-j$(nproc)"

echo "Renaming snapshot binary for easier local identification..."
cd ./bin/targets/econet/en751221
ls | sed -n -e 's/openwrt-snapshot-\(.*\)-econet-\(.*\)/mv openwrt-snapshot-\1-econet-\2 openwrt-econet-\2/p' | sh

echo "SUCCESS: Your custom firmware is ready!"
