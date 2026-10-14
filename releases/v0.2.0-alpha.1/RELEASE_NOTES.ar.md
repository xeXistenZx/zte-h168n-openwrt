# `v0.2.0-alpha.1` — نسخة تجريبية لتشغيل مكونات الهاردوير

**الجهاز:** ZTE ZXHN H168N V3.5 (الهاردوير المختبر V3.5.2)

**التاريخ:** 14 أكتوبر 2026

**الحالة:** Alpha تجريبية — **RAM-only**

**Kernel:** Linux `6.18.52`

**OpenWrt base:** `b3aa173dab5baa3cb4bd4fa6b0ebdb086500c5f4`

> **تحذير: دي مش Factory Firmware ولا Sysupgrade. ممنوع تكتبها على SPI Flash أو تستخدم Flash/Erase/Upgrade.**

## إيه اللي اشتغل فعلًا؟

دي أول نسخة من تجاربنا جمعت في Boot واحد الـ Ethernet Switch بكل فتحاته، تحميل الـ Drivers أوتوماتيك، إعداد `pfifo_fast` وBQL، مع تشغيل USB Controller والتعرف على Flash drive.

| الاختبار | النتيجة على الجهاز المختبر |
| --- | --- |
| OpenWrt من RAM عن طريق UART/XMODEM | ✅ |
| أربع فتحات RJ45 كـ LAN في `br-lan` | ✅ |
| عنوان LAN | `192.168.1.1` |
| `pfifo_fast` افتراضيًا | ✅ |
| `limit_min=32768` على 256 TX queues | ✅ |
| TCP download للراوتر نفسه | حوالي **67.8 Mbps** |
| USB xHCI | ✅ |
| التعرف على Kingston USB والبارتيشن `/dev/sda1` | ✅ |
| زيادة في أخطاء أو drops أثناء آخر اختبار TCP | لم تظهر في العدادات المختبرة |
| OOM أثناء جلسة الاختبار | لم يظهر في Kernel log |

## اختبار السرعة — 128 MiB ثلاث مرات

الراوتر حمّل ملف 128 MiB من جهاز Ubuntu على `192.168.1.3:8080`:

```sh
for i in 1 2 3; do
    time wget -q -O /dev/null http://192.168.1.3:8080/test128m.bin
done
```

| مرة | الزمن | السرعة المحسوبة |
| --- | --- | --- |
| 1 | 15.89 ثانية | 67.6 Mbps |
| 2 | 15.84 ثانية | 67.8 Mbps |
| 3 | 15.78 ثانية | 68.1 Mbps |

دي **سرعة نقل بيانات للـ CPU في الراوتر نفسه**، مش سرعة Internet routing أو NAT. اختبار LAN-to-LAN منفصل سابقًا وصل تقريبًا لـ 94–95 Mbps على وصلات 100 Mbps.

## حالة الذاكرة بعد الاختبار

```text
MemAvailable: 7256 kB
SUnreclaim:   11660 kB
```

ده معناه إن الجهاز شغال لكن مساحة الـ RAM المتاحة قليلة. الأرقام دي لقطة وقت الاختبار، مش ضمان ضد OOM في ظروف أخرى. جلسة الاختبار الموثّقة وصلت لـ 27 دقيقة على الأقل، لكن لسه ما عملناش اختبارات استقرار لأيام.

## USB

تم تشغيل `xhci-mtk` والتعرف على Kingston DataTraveler 3.0 وظهور `/dev/sda` و`/dev/sda1`. ظهر خطأ USB غير قاتل `-71` أثناء الـ enumeration؛ سببه مش مؤكد. **ما اختبرناش Mount أو نقل ملفات من الـ USB** في النسخة دي.

## الحاجة اللي ما خلصتش

- Wi-Fi وLuCI مش موجودين.
- تشغيله كراوتر إنترنت كامل (WAN/NAT/PPPoE/Firewall) مش مؤكد.
- الـ TX queues عددها 256 والـ RAM المتاحة محدودة.
- في تذبذب ملحوظ في Ping للراوتر نفسه (تقريبًا 1–10 ms في فترات بدون فصل كابلات)، ولسه بنبحث عن سببه.
- اختبارات Cold Boot المتكررة والتشغيل الطويل مش مكتملة.
- التثبيت الدائم على Flash أو Recovery غير مدعومين.

## ملف الـ Firmware المُختبَر

```text
openwrt-econet-en751221-zte_h168n-v3.5-initramfs-kernel.bin
Size: 5982181 bytes
SHA-256: 1c8a120e9f51740cfc3a1f32dee7d4b740344aaacb4a3eab036ed92a2c5408a9
```

لو عندك نفس الهاردوير وعندك Bootloader مفتوح وبتعرف تستخدم XMODEM، مسار الـ RAM المُختبر كان:

```text
xmdm 80020000 0x5B47E5
# send the exact matching file using XMODEM
jump 80020000
```

**الأوامر دي فقط للتشغيل المؤقت من RAM.** لازم تتحقق من حجم الـ File وSHA-256، وما تجربهاش على إصدار مختلف من غير مراجعة كاملة.

## الشكر والتعاون

التجارب العملية أجراها الباحث/المساهمون. تم استخدام ChatGPT من OpenAI ومساعدات AI في المناقشات، تحليل مخرجات وكتابة/ترجمة التوثيق. الشكر لمطوري OpenWrt وLinux ولـ CJ DeLisle على كود [`econet_eth`](https://github.com/cjdelisle/econet_eth). AI ممكن تغلط، وأي ملاحظات أو إصلاحات مرحّب بيها جدًا.

[شرح فني تفصيلي](../../docs/releases/v0.2.0-alpha.1-validation.ar.md) · [خطة التطوير](../../docs/H168N-ROADMAP.ar.md) · [التعاون والمساهمة](../../CONTRIBUTING.ar.md)
