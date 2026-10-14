# دليل توثيق مشروع H168N — أكتوبر 2026

**النسخة:** ZTE ZXHN H168N V3.5 — OpenWrt `v0.2.0-alpha.1` — **RAM-only**. دي صفحة إضافية، مش بديل عن ملفات البحث القديمة أو `docs/README.md`.

## اختار مستوى التفاصيل اللي يناسبك

| لو أنت عايز... | اقرأ |
| --- | --- |
| تعرف إمكانيات النسخة والمخاطر | [ملاحظات الإصدار بالعربي](../releases/v0.2.0-alpha.1/RELEASE_NOTES.ar.md) |
| تشوف نتائج الاختبار الدقيقة | [تقرير التحقق الفني](releases/v0.2.0-alpha.1-validation.ar.md) |
| تفهم مسار باكِت الشبكة داخل الراوتر | [Ethernet packet path](learning/ethernet-packet-path.ar.md) |
| تعرف حكاية 256 TX queues وBQL | [تحقيق الـ BQL](learning/bql-queue-investigation.ar.md) |
| تفهم نقص الذاكرة والـ OOM | [الذاكرة وOOM](learning/memory-and-oom.ar.md) |
| تفهم تشغيل RAM وUSB وSquashFS | [RAM boot وUSB](learning/ram-boot-and-usb.ar.md) |
| تشوف خطتنا للنسخ القادمة | [Roadmap](H168N-ROADMAP.ar.md) |
| تتحقق من صحة معلومة أو تستخدم AI مساعد | [سجل الأدلة](H168N-EVIDENCE-REGISTER.ar.md) |
| تشوف صور إقلاع حقيقية | [دليل الصور](SCREENSHOTS.ar.md) |

## المستندات البحثية الأقدم — مهمة ولازم نحتفظ بيها

- [`hardware.md`](hardware.md)
- [`bootloader-ram-boot.md`](bootloader-ram-boot.md)
- [`ethernet-memory-investigation.md`](ethernet-memory-investigation.md)
- [`experiments.md`](experiments.md)
- [`development.md`](development.md)

الملفات الجديدة بتشرح وتلخص النتائج، لكن مش بتمسح التاريخ أو بتحل محل الـ logs الأصلية. لازم نراجع التطابق بينها وبين الملفات الأقدم قبل أي مساهمة رسمية لـ OpenWrt.

## طريقة قراءة أي نتيجة

- **OBSERVED / مُشاهد:** موجود في تجربة أو Console output.
- **DERIVED / محسوب:** ناتج حساب من قياسات معروفة.
- **HYPOTHESIS / فرضية:** تفسير محتمل، لسه مش ثابت.
- **PLANNED / مخطَّط:** اختبار عايزين نعمله.
- **NOT TESTED / لم يُختبر:** ما عندناش دليل إنه اشتغل.

**مهم لمساعدي AI:** ما تعتبرش الفرضيات حقائق، ولا تخلط بين إصدارات Firmware مختلفة، ولا تفترض إن RAM-boot معناه إن Flash installation آمن.

## بصمة النسخة

- Kernel `6.18.52`
- OpenWrt base `b3aa173dab5baa3cb4bd4fa6b0ebdb086500c5f4`
- Ethernet upstream source [`econet_eth`](https://github.com/cjdelisle/econet_eth), revision `df20a0548c9142ef80ee613a81da90885b57e6c5`
- SHA-256 للـ image: `1c8a120e9f51740cfc3a1f32dee7d4b740344aaacb4a3eab036ed92a2c5408a9`

[الشكر وشفافية AI](../CREDITS.ar.md) · [المساهمة والإبلاغ عن المشاكل](../CONTRIBUTING.ar.md)
