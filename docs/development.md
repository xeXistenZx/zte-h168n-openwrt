# H168N V3.5 development notes

## Hardware and boot environment

- ZTE ZXHN H168N V3.5, Orange Egypt variant
- EcoNet EN751221 family
- 64 MiB RAM
- 8 MiB Winbond W25Q64 SPI NOR
- UART bootloader with XMODEM RAM-loading support
- Temporary execution address: 0x80020000

The original flash firmware has been preserved.

## Kernel and initial bring-up

The experimental port uses the existing OpenWrt EcoNet target and
adds an H168N-specific device tree and image definition.

Initial Ethernet module activation with the default fq_codel
configuration caused severe memory consumption and OOM failures,
associated with multiqueue qdisc initialisation.

Removing Ethernet module autoload and using pfifo_fast before
loading the module allowed more stable testing.

## Ethernet throughput investigation

Previous measured HTTP transfer results:

- Internal Ethernet: approximately 3.8-3.85 Mbps
- USB CDC Ethernet: approximately 48 Mbps
- Test payload: 16 MiB
- Internal Ethernet: approximately 34.6-35.3 seconds
- USB Ethernet: approximately 2.80-2.82 seconds

Observed during internal Ethernet tests:

- No significant additional RX errors or drops
- Examined GDM1 TX and CPORT shaper registers returned zero
- Examined QDMA channel limit control was disabled
- No demonstrated root cause for the low throughput

The GDM register logging patch was used experimentally, then
removed from the v0.1a release candidate.

## Known unknowns

- Whether the switch CPU-facing port configuration is optimal
- Whether QDMA/GDM setup differs from the manufacturer implementation
- Whether board-specific PHY or timing configuration is missing
- Whether the vendor firmware performs additional initialisation
- Whether the current driver has a generic or board-specific issue
- Whether an older manufacturer driver can be independently tested

None of these possibilities is yet a confirmed explanation.

## Planned investigations

1. Review the current EcoNet driver and existing diagnostics.
2. Obtain and study relevant original manufacturer driver source.
3. Test an independent manufacturer-based baseline if practical.
4. Compare register initialisation and hardware configuration.
5. Test one justified change at a time in RAM.
6. Contribute any confirmed fix to the appropriate upstream project.

## Release policy

- Keep v0.1a as a traceable baseline.
- Preserve exact source revision, patch set and binary checksum.
- Test each release candidate with RAM boot before publication.
- Do not perform flash writes on borrowed hardware.
- Keep experimental investigations on separate Git branches.
