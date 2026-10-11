# H168N development documentation

This directory records **how** the experimental ZTE ZXHN H168N V3.5 OpenWrt RAM-only port was developed, including unsuccessful experiments. It is intended to help future contributors avoid repeating work.

## Choose a starting point

| If you are interested in… | Read |
| --- | --- |
| The sequence of experiments and what each one taught us | [Experiment log](experiments.md) |
| The Ethernet OOM, qdisc workaround, memory measurements, and 3.85 Mbps issue | [Ethernet and memory investigation](ethernet-memory-investigation.md) |
| UART access, XMODEM, and safe RAM booting | [RAM boot and bootloader](bootloader-ram-boot.md) |
| Board hardware, what is established, and what is still unknown | [Hardware findings](hardware.md) |
| The existing brief project history and roadmap | [Development notes](development.md) |

## Evidence convention

- **Observed:** supported by a recorded test, boot log, command output, or measurement.
- **Interpretation:** a plausible explanation consistent with observations, but not yet confirmed.
- **Unverified:** requires a repeatable test, exact log, datasheet, or source review.
- **Known regression/failure:** record it alongside successes rather than hiding it.

Values from different test builds are **not directly comparable** unless their configurations and test conditions match. Original terminal logs and screenshots should be attached or linked when available; this documentation does not recreate logs that were not preserved.

**Safety:** This project is **RAM-only** on borrowed hardware. No installation to the original flash is supported or validated.
