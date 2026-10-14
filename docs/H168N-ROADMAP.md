# H168N OpenWrt roadmap — proposed, evidence-driven

**Updated:** 14 October 2026. **Status:** planning document; names below are *proposals*, not committed release dates or guarantees. Each step is gated by measurements and regression testing.

## Current milestone: v0.2.0-alpha.1 — integrated hardware enablement

**Validated in a live RAM-only test:** automated four-port LAN bridge, `pfifo_fast` before interface creation, all 256 BQL `limit_min=32768`, sustained CPU-path TCP near 68 Mbit/s, USB flash-drive block detection, no OOM observed during reported session.

**Not yet checked enough for production:** cold-boot reproducibility, prolonged uptime, CPU-path ping sawtooth, Wi-Fi, LuCI, NAT/WAN, filesystem mount, permanent flash install.

**Publication gate:** attach identical SHA-256-verified firmware as an *experimental GitHub pre-release*; retain exact source/config/feed revisions and link the validation report. Do not mark stable or flashable.

## Proposed release sequence

| Milestone | Proposed scope | Exit criteria / measurements | Primary risk |
| --- | --- | --- | --- |
| **alpha.2 — queue/memory experiments** | RAM-only A/B builds comparing 256/16/8 TX queues, FQ-CoDel/pfifo_fast, BQL baseline | Multiple clean boots; OOM frequency; per-test memory, RTT and 128 MiB HTTP throughput | Driver queue mapping and regressions |
| **alpha.3 — Ethernet correctness** | Investigate and patch TX completion/BQL aggregation, queue stop/wake and QDMA path | Measured stable throughput, no new drops, code-reviewable minimal patch | Root cause still unproven |
| **alpha.4 — memory/rootfs research** | Quantify slab allocations; RAM-resident compressed SquashFS experiment; USB stability | Same-feature RAM comparison and cold boots; reliable recovery | Compressed root boot complexity |
| **beta.1 — usable router features** | Verify PCIe radios (MT7603EN/MT7612EN), drivers/firmware, LuCI feasibility, LAN/WAN segmentation | Wi-Fi association and transfer tests, usable memory headroom, security checks | PCIe/driver support; OOM |
| **beta.2 — daily-use evaluation** | DHCP, firewall/NAT, routing/PPPoE as applicable, reboot/uptime tests, reproducible source patches | Repeatable operation and documented configuration | Performance and stability |
| **stable candidate (far future)** | Reviewable upstream board support, device-safe installation approach | Proven flash layout/header/recovery, upstream patch review, sustained regression test plan | Risk of bricking / upstream integration |

The version labels are intentionally adjustable. We should not bundle experimental Wi-Fi into alpha.1 retrospectively.

## Experiment backlog — not yet conclusions

1. **FQ-CoDel OOM isolation:** same image except qdisc, controlled repeated cold boots; watch transient `SUnreclaim` and OOM call traces.
2. **Queue-count reduction:** 256 → 16 → 8; confirm correct queue selection, DMA/channel association, throughput, reliability and memory effect.
3. **BQL API correctness:** inspect `netdev_tx_completed_queue()` placement; consider aggregating completion bytes once per completion round, matching sent bytes; test with and without minimum workaround.
4. **Latency sawtooth:** collect time-aligned ICMP, CPU/interrupt, QDMA/driver and qdisc data on a continuously connected cable.
5. **Memory accounting:** inspect transient slab allocation rather than asserting FQ-CoDel is sole culprit; validate timing/scheduler hypothesis with a controlled monitoring-loop variable.
6. **USB:** reproduce `-71` with/without hub and known-good leads; only then consider optional filesystem mounting support.
7. **RAM-root compression:** measure net available memory, cold-boot reliability and decompression/caching trade-offs.
8. **PCIe/Wi-Fi:** confirm enumeration of hardware radios before selecting mt76 packages, then test on isolated development builds.
9. **LuCI:** add only with resource budget and stable network baseline, not as proof of router-readiness by itself.
10. **Factory firmware:** reverse-engineer flash partitions/headers and recovery away from borrowed device; **never flash this borrowed router without permission and validated recovery.**

## Working method for each milestone

- Maintain **a tested reference build** and a separately named experimental branch.
- Change **one causal variable per experiment** wherever practical.
- Log hardware version, DTS, source commit/patch hash, feed revisions, firmware hash, boot method, cables/ports, commands and exact raw outputs.
- Repeat tests and record **failures** as carefully as successes.
- Mark results `OBSERVED`, `DERIVED`, `HYPOTHESIS`, `PLANNED` or `NOT TESTED`.
- Do not remove working fallbacks or touch original SPI NOR as part of RAM-only development.

## Questions to ask before an upstream OpenWrt submission

Can independent testers build and boot? Are DTS devices, regulators, GPIO and MAC addresses correct? Is the Ethernet driver solution upstreamable rather than a per-board sysfs workaround? Are Wi-Fi and the actual physical WAN interface appropriately described? Is a **safe installation/recovery procedure** demonstrable? Is there permission and access to a non-borrowed test device for flash validation?
