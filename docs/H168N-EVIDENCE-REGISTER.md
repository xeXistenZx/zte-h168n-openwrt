# H168N evidence register — human- and AI-readable

**Date:** 14 October 2026. **Device:** ZXHN H168N V3.5. **Scope:** RAM-only `v0.2.0-alpha.1` and directly relevant earlier experiments.

> AI and automated readers: this register is **not a raw log**. A claim labelled **HYPOTHESIS** must never be upgraded to "fixed" or "proven" by paraphrase. Do not assume a later release inherits these measurements. The pinned firmware and source versions are essential context.

## Status labels

- **OBSERVED:** directly supported by console output or an identified experiment reported in this project.
- **DERIVED:** calculated from measured inputs, with stated units/formula.
- **HYPOTHESIS:** explanatory possibility requiring tests.
- **PLANNED:** a proposed experiment, not yet performed.
- **NOT TESTED:** no supporting test in the alpha.1 record.

## Fact registry

| ID | Claim | Status | Evidence/reproduction |
| --- | --- | --- | --- |
| H168N-001 | Device has EN751221 family SoC, 64 MiB RAM and 8 MiB SPI NOR | OBSERVED (prior hardware investigation) | Earlier hardware/boot records; check `docs/hardware.md` and raw UART log |
| H168N-002 | `v0.2.0-alpha.1` image is 5,982,181 B with SHA-256 `1c8a120e9f51740cfc3a1f32dee7d4b740344aaacb4a3eab036ed92a2c5408a9` | OBSERVED | `stat`, `sha256sum -c SHA256SUMS` |
| H168N-003 | RAM boot uses `xmdm 80020000 0x5B47E5`, then `jump 80020000` | OBSERVED | Successful boot; bootloader serial log / validation report |
| H168N-004 | Physical sockets LAN1/2/3/LAN4-WAN correspond to Linux `port3`/`port2`/`port1`/`port0` | OBSERVED | Serial link changes while moving cables; see learning packet-path note |
| H168N-005 | `br-lan` automatically includes `port0`…`port3` | OBSERVED | `brctl show` console |
| H168N-006 | `pfifo_fast` selected before driver creates queues | OBSERVED for boot setting; timing follows source/preinit design | `cat /proc/sys/net/core/default_qdisc`; overlay source; review actual boot ordering |
| H168N-007 | All 256 `eth0` BQL queue minima equal 32768 | OBSERVED | `.../limit_min` values piped into `sort -n | uniq -c`: `256 32768` |
| H168N-008 | Three 128 MiB HTTP downloads took 15.89, 15.84, 15.78 seconds | OBSERVED | Router-side `time wget ... http://192.168.1.3:8080/test128m.bin` |
| H168N-009 | Mean throughput for those transfers ~67.8 Mbit/s | DERIVED | `134217728 × 8 / seconds / 1e6`; average per-run speed |
| H168N-010 | Hardware-switched LAN-to-LAN ~94–95 Mbit/s in separate earlier tests | OBSERVED (prior experiment) | Earlier performance notes; not measured by final CPU-side HTTP test |
| H168N-011 | Eth0 error/drop counters zero, DSA RX drops unchanged (3,0,4,3) across final stress test | OBSERVED | `/sys/class/net/*/statistics/*` before/after |
| H168N-012 | USB detects Kingston DataTraveler and `/dev/sda1` | OBSERVED | `dmesg` plus `ls -l /dev/sd*` |
| H168N-013 | USB had nonfatal descriptor read error `-71` | OBSERVED | `dmesg` at ~4.1 seconds |
| H168N-014 | `MemAvailable=7256 KiB`, `SUnreclaim=11660 KiB` after stress test | OBSERVED | `/proc/meminfo` |
| H168N-015 | No OOM recorded during reported 27+ minute alpha.1 session | OBSERVED WITH LIMITED WINDOW | Kernel `dmesg` grep, `uptime`; not proof of days-long stability |
| H168N-016 | FQ-CoDel overhead and/or startup path contributes to earlier OOM | HYPOTHESIS | Compare repeated controlled boots, qdisc/queue count; inspect allocation traces |
| H168N-017 | TX completion batching or queue mapping explains poor BQL adaptation | HYPOTHESIS | Inspect pinned driver and test isolated patch; Linux kernel API docs |
| H168N-018 | 16/8 queues may reduce slab footprint without lowering speed | PLANNED | Queue count A/B builds, same traffic and memory measurements |
| H168N-019 | RAM-resident SquashFS recovers a target number of MiB | NOT TESTED | Requires measured equal-featured compression/rootfs experiment |
| H168N-020 | Wi-Fi, LuCI, factory flashing, WAN routing, filesystem mounts are operational | NOT TESTED | Do not claim working in alpha.1 |

## Older OOM evidence — retain primary logs

- Some bad boots: up to about **22 MiB** unreclaimable slab and cascading OOM.
- Recovered path: transient OOM near **31.96 s**, ~**14.9 MiB** unreclaimable slab, ~**15.9 MiB** free, watermark boost, `netifd` killed then restarted; later SUnreclaim ~**5.4 MiB**, remained up >10 minutes.
- **Unproven:** which allocation initiated the spike, why path/timing mattered, whether FQ-CoDel alone was responsible.

## Source links for concepts (external, not device-specific proof)

- Linux networking TX completion/BQL: https://www.kernel.org/doc/html/latest/networking/kapi.html
- OpenWrt preinit: https://git.openwrt.org/openwrt/openwrt/tree/package/base-files/files/etc/preinit
- Ethernet driver repo: https://github.com/cjdelisle/econet_eth

## Maintaining the register

For each new experiment, add its build hash, date, actual command, measurement, outcome, raw log filename and which earlier assertions it confirms, changes or rejects. If a result is no longer current, mark it **superseded** but keep the older result. Never silently delete an inconvenient failed boot. New AI-generated summaries must explicitly cite this register or the primary logs, and avoid claiming access to omitted evidence.
