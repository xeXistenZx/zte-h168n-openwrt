# شرح RAM boot وInitramfs وSquashFS وUSB

## إحنا ليه بنشغّل النظام من RAM؟

الراوتر اللي بنختبر عليه مستعار، وعليه **SPI NOR Flash حجمها 8 MiB** بنحاول نحافظ عليها من غير أي كتابة. الـ Bootloader الأصلي بيسمح نستقبل Kernel/Initramfs في RAM عن طريق UART/XMODEM ونشغّله. ده يخلي التجربة مؤقتة، لكن **مش معناه إن كل أوامر الـ Bootloader آمنة**.

## تفاصيل الملف اللي اتجرب في alpha.1

```text
Image:  openwrt-econet-en751221-zte_h168n-v3.5-initramfs-kernel.bin
Bytes:  5982181
SHA256: 1c8a120e9f51740cfc3a1f32dee7d4b740344aaacb4a3eab036ed92a2c5408a9
Load:   0x80020000
Length: 0x5B47E5
```

بعد الوصول للـ `bldr>` في **نفس نسخة الهاردوير التي جُرّبت** واستخدام Terminal/XMODEM كما تم اختباره:

```text
xmdm 80020000 0x5B47E5
# Transfer the exact image by XMODEM
jump 80020000
```

**خطر جدًا:** ما تستخدمش `flash` أو `erase` أو `upgrade` أو أي أمر كتابة على الـ Flash. لازم تتحقق من اسم الملف والحجم والبصمة، لأن Size argument يختلف مع كل Build.

## فرق أنواع Root filesystem

| النوع | الملفات فين؟ | الميزة أو المشكلة |
| --- | --- | --- |
| **Initramfs الحالي** | ملفات بتتفك في RAM وقت التشغيل | Boot سهل في التجارب لكنه بياخد RAM |
| **SquashFS داخل RAM (مقترح)** | ملف مضغوط في RAM مع Cache وOverlay | ممكن يقلّل الاستهلاك، لكنه محتاج تصميم وقياس |
| **SquashFS داخل Flash (مستقبلي)** | نظام مضغوط على الـ SPI Flash | بيحافظ على RAM، لكن لازم Flash map وRecovery مثبتين |

**Factory Firmware مش مجرد SquashFS file!** ممكن يحتاج Header/Checksums/Partitions وتوافق Bootloader وطريقة استرجاع آمنة. الحاجات دي مش جاهزة في alpha.1.

## USB اتجرب إزاي؟

أضفنا `kmod-usb3` و`kmod-usb-xhci-mtk` و`kmod-usb-storage` مع SCSI dependencies. في الـ dmesg ظهر:

```text
xhci-mtk 1fb90000.usb: xHCI Host Controller
usb 1-2.2: device descriptor read/64, error -71
usb-storage 1-2.2:1.0: USB Mass Storage device detected
scsi 0:0:0:0: Direct-Access Kingston DataTraveler 3.0
sda: sda1
```

ظهر `/dev/sda` و`/dev/sda1`. التحذير `-71` ما منعش اكتشاف الجهاز، لكن سببه مش معروف (وكان فيه USB hub في المسار). لسه ما اختبرناش Mount أو نسخ ملفات أو الاستقرار الطويل.

قبل إضافة Wi-Fi وLuCI، لازم نوصل لاستقرار قابل للتكرار وRAM كفاية. الصورة الحالية مش ضمان إن كل الخدمات دي هتشتغل.

[English original](ram-boot-and-usb.md) · [خطة التطوير](../H168N-ROADMAP.ar.md)
