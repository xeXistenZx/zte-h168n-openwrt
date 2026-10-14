# Learning note: 64 MiB RAM, slab memory and the OOM investigation

**Purpose:** explain observed memory behaviour without overstating the root cause.

## The vocabulary

- **Physical RAM:** hardware memory present on board; the H168N has **64 MiB**.
- **MemTotal:** Linux-reported memory it manages; smaller than physical RAM where regions are reserved. Reported sample about **53740 KiB**, not the full 65536 KiB.
- **MemAvailable:** kernel estimate of memory available without severe swapping/reclaim pressure; it is *not* a guaranteed amount safe for any one allocation.
- **Slab:** kernel-managed caches/objects supporting data structures.
- **SUnreclaim:** memory counted as kernel slab not readily reclaimed by normal cache shrinkers. High values matter on a small router but do not independently prove a leak.
- **Shmem:** shared-memory/tmpfs usage; do not assume every listed KiB can be immediately recovered by switching filesystem formats.
- **OOM killer:** response to an allocation failure where processes may be terminated; it is an effect of memory pressure, not evidence identifying the original allocator.

## What happened during earlier RAM-boot development [OBSERVED]

Older unsuccessful or marginal boots showed OOM cascades and high unreclaimable slab, around **22 MiB** in some bad cases. A notable recovered boot still experienced an OOM around **31.96 seconds** in late-init/hotplug; at that point `slab_unreclaimable` was approximately **3821 pages (~14.9 MiB)** and `free` about **4067 pages (~15.9 MiB)** while a watermark boost increased the effective minimum reserve. `netifd` was killed, later restarted by `procd`, `SUnreclaim` subsequently decreased to around **5.4 MiB**, and the router remained responsive for over ten minutes.

The contrast implies transient or path-dependent memory allocation/pressure during startup. A suspected interaction with late-init/hotplug/network/GPIO timing, and whether a monitoring loop changed scheduling, remain **hypotheses**. Do not announce an identified leaking allocation until backed by stack/allocation traces or repeatable A/B tests.

## Alpha.1 stable reference [OBSERVED]

With `pfifo_fast` selected before Ethernet driver initialisation and global BQL minima in place:

```text
MemAvailable: 7256 kB
SUnreclaim:   11660 kB
```

That snapshot followed the final **3 × 128 MiB** TCP downloads; the kernel log check showed no OOM/panic. Other samples were close to **7.1–7.3 MiB** available and **11.3–11.4 MiB** unreclaimable slab. This is functional but has limited expansion headroom.

## Is FQ-CoDel the OOM root cause?

**Not demonstrated.** Its per-TX-queue memory structures may become expensive when the driver advertises 256 queues. Booting with `pfifo_fast` was associated with improved behaviour, but this is not definitive causal isolation: the boot path was complex, and a large startup-time allocation could be separate. BQL changing from small adaptive limits to a 32 KiB minimum does not prove a fix to the memory root cause.

## Why not promise to recover 10 MiB from SquashFS?

SquashFS stores a compressed, read-only filesystem; the typical flash-installed layout has compressed bytes residing in nonvolatile storage. **On this borrowed device we must not flash SPI NOR.** A *RAM-resident* SquashFS still consumes RAM for its compressed image, loop/mount infrastructure, caches and writable overlay. It may use less memory than unpacked initramfs, but actual savings require measuring both arrangements with otherwise identical features and workloads. A future flash-based install changes this comparison; it is a separate safety/recovery project.

## Measurements we should collect next [PLANNED]

- A timestamped `/proc/meminfo` time series from power-on until steady state, especially `MemAvailable`, `Slab`, `SReclaimable`, `SUnreclaim`, `Shmem`, `Committed_AS`.
- `dmesg` with memory/OOM details and kernel timestamps; record `procd` and `netifd` process liveness.
- Deterministic cold-boot A/B comparisons with FQ-CoDel/pfifo_fast and 256/16/8 TX queues.
- Per-slab-cache stats where exported; avoid multiplying partial counters as if they were authoritative total memory usage.
- Throughput, drops, RTT and USB observations alongside memory: a lower footprint is not a win if the driver becomes unreliable.
- Cold-boot reproducibility and an explicit record of whether a monitoring loop was running; vary timing as a controlled factor.

Keep raw original serial logs and hashes in a separate evidence directory; the present document is a secondary explanation, not a replacement for primary logs.
