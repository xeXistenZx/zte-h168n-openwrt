#!/bin/sh
set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SRC=${1:-"$HOME/openwrt/openwrt"}
REV=e5c7612b1664d9e533ed5ddb6a861b4d0a62daa8

cd "$SRC"

if [ "$(git rev-parse HEAD)" != "$REV" ]; then
    echo "ERROR: OpenWrt checkout is not at the tested revision."
    echo "Expected: $REV"
    exit 1
fi

apply_patch() {
    patch="$REPO/patches/$1"

    if git apply --reverse --check "$patch" 2>/dev/null; then
        echo "Already applied: $1"
    else
        git apply --check "$patch"
        git apply "$patch"
        echo "Applied: $1"
    fi
}

apply_patch 001-disable-econet-eth-autoload.patch
apply_patch 002-add-h168n-image-definition.patch

cp "$REPO/dts/en751221_zte_h168n-v3.5.dts" \
    target/linux/econet/dts/

cp "$REPO/config/config-6.18" \
    target/linux/econet/

mkdir -p files/etc
cp -a "$REPO/overlay/etc/." files/etc/

cp "$REPO/config/.config-h168n" .config

make defconfig
make -j"$(nproc)" V=s

echo "Build finished. Check bin/targets/econet/en751221/"
