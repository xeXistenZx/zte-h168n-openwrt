# سجل أدلة H168N — للناس ولمساعدي AI

**التاريخ:** 14 أكتوبر 2026. **النطاق:** النسخة `v0.2.0-alpha.1` RAM-only والتجارب السابقة المرتبطة بيها.

> **مهم:** السجل ده **تلخيص للأدلة مش الـ raw logs نفسها**. أي شرح مكتوب جنبه «فرضية» ممنوع يتحول لحقيقة مؤكدة بمجرد إن AI لخّصته. وحجم Firmware أو البصمة الخاصة بإصدار ما ما ينفعش استخدامها لإصدار تاني.

## معاني التصنيفات

- **OBSERVED — مُشاهَد:** اتسجل في جهاز أو Output تجريبي.
- **DERIVED — محسوب:** حساب انطلاقًا من أرقام مقاسة.
- **HYPOTHESIS — فرضية:** احتمال محتاج إثبات.
- **PLANNED — مخطط:** تجربة لم تُنفَّذ بعد.
- **NOT TESTED — لم يُختبر:** مفيش دليل كافي.

## أهم النتائج

| ID | النتيجة | التصنيف | مرجع أو طريقة تحقق |
| --- | --- | --- | --- |
| H168N-001 | EN751221، RAM 64 MiB، SPI NOR 8 MiB | OBSERVED | سجلات الهاردوير القديمة |
| H168N-002 | Firmware alpha.1 = 5,982,181 bytes وبصمة SHA-256 محددة | OBSERVED | `sha256sum -c SHA256SUMS` |
| H168N-003 | RAM boot عبر `xmdm 80020000 0x5B47E5` ثم `jump 80020000` | OBSERVED | UART boot والنسخة نفسها |
| H168N-004 | LAN1=`port3`, LAN2=`port2`, LAN3=`port1`, LAN4/WAN=`port0` | OBSERVED | تجارب فصل وتوصيل الكابلات وdmesg |
| H168N-005 | `br-lan` فيها `port0` إلى `port3` | OBSERVED | `brctl show` |
| H168N-006 | الإعداد الافتراضي `pfifo_fast` اتطبق | OBSERVED | `/proc/sys/net/core/default_qdisc` |
| H168N-007 | كل **256** TX queues: `limit_min=32768` | OBSERVED | ملفات sysfs |
| H168N-008 | 3 × 128 MiB: **15.89/15.84/15.78 ثانية** | OBSERVED | `time wget` |
| H168N-009 | متوسط سرعة التحميل حوالي 67.8 Mbit/s | DERIVED | `134217728 × 8 / seconds / 1e6` |
| H168N-010 | Switch LAN-to-LAN حوالي 94–95 Mbps سابقًا | OBSERVED | اختبار منفصل |
| H168N-011 | `eth0` errors/drops = 0، والـ DSA RX drops مازادتش في آخر Stress test | OBSERVED | مقارنة العدادات قبل/بعد |
| H168N-012 | Kingston USB و`/dev/sda1` اتعرف عليهم | OBSERVED | dmesg + ls |
| H168N-013 | تحذير USB غير قاتل `-71` | OBSERVED | dmesg |
| H168N-014 | بعد الاختبار: MemAvailable=7256 KiB وSUnreclaim=11660 KiB | OBSERVED | `/proc/meminfo` |
| H168N-015 | مفيش OOM في جلسة alpha.1 المسجلة (27+ دقيقة) | OBSERVED محدود | dmesg + uptime |
| H168N-016 | FQ-CoDel أو مسار Startup سبب في OOM القديم | HYPOTHESIS | يحتاج A/B boots |
| H168N-017 | TX completion/BQL accounting هو أصل مشكلة السرعة | HYPOTHESIS | مراجعة وتعديل driver مع اختبارات |
| H168N-018 | تقليل queues إلى 16/8 هيوفر RAM بدون خسارة سرعة | PLANNED | مقارنة تجريبية |
| H168N-019 | RAM-resident SquashFS هيوفر قدر معين من RAM | NOT TESTED | قياس قبل/بعد |
| H168N-020 | Wi-Fi وLuCI وFactory flash وWAN/NAT اشتغلوا | NOT TESTED | ما ينفعش ادعاء ده |

## أهم فرق بين إقلاع سليم وإقلاع فاشل سابقًا

حصل في بعض الإقلاعات القديمة OOM cascades مع `SUnreclaim` حوالي 22 MiB. في إقلاع آخر حصل OOM مؤقت حوالي 31.96 ثانية، مع `slab_unreclaimable` ~14.9 MiB، و`free` ~15.9 MiB، وبعدها `netifd` مات و`procd` شغله تاني، وذاكرة slab انخفضت لاحقًا لحوالي 5.4 MiB واستمر الجهاز فوق 10 دقائق. **السبب المباشر لتخصيص الذاكرة الكبير لسه مش مثبت.**

## نصيحة للتوثيق وAI

أي تجربة جديدة لازم تسجل التاريخ وSHA-256 والـ Kernel والـ driver revision والـ Port والـ commands والـ raw log. حافظ على التجارب القديمة حتى لو نتيجتها اتغيرت، واكتب `SUPERSEDED` بدل حذفها. ارجع للـ [English evidence register](H168N-EVIDENCE-REGISTER.md) لمزيد من التفاصيل والمراجع.
