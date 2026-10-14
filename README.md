# OpenWrt for ZTE ZXHN H168N V3.5

## Project Goal

This project aims to give inexpensive and discarded ZTE ZXHN H168N
routers a second life through OpenWrt, while making Linux, networking
and embedded development more accessible to learners and hobbyists,
particularly in Egypt and the Arabic-speaking community.

These routers are commonly sold second-hand in Egypt for around
**250–400 EGP (approximately $5–7 USD)**, making them potentially
excellent low-cost learning platforms.

We aim to document our experiments, successes, failures and discoveries
so others can learn from them, avoid repeating unnecessary work and
contribute improvements.

**Contributions, feedback, bug reports, corrections and new ideas
are always welcome.**


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

Use an OpenWrt source checkout at commit:

    e5c7612b1664d9e533ed5ddb6a861b4d0a62daa8

Install the usual OpenWrt build dependencies and prepare the
package feeds before building.

From your OpenWrt source directory, apply the H168N patches:

    git apply /path/to/zte-h168n-openwrt/patches/001-disable-econet-eth-autoload.patch
    git apply /path/to/zte-h168n-openwrt/patches/002-add-h168n-image-definition.patch

Copy the board-specific files:

    cp /path/to/zte-h168n-openwrt/dts/*.dts target/linux/econet/dts/
    cp /path/to/zte-h168n-openwrt/config/config-6.18 target/linux/econet/
    mkdir -p files/etc
    cp -a /path/to/zte-h168n-openwrt/overlay/etc/. files/etc/
    cp /path/to/zte-h168n-openwrt/config/.config-h168n .config

Build the image:

    make defconfig
    make -j$(nproc)

Expected output:

    bin/targets/econet/en751221/openwrt-econet-en751221-zte_h168n-v3.5-initramfs-kernel.bin

Incremental builds can complete quickly, while fresh builds
take considerably longer.

Package feed revisions and the full build environment are not
yet pinned, so bit-for-bit reproducibility is not guaranteed.

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

See the [documentation index](docs/README.md) for technical investigations, experiments, hardware findings and future work.

## Safety and contributions

Contributions, testing reports and driver investigations are welcome.
Please distinguish confirmed observations from hypotheses.

Do not assume that this image is suitable for flash installation.

<!-- H168N-BILINGUAL-ACKNOWLEDGEMENTS-v1 -->
## Languages / لغات التوثيق

- [Arabic project overview / شرح المشروع بالعربي](README.ar.md)
- [Technical documentation / التوثيق الفني](docs/ALPHA1-DOCUMENTATION-INDEX.md) · [بالعربي](docs/ALPHA1-DOCUMENTATION-INDEX.ar.md)
- [Release roadmap](docs/H168N-ROADMAP.md) · [بالعربي](docs/H168N-ROADMAP.ar.md)

## Credits, AI assistance and contribution

The hardware tests were operated and measured by the project's human researcher(s)/contributors. **ChatGPT (OpenAI) and other AI assistants** helped with technical discussion, analyzing shared outputs, suggesting experiments, drafting commands and code, writing documents and Arabic translation. AI-generated content can be wrong and needs human review; it does not replace actual device testing. The OpenWrt/Linux community and **CJ DeLisle's [`econet_eth`](https://github.com/cjdelisle/econet_eth)** are acknowledged for their upstream work. Attribution does not imply endorsement.

Corrections, bug reports, reproducible tests and pull requests are very welcome: [CONTRIBUTING.md](CONTRIBUTING.md) · [بالعربي](CONTRIBUTING.ar.md) · [CREDITS.md](CREDITS.md). Authentic boot screenshots can be added using the [screenshot guide](docs/SCREENSHOTS.md); screenshots have not yet been supplied in this add-on.

**Experimental RAM-only image — do not flash.** No factory/sysupgrade image or validated flash recovery procedure is provided.
<!-- /H168N-BILINGUAL-ACKNOWLEDGEMENTS-v1 -->
