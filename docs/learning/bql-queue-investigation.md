# Learning note: why 256 queues caused a surprising throughput problem

**Status:** observations and workaround verified in October 2026; ultimate driver root cause **not yet established**.

## The concepts in plain English

**A Linux TX queue** holds/transmits packets destined to be sent. A NIC can expose many software queues. **A qdisc** (queue discipline) decides which queued packets should leave next. `pfifo_fast` is a comparatively simple legacy qdisc; FQ-CoDel combines per-flow scheduling with queue-delay control.

**Byte Queue Limits (BQL)** is kernel accounting that aims to avoid leaving too many bytes waiting inside the device/driver. It adjusts how much data may be outstanding in each device TX queue. BQL is **not** a preallocated RAM buffer; setting `limit_min=32768` on 256 queues does *not* allocate 256 × 32768 bytes of buffers.

## Our sequence of observations

1. **Early problem:** CPU-path TCP performance could be extremely slow; UDP burst traffic also showed stalls. This happened even while hardware-switched LAN-to-LAN traffic could approach line rate.
2. **Queue discovery:** Driver QDMA debug counters showed traffic used individual Linux TX queues. A channel/queue mapping of `channel × 8 + queue_index` matched queue-specific activity in tested runs. Examples included `tx-214` and `tx-138` on different transfers.
3. **Partial remedy:** Raising BQL minima to **32768** on seven queues improved the connections using those queues; another new TCP flow could land on a *different* queue and still slow down.
4. **Global workaround:** Apply `limit_min=32768` to **all 256** `eth0` TX queues. Independent new transfers then consistently completed 128 MiB in about **15.6–16.2 seconds**, approximately **67–69 Mbit/s**.
5. **Alpha.1 validation:** Exactly `256 32768` from `sort -n | uniq -c`, with repeated 128 MiB times of **15.89, 15.84, 15.78 seconds** and unchanged errors/drops during controlled testing.

## Reproduce the runtime workaround [TESTED]

```sh
for q in /sys/class/net/eth0/queues/tx-*/byte_queue_limits; do
    [ -w "$q/limit_min" ] || continue
    echo 32768 > "$q/limit_min"
done

for q in /sys/class/net/eth0/queues/tx-*/byte_queue_limits; do
    cat "$q/limit_min"
done | sort -n | uniq -c
# Expected on tested 256-queue alpha.1: 256 32768
```

The boot script applies this automatically. This is a **diagnostic/operational workaround**, *not* the final upstream driver fix.

## Why might the driver need repair?

The investigated source calls `netdev_tx_completed_queue()` during completion handling, reportedly once per completed packet. Linux's networking API says this function should be called **at most once per TX completion round** rather than per individual packet. This is a specific code-review candidate, **not proof that it caused slow TCP, OOM, or all BQL adaptation problems**.

The relevant kernel API specification is https://www.kernel.org/doc/html/latest/networking/kapi.html . Check the exact pinned driver code before writing any patch or claiming the call-site is unchanged.

Other candidates include how queue mappings are chosen, stop/wake thresholds, outstanding-byte accounting, hardware backlog and descriptor recycling.

## `pfifo_fast` versus FQ-CoDel

The out-of-tree driver registers 256 TX queues. With a default `mq` root, there may be one leaf qdisc per TX queue. FQ-CoDel's structures can therefore create significant overhead compared to a simpler qdisc. **We observed OOM in some earlier startup paths and later stability with `pfifo_fast`, but have not proved that FQ-CoDel alone caused OOM.**

Changing BQL minima does not automatically eliminate the qdisc allocations. Reducing 256 software TX queues to 16 or 8 is an important *proposed* controlled experiment—not an established improvement.

## Experimental design [PLANNED]

Run identical cold-boot tests on a RAM-only build, varying *one factor at a time*:

| Build | TX queues | Default qdisc | BQL minimum | Purpose |
| --- | ---: | --- | ---: | --- |
| Reference alpha.1 | 256 | `pfifo_fast` | 32768 | Tested baseline |
| A | 256 | FQ-CoDel | 32768 | Is FQ-CoDel stable after global BQL workaround? |
| B | 16 | `pfifo_fast` | 32768 | Is queue reduction safe and less memory hungry? |
| C | 16 | FQ-CoDel | 32768 | Does fewer qdisc instances avoid startup OOM? |
| D | 8 | FQ-CoDel | 32768 | Further queue/memory trade-off |
| E | Driver accounting patch | Compare both | Controlled | Test a root-cause repair |

Record kernel image hash, precise driver diff, boot success/failure, `MemAvailable`, `SUnreclaim`, `Shmem`, error/drop counters, 128 MiB TCP timing, UDP burst loss, idle/load pings and QDMA hardware counters. Repeat cold boots to detect intermittent race/path effects. A result with fewer queues must also be checked for speed/regression, not just RAM.
