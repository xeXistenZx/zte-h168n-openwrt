# H168N documentation guide — October 2026

**Scope:** ZTE ZXHN H168N V3.5 / OpenWrt `v0.2.0-alpha.1` RAM-only development.

This page is an **additional index**. It does not replace the repository's existing `docs/README.md` or prior research notes. Existing documents were not available for line-by-line review when this pack was drafted; confirm links, nomenclature, and chronology against the repository before merging.

## Choose the level of detail

| I want to... | Start here |
| --- | --- |
| Know whether this release is usable | [`releases/v0.2.0-alpha.1-validation.md`](releases/v0.2.0-alpha.1-validation.md) |
| Understand how Ethernet works | [`learning/ethernet-packet-path.md`](learning/ethernet-packet-path.md) |
| Understand BQL and the slow-TCP investigation | [`learning/bql-queue-investigation.md`](learning/bql-queue-investigation.md) |
| Understand the OOM episodes and memory figures | [`learning/memory-and-oom.md`](learning/memory-and-oom.md) |
| Understand RAM boot and USB discovery | [`learning/ram-boot-and-usb.md`](learning/ram-boot-and-usb.md) |
| See the proposed next work | [`H168N-ROADMAP.md`](H168N-ROADMAP.md) |
| Reuse evidence programmatically or with AI | [`H168N-EVIDENCE-REGISTER.md`](H168N-EVIDENCE-REGISTER.md) |

## Existing investigation records — preserve rather than replace

- [`docs/hardware.md`](hardware.md)
- [`docs/bootloader-ram-boot.md`](bootloader-ram-boot.md)
- [`docs/ethernet-memory-investigation.md`](ethernet-memory-investigation.md)
- [`docs/experiments.md`](experiments.md)
- [`docs/development.md`](development.md)

These older files should be audited against the versioned release snapshot and then cross-linked from the main `README.md` and `docs/README.md`. Do not overwrite or delete them merely because these new explanatory documents cover overlapping concepts.

## Evidence convention

Every nontrivial claim should be tagged **OBSERVED**, **DERIVED**, **HYPOTHESIS**, **NOT TESTED**, or **PLANNED**; see the evidence register for definitions. A successful RAM boot is not a safe flash procedure. An observed absence of OOM is not proof of long-term stability. A workaround is not necessarily a driver fix.

## Reproducibility anchors

- Release: `v0.2.0-alpha.1`, 14 October 2026
- Kernel: `6.18.52`
- OpenWrt base commit: `b3aa173dab5baa3cb4bd4fa6b0ebdb086500c5f4`
- Ethernet source: `https://github.com/cjdelisle/econet_eth`, revision `df20a0548c9142ef80ee613a81da90885b57e6c5`
- Firmware SHA-256: `1c8a120e9f51740cfc3a1f32dee7d4b740344aaacb4a3eab036ed92a2c5408a9`
- Local versioned source snapshot already staged at `releases/v0.2.0-alpha.1/` in the user's repository; **this documentation bundle contains no firmware binary**.

## For maintainers and future AI assistants

Use the evidence register as a navigational map, *not* as a substitute for original logs or code review. For each performance assertion, record device, firmware identity, interface/port, packet/byte counts, test command, runtime conditions and the output. A complete raw-log archive has not been attached to this documentation pack.

## Languages, contributions and screenshots

- [Arabic companion overview](../README.ar.md) / [ملخص المشروع بالعربي](../README.ar.md)
- [Arabic documentation index](ALPHA1-DOCUMENTATION-INDEX.ar.md)
- [Arabic roadmap](H168N-ROADMAP.ar.md) and [Arabic evidence register](H168N-EVIDENCE-REGISTER.ar.md)
- [Credits and AI transparency](../CREDITS.md) / [بالعربي](../CREDITS.ar.md)
- [Contributing and bug reporting](../CONTRIBUTING.md) / [بالعربي](../CONTRIBUTING.ar.md)
- [How to capture authentic boot screenshots](SCREENSHOTS.md) / [بالعربي](SCREENSHOTS.ar.md)

Do not publish simulated terminal screenshots as genuine test evidence. Original repository documents must be compared before replacing any pre-existing file.
