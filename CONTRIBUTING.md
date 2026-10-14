# Contributing, testing and reporting issues

Contributions are welcome: kernel/networking review, hardware verification, tests, Arabic/English documentation corrections, accessibility improvements, and reproducible bug reports.

## Before reporting

1. Read [the alpha.1 validation report](docs/releases/v0.2.0-alpha.1-validation.md), [evidence register](docs/H168N-EVIDENCE-REGISTER.md) and [roadmap](docs/H168N-ROADMAP.md).
2. Confirm **exact model/hardware revision**, board label, OpenWrt release, Linux kernel and firmware SHA-256. Different H168N revisions must not be conflated.
3. Capture the *exact* command, expected and actual output, repeatability, UART/kernel logs and whether cables or devices were moved. For benchmarks include direction, transfer size, interface/physical port, timing, link rate and RX/TX error/drop deltas.
4. Remove passwords, login cookies, public IPs, MAC addresses, serial numbers, Wi-Fi keys, credentials and other personal information before posting.
5. State whether your finding is **OBSERVED**, **DERIVED**, **HYPOTHESIS** or **NOT TESTED**. If proposing a fix, distinguish a runtime workaround from a driver correction.

## Submitting changes

- Prefer a focused GitHub Issue for a reproducible fault, or a Pull Request with a minimal change and explanation.
- Explain **why** a source change is needed and link evidence of behaviour before/after. Include the base OpenWrt revision, driver revision and exact DTS/overlay modifications.
- Keep failed tests; do not erase inconvenient data or mark speculative causes as proven.
- Update the corresponding English and Arabic documentation where possible. A translation-only improvement is welcome.
- AI-assisted contributions are welcome, but **disclose relevant AI use**, review the output and verify commands/code independently.

## Safety

**RAM-ONLY. NEVER FLASH THE ALPHA IMAGE.** There is no validated factory/sysupgrade image or guaranteed flash recovery procedure. Do not suggest permanent flash writes, wiping partitions or deploying the experimental build as an ISP gateway. Do not test flash-writing commands on borrowed hardware.

## Screenshot contributions

See [docs/SCREENSHOTS.md](docs/SCREENSHOTS.md). Only publish authentic images from the tested device, without secrets or identifying information.
