# Hardware findings and uncertainties

**Device under investigation:** ZTE ZXHN H168N V3.5 (Orange Egypt variant)

| Component | Evidence-backed finding | Remaining question |
| --- | --- | --- |
| Main SoC | EcoNet EN751221 family | Full board-specific hardware configuration |
| DRAM | 64 MiB reported by boot environment | Detailed timing/configuration and usable regions |
| Flash | 8 MiB Winbond W25Q64 SPI NOR identified | Linux controller integration, safe partition boundaries |
| Serial console | UART bootloader accessible | Complete pinout documentation/photo |
| Ethernet | Internal interface enumerates and exchanges traffic | CPU port, PHY/switch configuration, low throughput |
| USB | USB CDC Ethernet network path tested | Hub stability and integrated USB support |
| Wi-Fi | Not validated in this port | Chip identification, firmware and driver viability |

## Firmware and Linux board description

The experimental board DTS describes 64 MiB RAM, console selection, and GMAC enablement. It contains vestigial NAND declarations followed by `&nand { status = "disabled"; };`. Those NAND fragments are **not** a claim that this board uses NAND flash; the investigated board uses SPI NOR.

The first release intentionally avoids enabling flash-write support. The DTS and image definition remain experimental and are not a flash-installation layout.

## Questions for contributors

- Are there EN751221 reference designs with comparable Ethernet datapath or CPU-facing switch port topology?
- Does the vendor bootloader initialise networking hardware that Linux currently assumes is already configured?
- Is an original GPL driver or hardware register reference available for this variant?
- Can a working board provide comparative read-only switch/GDM/QDMA/PHY configuration dumps?

Always separate measurements and vendor documentation from assumptions based on another model or revision.
