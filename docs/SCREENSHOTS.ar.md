# صور حقيقية لإقلاع OpenWrt على H168N

إضافة Screenshot من الراوتر وهو بيشغّل OpenWrt فكرة ممتازة؛ هتساعد أي حد يشوف إننا بنتكلم عن تجربة فعلية. **لكن الصور لسه محتاجة تتصور من الجهاز الحقيقي**؛ الحزمة دي ما فيهاش صورة مولّدة بالـ AI أو لقطة مزيفة.

## ياريت ناخد صورتين

1. **صورة الإقلاع بـ UART**: شاشة الـ Terminal وقت Linux/OpenWrt loading، ثم علامة `root@OpenWrt:~#`. لو واضح إصدار Kernel/موديل الراوتر يبقى ممتاز.
2. **صورة النتائج**: شاشة فيها `brctl show` و`pfifo_fast` و`256 32768` للـ BQL وقراءة الذاكرة وظهور USB drive.

الأوامر الجاهزة على الراوتر:

```sh
uname -a
brctl show
cat /proc/sys/net/core/default_qdisc
for q in /sys/class/net/eth0/queues/tx-*/byte_queue_limits; do cat "$q/limit_min"; done | sort -n | uniq -c
grep -E 'MemAvailable:|SUnreclaim:' /proc/meminfo
ls -l /dev/sd* 2>/dev/null
```

لما نصوّر صور حقيقية، نحطّها هنا (داخل مجلد المشروع):

- `assets/screenshots/h168n-alpha1-uart-boot.png`
- `assets/screenshots/h168n-alpha1-ethernet-usb.png`

بعد كده نضيف روابطها في `README.md` و`README.ar.md`. قبل النشر نخفي كلمات السر، Serial Number، MAC، الـ IP العام وأي معلومات شخصية. ما نمسحش تحذيرات مهمة من الصورة، ولو قصّينا أو غطّينا جزء منها نوضح ده.

**الصورة دليل بصري مساعد؛ التفاصيل الفنية والاختبارات موجودة في الـ logs والتوثيق.**
