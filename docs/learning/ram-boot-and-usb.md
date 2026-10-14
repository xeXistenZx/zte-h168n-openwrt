# Learning note: RAM-only booting, initramfs, SquashFS and USB

## Why RAM-only?

The tested H168N is borrowed. Its original **8 MiB SPI NOR flash** is intentionally untouched. The existing bootloader can accept a kernel image into RAM and execute it, allowing Linux and OpenWrt driver experimentation without committing changes to nonvolatile firmware. This does **not** make every possible RAM command safe; only use the validated load/jump path.

## Exact alpha.1 boot record [OBSERVED]

```text
image:  openwrt-econet-en751221-zte_h168n-v3.5-initramfs-kernel.bin
bytes:  5982181
sha256: 1c8a120e9f51740cfc3a1f32dee7d4b740344aaacb4a3eab036ed92a2c5408a9
load:   0x80020000
length: 0x5B47E5
```

With the H168N's **already accessed** bootloader and the same working serial/XMODEM procedure:

```text
xmdm 80020000 0x5B47E5
# Send exactly the matching image through XMODEM
jump 80020000
```

**Do not invoke `flash`, `erase` or other nonvolatile write functions.** Verify the image hash and its length every time. The device may take time to transfer a multi-megabyte image over UART.

## initramfs versus SquashFS (what changes?)

| Mode | Where root filesystem resides | Why it matters |
| --- | --- | --- |
| Current alpha.1 initramfs | Extracted, writable RAM root | Easy RAM boot; root files consume RAM after unpack |
| RAM-resident compressed filesystem (research) | Compressed SquashFS remains in RAM, plus RAM overlay/caches | Might reduce memory; mounting and boot design need new work |
| Flash-resident SquashFS (future factory/system) | Compressed filesystem in SPI flash | Can spare RAM, but requires correct flash map, image headers, bootloader compatibility, recovery, and explicit permission |

A "factory image" is not simply a SquashFS file. A safe installable image needs a verified layout, packaging, checksums/headers as appropriate and recovery path; **none of those are certified in alpha.1**.

## USB inclusion and results [OBSERVED]

Minimal USB packages included `kmod-usb3`, `kmod-usb-xhci-mtk`, `kmod-usb-storage`, and their SCSI dependencies. At boot:

```text
xhci-mtk 1fb90000.usb: xHCI Host Controller
usb 1-2.2: device descriptor read/64, error -71
usb-storage 1-2.2:1.0: USB Mass Storage device detected
scsi 0:0:0:0: Direct-Access Kingston DataTraveler 3.0
sda: sda1
```

Both root USB buses registered; Kingston block devices `/dev/sda`, `/dev/sda1` appeared. The initial `-71` protocol error did not prevent detection. A USB hub was present in the reported topology; power, cables, hub behaviour and controller timing have not been individually isolated. No filesystem mounting or long-duration USB I/O tested.

## Future roadmap connection

Before adding LuCI, Wi-Fi, a flashable root filesystem or any permanent partition changes, establish repeated boot stability and a measured RAM budget. A RAM-only system with ~7 MiB `MemAvailable` may become memory constrained if substantially more software is loaded. Do not assume compressed root alone will solve that.
