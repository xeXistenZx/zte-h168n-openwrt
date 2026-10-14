# Learning note: where a packet goes in the H168N

**Audience:** OpenWrt users learning Linux network internals; kernel and DSA developers.  **Status:** explanatory architecture plus device-specific observations.

## The two very different packet journeys

### A. Laptop → router itself (CPU path)

```text
Laptop -> RJ45 -> MT7530 DSA switch -> CPU-facing interface `eth0`
       -> Linux network stack -> socket/application (`wget`, ping, SSH, ...)
```

The CPU must process the received packet. For replies or data transmitted from the router, Linux also traverses the TX qdisc / queue-management / QDMA path. A healthy 100 Mbit/s physical link does not automatically mean that the CPU can originate/consume data at wire speed.

### B. Laptop → Windows PC (LAN-to-LAN forwarding)

```text
Laptop -> RJ45 -> MT7530 switch fabric -> other RJ45 -> Windows PC
```

With the ports bridged and compatible forwarding state, the switch may forward unicast frames in hardware rather than sending every frame through Linux protocol processing. That is why the observed **~94–95 Mbit/s** LAN-to-LAN result and **~67.8 Mbit/s** router-facing TCP download can both be correct.

## Actual RJ45 mapping established by cable moves [OBSERVED]

| Router socket | Linux DSA interface |
| --- | --- |
| LAN1 | `port3` |
| LAN2 | `port2` |
| LAN3 | `port1` |
| LAN4/WAN | `port0` |

Linux also exposed `port4`, but a physical RJ45 mapping was **not established**. Do not claim that it is definitely unwired or absent without tracing the board.

### Auto bridge in alpha.1 [OBSERVED]

```text
br-lan: port0 port1 port2 port3
IP address: 192.168.1.1/24
```

The socket labelled WAN is functioning as **LAN** here. This alpha is not a WAN-router/NAT-performance release.

## What are QDMA and TX queues?

QDMA is the chip's queuing/DMA transmission engine. The current out-of-tree Ethernet driver exposes **256 Linux TX software queues**, associated in the observed configuration with **32 channels × 8 queues**. Debug counters under `/sys/kernel/debug/econet_eth/qdma0/chan_ctrs0` helped link traffic to specific queues. The design also involves hardware descriptor rings, which should **not** be confused with the number of Linux TX queues.

When a packet is to be transmitted, Linux chooses a software queue, queues/schedules the packet, and the driver submits it to hardware. **BQL** controls driver-queue outstanding bytes; **qdisc** manages software packet scheduling. They operate at different layers. See [`bql-queue-investigation.md`](bql-queue-investigation.md).

## Module loading and switch type [OBSERVED]

The working manual sequence (later automated) was:

```sh
echo pfifo_fast > /proc/sys/net/core/default_qdisc
insmod /lib/modules/$(uname -r)/mt7530.ko
insmod /lib/modules/$(uname -r)/mt7530-mmio.ko
insmod /lib/modules/$(uname -r)/econet-eth.ko
```

**Do not** load `mt7530-mdio` as part of this board's tested sequence: the working switch driver path is MMIO. To ensure the selected qdisc applies from the beginning, set it **before the Ethernet interface and its 256 queues are registered**. Alpha.1 uses OpenWrt preinit and an early service to achieve this.

## Why was there a 1–10 ms sawtooth to the router?

**HYPOTHESIS ONLY:** CPU scheduling, interrupt coalescing, packet-processing timing or queue behaviour could contribute. Ping timing, link counters and workload traces are needed to isolate it. The phenomenon was different from obvious several-second interruptions during deliberate cable reconnections. We cannot identify its root cause from ping output alone.

## Useful tests

```sh
brctl show
cat /proc/sys/net/core/default_qdisc
for x in eth0 port0 port1 port2 port3; do
  echo "$x"; cat /sys/class/net/$x/statistics/rx_errors
  cat /sys/class/net/$x/statistics/tx_errors
done
```

BusyBox's built-in `ip` on this image **does not implement `ip -s`**; use `/sys/class/net/*/statistics/` for counters. `tc` is not installed in this minimal image, so inspecting the active qdisc hierarchy requires a later debug build or other means.

## Relevant source

- CJ DeLisle EcoNet Ethernet driver: https://github.com/cjdelisle/econet_eth (pinned release revision in validation record)
- OpenWrt preinit source: https://git.openwrt.org/openwrt/openwrt/tree/package/base-files/files/etc/preinit
