# Experiment log: lessons from the H168N V3.5 port

This is a **retrospective summary**, not a reconstructed command-by-command journal. Dates and exact logs are supplied only when established. Entries indicate what was observed and why it mattered.

## 1. Gain access without altering the firmware

**Question:** Can we run a different kernel while preserving the borrowed router?

**Method:** UART bootloader access, XMODEM into RAM and a RAM `jump`.

**Observed:** RAM boot succeeded for experimental OpenWrt images. The original flash firmware remained intact.

**Lesson:** Secure a recovery-safe test path before working on kernel, Ethernet, or filesystem support.

**Outstanding evidence:** Pinout images, full bootloader output and logs.

## 2. Establish a generic EcoNet baseline

**Question:** Is the existing OpenWrt EcoNet platform close enough for this SoC?

**Method:** Boot generic EN751221 initramfs and inspect kernel/module initialisation.

**Observed:** OpenWrt booted and internal Ethernet enumerated, but interface activation could trigger severe memory pressure/OOM.

**Lesson:** A booting kernel and an enumerated Ethernet interface do not establish a functioning router.

## 3. Identify where the memory failure occurs

**Question:** Why does activating networking destabilise a 64 MiB device?

**Method:** Inspect OOM trace and slab counters; compare behaviour with and without the Ethernet module.

**Observed:** Trace included `fq_codel_init -> qdisc_create_dflt -> mq_init_common -> mq_init -> dev_activate`. `SUnreclaim` fell by about 17.5 MiB in an unloading experiment.

**Interpretation:** Large multiqueue qdisc allocations are implicated; the numbers alone do not prove a driver memory leak.

**Lesson:** Record exact failing subsystem and Linux memory category before attributing fault.

## 4. Test a narrower workaround

**Question:** Can qdisc selection and module loading order avoid the OOM path?

**Method:** Disable automatic loading of `econet-eth.ko`; set `pfifo_fast`; insert the module under controlled conditions.

**Observed:** More stable transfers became possible, with approximately 11.5 MiB `MemAvailable` after loading in one earlier test. A separate full network restart still triggered OOM.

**Lesson:** A workaround can enable useful progress without claiming the root problem is solved.

## 5. Establish comparative network performance

**Question:** Is low performance a general limit of the router's processing capacity?

**Method:** Compare 16 MiB HTTP transfers over internal Ethernet and USB CDC Ethernet.

**Observed:** About 3.8–3.85 Mbps internal versus ~48 Mbps over USB.

**Interpretation:** A faster alternative network path exists; this does not identify the defective component in the built-in path.

**Lesson:** A comparison interface can challenge assumptions and narrow the diagnostic search.

## 6. Inspect the internal Ethernet datapath

**Question:** Is a visible shaper, DMA error, queue limit or interruption pattern responsible?

**Method:** Read selected GDM/QDMA registers, counters, interrupts and interface statistics; use a temporary driver diagnostic patch.

**Observed:** GDM1 TX and CPORT shapers read zero; examined QDMA channel limiting was disabled; no demonstrated DMA error or RX drop explained the ~3.85 Mbps plateau.

**Lesson:** A negative result should be preserved. Absence of a fault in *one* register is not proof that the whole datapath is correctly configured.

## 7. Learn from an unsuccessful diagnostic build

**Question:** Does enabling additional slab debugging improve the evidence?

**Observed:** One earlier 6.18.38 SLUB-debug image booted but `econet-eth.ko` failed with a `.gnu.linkonce.this_module`/kernel `struct module` size mismatch.

**Lesson:** Keep kernel and module build state consistent; successful kernel boot does not prove external modules are compatible.

## 8. Prepare a reproducible, non-destructive release candidate

**Method:** Isolate the DTS, image-definition patch, autoload patch, qdisc startup overlay, OpenWrt configuration and a pinned upstream commit in a separate GitHub repository. Remove the temporary GDM diagnostic patch, clean and rebuild the Ethernet package, then build an initramfs.

**Observed:** A v0.1a candidate of 5,762,400 bytes was produced and identified by SHA256; RAM-boot acceptance result had not yet been entered when this document was drafted.

**Lesson:** Publish source, precise image identification and known limitations; do not turn an untested candidate into a verified release by assumption.

## Next controlled experiments

1. Record a complete memory profile from a *single* boot.
2. Capture throughput test commands and link/interface diagnostics.
3. Compare existing EcoNet driver against appropriate original vendor source, if available.
4. Isolate one register or logic difference at a time with before/after measures.
5. Preserve every experiment in Git branches and bring supported results back into the documentation.

For technical numbers, see [Ethernet and memory investigation](ethernet-memory-investigation.md). For RAM-safe boot commands, see [RAM boot and bootloader](bootloader-ram-boot.md).
