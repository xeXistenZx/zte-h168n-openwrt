# Authentic OpenWrt boot screenshots — alpha.1

Screenshots are **requested evidence**, not supplied in this pack. Never fabricate a boot screenshot, generate a synthetic terminal capture, or present a screenshot from a different device/build as if it were this one.

## Recommended captures

1. **UART boot and OpenWrt prompt** — show the actual H168N Linux boot (if possible kernel/version/board identity) and `root@OpenWrt:~#` prompt; capture via your real terminal (for example Tera Term). Avoid exposing bootloader passwords or sensitive boot data.
2. **Functional network and USB status** — on the **same alpha.1 boot**, show the actual output of:

```sh
uname -a
brctl show
cat /proc/sys/net/core/default_qdisc
for q in /sys/class/net/eth0/queues/tx-*/byte_queue_limits; do cat "$q/limit_min"; done | sort -n | uniq -c
grep -E 'MemAvailable:|SUnreclaim:' /proc/meminfo
ls -l /dev/sd* 2>/dev/null
```

If using a screenshot collage, label each panel and do not alter or remove failure messages. Keep original full-resolution captures locally; any published crop or redaction should be disclosed.

## Suggested paths after obtaining actual images

- `assets/screenshots/h168n-alpha1-uart-boot.png`
- `assets/screenshots/h168n-alpha1-ethernet-usb.png`

Only then add Markdown image links to the existing root `README.md`, `README.ar.md` and release notes, for example:

```markdown
![H168N v0.2.0-alpha.1 real UART boot](assets/screenshots/h168n-alpha1-uart-boot.png)
```

The current bundle deliberately contains **no image masquerading as a real screenshot**.

## Privacy and accuracy

Redact credentials, serial numbers, device identifiers, public IP addresses and personally identifying paths. Screenshots support the reported observation but do not replace raw logs, exact image SHA-256 or reproducible test instructions.
