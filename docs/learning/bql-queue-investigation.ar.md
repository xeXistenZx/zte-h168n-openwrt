# قصة 256 TX queues وBQL — ليه TCP كان بطيء؟

**الحالة:** اكتشفنا Workaround شغال في أكتوبر 2026. **لكن السبب البرمجي الأساسي لسه مش مؤكد.**

## المصطلحات الأول

- **TX queue:** طابور برنامج Linux بيستخدمه لتنظيم إرسال Packets على Interface.
- **qdisc:** نظام ترتيب الباكِتس قبل خروجها؛ مثل `pfifo_fast` البسيط أو **FQ-CoDel** الأكثر تعقيدًا.
- **BQL (Byte Queue Limits):** نظام بيحاول يوازن كمية البيانات المعلّقة عند الـ driver بحيث ما نضغطش طابور الهاردوير بدون داعي، وبيتتبع الـ outstanding bytes.
- **`limit_min`:** أقل Limit يسمح بيه BQL لواحد من الـ TX queues.

**ملحوظة مهمة:** لما نخلي `limit_min=32768` في 256 queues ده **مش معناه إن النظام حجز 8 MiB RAM فعلًا**. ده Limit للتحكم في إرسال Bytes، مش مساحة Buffer اتخصصت بالكامل.

## اللي حصل بالترتيب

1. شغّلنا Ethernet، لكن TCP للراوتر نفسه كان بطيء جدًا في تجارب سابقة، رغم إن الـ LAN-to-LAN Switching كان قريب من 100 Mbps.
2. بدأنا نبص في الـ QDMA debug counters، ولقينا إن TCP flows ممكن تستخدم **TX queues مختلفة** زي `tx-214` ثم `tx-138`. اتتبعناها بناءً على Channel/Queue mapping في التجارب.
3. زوّدنا BQL `limit_min` إلى **32768** في حوالي سبع queues نشطة، وسرعة بعض الاتصالات اتحسنت. لكن مع TCP connection جديدة، ممكن تختار Queue تانية وبالتالي ترجع المشكلة.
4. جربنا رفع الحد الأدنى على **كل الـ 256 TX queues**. بعدها 128 MiB download بقى بياخد تقريبًا **15.6–16.2 ثانية** بصورة متكررة، أي حوالي **67–69 Mbps**.
5. في alpha.1 اختبرنا ثلاث مرات **15.89، 15.84، 15.78 ثانية**، وكل الـ 256 Queue كانوا على 32768، ومفيش زيادة في error/drop counters خلال آخر اختبار.

## نفس الـ Workaround للتجارب فقط

```sh
for q in /sys/class/net/eth0/queues/tx-*/byte_queue_limits; do
    [ -w "$q/limit_min" ] || continue
    echo 32768 > "$q/limit_min"
done

for q in /sys/class/net/eth0/queues/tx-*/byte_queue_limits; do
    cat "$q/limit_min"
done | sort -n | uniq -c
# النتيجة المُشاهَدة في alpha.1:
# 256 32768
```

الـ init script بيعمل ده تلقائيًا في النسخة. **لكن ده حل عملي مؤقت، مش Fix نهائي مضمون في Driver.**

## إيه اللي محتاج مراجعة في الكود؟

أثناء فحص Driver [`econet_eth`](https://github.com/cjdelisle/econet_eth) لاحظنا استخدام `netdev_tx_completed_queue()` لكل Packet في Completion handling. وثائق Linux بتوصي إن نداء الدالة ما يكونش أكثر من مرة واحدة لكل TX completion round. ده **مرشح محدد للمراجعة**، لكن ما نقدرش نقول إنه مثبت سبب بطء TCP أو OOM من غير تعديل مُتحكَّم فيه واختبار واضح. كمان وارد يكون المشكلة في Mapping أو Stop/Wake أو الـ descriptors أو أي جزء تاني.

## طيب وفكرة FQ-CoDel؟

الـ driver بيعرض **256 software TX queues**. مع `mq` ممكن يبقى فيه qdisc مستقل لكل Queue. FQ-CoDel عنده هياكل إدارة للـ flows وذاكرة لكل Instance؛ طبيعي العدد الكبير يستهلك موارد أكتر. في بعض الإقلاعات القديمة ظهر OOM، بينما `pfifo_fast` ساعد في الوصول لإقلاع مستقر، **لكن ما أثبتناش إن FQ-CoDel وحده السبب**.

## التجارب اللي ناويين عليها

- نغير **qdisc فقط** بين `pfifo_fast` وFQ-CoDel مع نفس إعداد BQL، ونكرر Cold boot.
- نخفض الـ TX queues إلى **16 ثم 8** في Builds تجريبية منفصلة ونقيس RAM وسرعة الشبكة وDrop counters.
- نعمل Patch صغير لـ TX completion accounting إذا مراجعة الكود أثبتت خلل، ونقارن Before/After بنفس الملف ونفس Port.
- نوثق الفشل والنجاح والـ Logs، وما نخلطش فرضية مع سبب مؤكد.

[مرجع Linux networking API](https://www.kernel.org/doc/html/latest/networking/kapi.html) · [English original](bql-queue-investigation.md) · [خطة التجارب](../H168N-ROADMAP.ar.md)
