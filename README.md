# OpenWrt for ZTE ZXHN H168N V3.5

Experimental RAM-only OpenWrt port for the ZTE ZXHN H168N V3.5
(Orange Egypt variant), based on the EcoNet EN751221 platform.

## Status: v0.1a release candidate

This is an experimental development build, not production firmware.

- Kernel: OpenWrt Linux 6.18
- SoC: EcoNet EN751221
- RAM: 64 MiB
- Flash: 8 MiB SPI NOR (Winbond W25Q64)
- Boot method: UART bootloader + XMODEM, loading into RAM
- Internal Ethernet: functional in earlier tests, but severely slow
- Wi-Fi: not validated
- Flash installation: NOT supported or tested

**Do not flash this image.** It is intended only for temporary
RAM booting. Testing has been performed on borrowed hardware,
so preserving the original firmware is essential.

## Source

OpenWrt upstream:
https://git.openwrt.org/openwrt/openwrt.git

Base commit:

    e5c7612b1664d9e533ed5ddb6a861b4d0a62daa8

This repository contains board-specific additions and patches,
not a complete fork of the OpenWrt source tree.

The EcoNet target and Ethernet driver originate from the existing
OpenWrt development work, including contributions by CJ and others.
This project builds upon that work.

## Building on Ubuntu

Prepare a separate OpenWrt source checkout with the base commit
listed above, install the OpenWrt build dependencies, and prepare
the package feeds:

    ./scripts/feeds update -a
    ./scripts/feeds install -a

Then run this repository's build script, passing the path to the
OpenWrt checkout:

    ./build.sh /path/to/openwrt

The script applies the board patches, installs the DTS and
configuration files, and starts compilation.

Expected output:

    bin/targets/econet/en751221/openwrt-econet-en751221-zte_h168n-v3.5-initramfs-kernel.bin

The original development environment and package feeds have not
yet been fully pinned, so bit-for-bit reproducibility is not
guaranteed.

## RAM boot procedure

Using the UART bootloader prompt:

    bldr> xmdm 80020000 HEX_FILE_SIZE

Replace HEX_FILE_SIZE with the hexadecimal size of the exact
binary being uploaded.

Transfer the initramfs image using XMODEM, then execute:

    bldr> jump 80020000

These commands load and execute the image in RAM. They do not
install OpenWrt into flash.

Never use the bootloader's flash or erase commands for this
experimental port.

## Ethernet memory workaround

The original default qdisc configuration caused severe memory
pressure when activating the EcoNet Ethernet driver.

This build removes automatic Ethernet module loading. Its
board-specific startup script selects pfifo_fast before loading
the module.

This mitigates the observed memory-allocation problem but does
not resolve the Ethernet throughput limitation.

## Known limitations

- Internal Ethernet measured approximately 3.85 Mbps in earlier tests.
- USB CDC Ethernet achieved approximately 48 Mbps in comparison.
- Ethernet performance root cause remains unknown.
- SPI NOR access and flash layout are not validated under Linux.
- Wi-Fi and other peripherals remain unvalidated.
- RAM-only functionality is experimental.

See docs/development.md for diagnostic findings and future work.

## Safety and contributions

Contributions, testing reports and driver investigations are welcome.
Please distinguish confirmed observations from hypotheses.

Do not assume that this image is suitable for flash installation.
