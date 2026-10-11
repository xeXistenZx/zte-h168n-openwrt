# UART bootloader and RAM-only testing

The H168N V3.5 provided an accessible UART bootloader with a `bldr>` command prompt. This allowed experiments **without replacing the original firmware**.

## Established in prior sessions

- Bootloader accepts XMODEM transfers into memory.
- Tested loading address: `0x80020000`.
- Transfer size must match the **actual selected image**.
- Boot handoff uses `jump 80020000`.
- RAM-loaded OpenWrt images have booted successfully in prior experiments.
- Vendor flash remains untouched.

Example of the intended workflow **only at the UART `bldr>` prompt**:

```text
bldr> xmdm 80020000 HEX_FILE_SIZE
```

Send the image via the terminal application's XMODEM transfer facility. After transfer completion and only with a trusted, matching RAM-bootable image:

```text
bldr> jump 80020000
```

Compute `HEX_FILE_SIZE` on the Ubuntu machine from the exact file:

```sh
printf '0x%X\n' "$(stat -c %s /path/to/image.bin)"
sha256sum /path/to/image.bin
```

For the **v0.1a candidate prepared on 2026-10-11**:

| Field | Value |
| --- | --- |
| Size | 5,762,400 bytes |
| Hex size | `0x57ED60` |
| SHA256 | `cf403fd295745ac9098580b421bc3107a2e57b0d987c32ff9e6952b1bf07a13b` |
| Acceptance status when recorded | **Not yet confirmed RAM-boot tested** |

The values above are historical candidate identification, **not evidence of successful boot**. Revalidate checksum and actual image before use.

## Lessons learned

- A successful compile is **not** the same as a successful RAM boot.
- Kernel-module ABI mismatches can occur between builds even if the main kernel boots (one earlier SLUB-debug image rejected the Ethernet module due to the `.gnu.linkonce.this_module` structure-size mismatch).
- Archive working images under different names; never overwrite the only known-good file with an untested one.
- Use console logs to distinguish kernel boot failure, module-load failure, qdisc/OOM failure, and network configuration issues.
- Slow serial/XMODEM transfers make binary size and exact version tracking especially valuable.
- Keep test changes isolated from the borrowed router's original storage.

## Prohibited scope of this project

**Do not use bootloader `flash`, `erase`, or similar nonvolatile-writing operations.** There is no validated image for flash installation; flash controller support and partition boundaries are not established.

Additional bootloader commands, exact prompt transcripts, UART pinout photos, memory maps, and original transfer logs can be added when recovered and verified.
