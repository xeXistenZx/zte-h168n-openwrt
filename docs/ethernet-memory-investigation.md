# EcoNet Ethernet: memory pressure and throughput investigation

**Platform:** ZTE ZXHN H168N V3.5 (EcoNet EN751221), 64 MiB RAM  
**Scope:** Experimental OpenWrt RAM-only initramfs images; Linux 6.18-series development builds  
**Status:** The memory workaround supports more stable testing. The throughput bottleneck and deeper memory behaviour are **not resolved**.

> This is a record of experiments, not evidence of a confirmed defect in any individual developer's code. Unless otherwise stated, measurements below are from *earlier* test images, not an acceptance test of the new v0.1a release candidate.

## 1. Why ~3.85 Mbps is meaningful progress, but not a solution

The original challenge was not merely poor network throughput: activating the internal Ethernet driver could exhaust the limited RAM and destabilise or reboot the router. Changing the module-loading sequence and default qdisc created a more useful experimental platform: Ethernet transfers could complete repeatedly and driver statistics could be collected.

The current approximately **3.85 Mbps internal Ethernet performance is unacceptable as a final result**. We tolerate it temporarily to preserve a repeatable, RAM-only testing baseline while isolating the root cause.

## 2. Observed OOM failure

With an earlier generic EcoNet image, activating the internal network interface with the default `fq_codel` configuration was associated with severe memory pressure and an OOM. The recorded call-path elements included:

```text
fq_codel_init
  -> qdisc_create_dflt
  -> mq_init_common
  -> mq_init
  -> dev_activate
```

The driver exposes **256 TX queues** in the investigated configuration. Multiqueue qdisc setup can multiply per-queue allocations; the trace places a failure in network qdisc initialisation, **not proof of a leak inside `econet-eth.ko`**. Reconstructing the exact number and size of qdisc allocations requires the complete kernel log and matching kernel source.

**Important limitation:** The full OOM log has not yet been embedded here. The trace chain is an extract from earlier recorded troubleshooting and should be replaced or supplemented with the original log when recovered.

## 3. Memory observations (different experimental states)

| State / operation | Recorded observation | What it supports | Limitation |
| --- | --- | --- | --- |
| Activate Ethernet with default `fq_codel` | Severe memory pressure, OOM during qdisc activation | The qdisc path is implicated in this failure | Exact baseline `MemAvailable` and slab counters not yet collated |
| Unload EcoNet Ethernet module in a diagnostic session | `SUnreclaim` fell by approximately **17.5 MiB** | Significant unreclaimable slab memory was freed after unloading | Does not by itself prove which structures consumed that memory |
| Load Ethernet under `pfifo_fast` in a separate session | Approximately **11.5 MiB `MemAvailable`** after driver loading | A functional but memory-constrained test state existed | Not a matched paired comparison with the row above |
| Perform full `/etc/init.d/network restart` in another test | Further OOM and reboot occurred | The workaround does **not** prove full memory stability under all network operations | Conditions need to be reproduced and isolated |

Do **not** subtract the 17.5 MiB from the 11.5 MiB figure: the values came from different experiments and describe different Linux memory counters.

### Repeatable memory evidence still needed

For each distinct test image, record the image checksum, kernel version, qdisc, and these command outputs at defined checkpoints (before module load, after module load, after interface activation, under transfer load, and after unloading, where safe):

```sh
uname -a
cat /proc/sys/net/core/default_qdisc
tc qdisc show
grep -E 'MemTotal|MemFree|MemAvailable|Slab|SReclaimable|SUnreclaim' /proc/meminfo
cat /proc/net/dev
```

For driver insertion, record `dmesg` before and after, including any `oom-killer`, `page allocation failure`, or `fq_codel` traces. **Do not automatically reproduce the known OOM just to gather logs on borrowed hardware.** Only undertake deliberately controlled RAM-only tests with a recovery plan.

A future table should give the actual before/after values from the **same boot** and **same image**; no missing values have been invented here.

## 4. Workaround implemented for the H168N

The release-oriented source changes are intentionally small.

1. Remove `AUTOLOAD:=$(call AutoLoad,90,econet-eth)` from `package/kernel/econet-eth/Makefile`.
2. Supply `net.core.default_qdisc=pfifo_fast` in `files/etc/sysctl.d/99-h168n-qdisc.conf`.
3. Provide a board-scoped `/etc/init.d/h168n-ethernet` startup script (and boot-time `S15h168n-ethernet` entry).
4. The script checks `/tmp/sysinfo/board_name` for `zte,h168n-v3.5`, writes `pfifo_fast` to `/proc/sys/net/core/default_qdisc`, checks the result, then inserts `/lib/modules/$(uname -r)/econet-eth.ko`.

Relevant script excerpt:

```sh
[ "$(cat /tmp/sysinfo/board_name 2>/dev/null)" = "zte,h168n-v3.5" ] || return 0
echo pfifo_fast > /proc/sys/net/core/default_qdisc || return 1
if [ "$(cat /proc/sys/net/core/default_qdisc)" != "pfifo_fast" ]; then
    logger -t h168n-ethernet "pfifo_fast not active; refusing to load Ethernet"
    return 1
fi
insmod "/lib/modules/$(uname -r)/econet-eth.ko"
```

**Reasoning:** Choosing the qdisc before module loading avoids relying on the timing of the global sysctl service. The explicit test refuses to load the Ethernet module if the expected qdisc is unavailable. This mitigates the earlier `fq_codel` allocation failure but is **not an established upstream-quality fix** for the 256-queue memory footprint.

**Unverified implementation detail:** Startup ordering, service registration and module behaviour should be reconfirmed against the specific v0.1a candidate after RAM boot.

## 5. Throughput tests

Earlier tests transferred a **16 MiB** HTTP payload to compare the built-in Ethernet path with a USB CDC Ethernet adapter on the same router.

| Interface | Approximate transfer time | Approximate goodput |
| --- | ---: | ---: |
| Built-in EcoNet Ethernet | 34.6–35.3 s | 3.8–3.85 Mbps |
| USB CDC Ethernet | 2.80–2.82 s | ~48 Mbps |

These are application-level transfer measurements, not wire-speed link benchmarks. USB tests were run through a hub that occasionally disconnected, so hub reliability is a separate issue.

**Interpretation:** The router and its software stack can handle substantially more traffic through an alternative interface. This narrows the search to differences in the internal Ethernet path but does **not** conclusively locate the problem inside the Ethernet driver; switch configuration, PHY, CPU-facing port, DMA, interrupts, and test-path differences remain candidates.

## 6. Driver and register observations

Earlier controlled investigations reported:

- No material **additional** Ethernet RX errors or drops during the measured internal transfer.
- GDM1 shaper reads: `TX=0x00000000`, `CPORT=0x00000000`.
- QDMA channel-limit control reported `ch_lim_en=00000000`.
- QDMA0 interrupt 21 activity approximately 103 interrupts/second during one transfer.
- Debugfs DMA counters examined did not demonstrate an obvious error or sustained queue backlog.
- Driver configuration examined included forced 1 Gbps/full-duplex settings for switch CPU-facing ports 5/6; applicability to the board and actual datapath remains to be established.

The diagnostic GDM register-printing patch was deliberately **removed** from the first v0.1a candidate and preserved separately for future investigation. **Zero-valued shaper registers do not on their own prove that no other rate limiter exists.**

## 7. Open questions: hypotheses, not conclusions

- Is the switch/CPU port link, timing or register configuration appropriate for this board?
- Does the H168N vendor firmware perform board-specific PHY, GDM, QDMA or switch initialisation that is missing from the open implementation?
- Are DMA descriptor handling, interrupt rate, queue mapping, or offloads limiting throughput?
- Which memory structures account for the driver's unusually large observed slab footprint, and can the number of TX queues be reduced safely?
- Is the limitation present in CJ's generic EcoNet implementation on other EN751221 boards, or specific to our H168N configuration?

## 8. Next experiments

1. Freeze a known RAM-bootable binary and source commit; record its SHA256.
2. Capture a **single-boot** memory-state series without deliberately triggering OOM.
3. Preserve exact transfer commands, endpoint configuration, interface state, link speed, and driver statistics for repeatable throughput comparisons.
4. Review EcoNet driver initialisation, then obtain manufacturer source or register documentation where available.
5. Compare known vendor changes against generic defaults, identify **why** a difference exists, and test one justified change at a time on an experimental Git branch.
6. Share the minimum reproduction case and evidence with EcoNet/OpenWrt developers.

## 9. Help wanted

Especially useful input: EN751221 QDMA/GDM documentation, MT7530/CPU-port configuration knowledge, a comparable board's driver measurements, and Linux multiqueue-qdisc memory-allocation expertise.

**Safety:** All experimental images are for RAM execution only; no flash-writing or installation steps are proposed.
