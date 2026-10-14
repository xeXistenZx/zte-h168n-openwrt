# v0.2.0-alpha.1 — Integrated Hardware Enablement

**Device:** ZTE ZXHN H168N V3.5
**Release date:** 14 October 2026
**Status:** Experimental alpha — RAM-only
**Kernel:** Linux 6.18.52
**OpenWrt base:** b3aa173dab5baa3cb4bd4fa6b0ebdb086500c5f4

## Overview

First integrated RAM-only OpenWrt development release for the
ZTE ZXHN H168N V3.5.

Combines functional four-port DSA Ethernet, automatic network
initialisation, the experimental BQL workaround and USB mass-storage
detection.

This is NOT a factory or sysupgrade image. DO NOT FLASH IT.

## Tested hardware

- EcoNet EN751221 SoC
- 64 MiB physical RAM
- 8 MiB SPI NOR flash (left untouched)
- Four physical 100 Mbps Ethernet ports
- MediaTek xHCI USB host controller

## Confirmed functionality

- Successful RAM boot using the existing ZTE bootloader.
- Automatic Ethernet driver and DSA switch initialisation.
- Four physical ports bridged into br-lan.
- br-lan address: 192.168.1.1.
- Automatic pfifo_fast default qdisc configuration.
- Automatic BQL limit_min=32768 on all 256 eth0 TX queues.
- Sustained TCP downloads to the router at approximately 67.8 Mbps.
- Successful detection of USB mass storage and /dev/sda1.
- No additional reported Ethernet drops or errors during the
  final three 128 MiB TCP transfers.
- No OOM recorded during the reported validation session.

## Ethernet measurements

Three consecutive 128 MiB downloads:

| Test | Duration | Approximate throughput |
|------|----------|------------------------|
| 1 | 15.89 s | 67.6 Mbps |
| 2 | 15.84 s | 67.8 Mbps |
| 3 | 15.78 s | 68.1 Mbps |

The approximately 95 Mbps LAN-to-LAN switching performance was
established in earlier testing, not as part of the final stress test.

All measured eth0 RX/TX error and drop counters remained zero.
Physical-port RX drop counters did not increase during the final
controlled transfers.

## Memory measurements

After the final stress test:

- MemAvailable: 7256 KiB
- SUnreclaim: 11660 KiB
- No OOM detected in the kernel log.

These are runtime observations, not worst-case memory guarantees.

## USB observations

- MediaTek xHCI host initialised.
- Kingston DataTraveler 3.0 detected.
- /dev/sda and /dev/sda1 detected.
- One USB descriptor error (-71) observed.
- Filesystem mounting and sustained USB transfers not tested.

## Known limitations

- Only approximately 7 MiB RAM available in the tested state.
- High unreclaimable kernel slab usage.
- Ethernet exposes 256 software TX queues.
- pfifo_fast and global BQL minimum are temporary workarounds.
- Recurring CPU-facing ICMP latency fluctuations.
- Wi-Fi and LuCI not included.
- Repeated independent cold boots not yet documented.
- Long-duration unattended stability not established.
- No flash installation or recovery procedure validated.

## RAM boot

The tested image is:

openwrt-econet-en751221-zte_h168n-v3.5-initramfs-kernel.bin

Image size: 5982181 bytes
SHA-256:
1c8a120e9f51740cfc3a1f32dee7d4b740344aaacb4a3eab036ed92a2c5408a9

Existing ZTE bootloader commands:

    xmdm 80020000 0x5B47E5
    jump 80020000

Transfer the exact matching binary using XMODEM before executing
the jump command.

These commands are for RAM execution only.

## Reproducibility

The versioned release directory includes:

- OpenWrt build configuration
- OpenWrt base commit
- Feed revisions
- Device tree source
- OpenWrt source patch
- Startup overlay files
- Firmware checksum

The binary is intended to be distributed as a GitHub Release asset,
not committed into Git history.

## Upstream attribution

Ethernet driver based on CJ DeLisle's econet_eth project:

https://github.com/cjdelisle/econet_eth

Pinned driver revision:
df20a0548c9142ef80ee613a81da90885b57e6c5

## Planned investigations

1. Compare FQ-CoDel and pfifo_fast using identical BQL settings.
2. Reduce the software TX queue count from 256 to 16 or 8.
3. Investigate TX completion and BQL accounting.
4. Investigate unreclaimable slab usage and startup memory spikes.
5. Improve CPU-side Ethernet throughput and latency.
6. Explore compressed SquashFS boot arrangements.
7. Investigate PCIe Wi-Fi support.
8. Add LuCI after establishing adequate RAM headroom.
9. Research factory firmware format separately.

## Safety notice

Experimental research firmware. Not production-ready.

Do not flash this image to SPI NOR.

The borrowed test router's original firmware and flash contents
were preserved throughout this validation.

<!-- H168N-RELEASE-AI-CREDITS-v1 -->
## Credits, AI transparency and feedback

The reported hardware experiments and measurements were performed by the human project researcher(s)/contributors operating the device. **ChatGPT (OpenAI) and other AI assistants** supported technical discussions, analyzing shared outputs, proposing experiments and code, drafting documentation and Arabic translation. AI output can be mistaken; technical claims and changes require independent human review and reproducible physical testing.

Thanks to OpenWrt and Linux contributors and to **CJ DeLisle** for the upstream [`econet_eth`](https://github.com/cjdelisle/econet_eth) driver. Attribution does not imply endorsement.

We welcome bug reports, corrections to measurements, technical review, translations, patch contributions and repeatable tests. See [CONTRIBUTING.md](../../CONTRIBUTING.md), [CREDITS.md](../../CREDITS.md) and [Arabic release notes](RELEASE_NOTES.ar.md). Genuine terminal screenshots are planned; see [screenshot instructions](../../docs/SCREENSHOTS.md).
<!-- /H168N-RELEASE-AI-CREDITS-v1 -->
