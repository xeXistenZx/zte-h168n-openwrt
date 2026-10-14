# شرح مبسط: Ethernet Packet بتمشي إزاي داخل H168N؟

**الفكرة:** نفهم ليه التحويل بين جهازين على فتحات LAN ممكن يكون سريع، بينما الاتصال بالـ CPU نفسه مختلف في الأداء.

## المسار في حدود اللي اتأكدنا منه

```text
Laptop / PC
    |
    v
RJ45 port (LAN1/2/3/4)
    |
    v
MT7530 DSA switch --------> another RJ45 port  (LAN-to-LAN switching)
    |
    v
CPU-facing link: eth0
    |
    v
QDMA + driver econet-eth
    |
    v
Linux networking / OpenWrt (br-lan, IP, services)
```

ده **رسم تعليمي مبسّط** مش Schematic كهربائي ولا تفاصيل كل مسار DMA. جزء LAN-to-LAN في الـ Switch ممكن يوصل لقرب سرعة Ethernet الفيزيائية، بينما وصول الباكِت للـ CPU يمر بمراحل مختلفة في Linux والـ driver.

## أسماء فتحات الراوتر اللي اتجربت

| مكان فتحة Ethernet المكتوب على الراوتر | اسمها في Linux |
| --- | --- |
| LAN1 | `port3` |
| LAN2 | `port2` |
| LAN3 | `port1` |
| LAN4/WAN | `port0` |

كل الأربع فتحات اتجربوا كـ **LAN** داخل `br-lan`. ظهور `port4` في Linux مش دليل إنه متوصل بفتحة RJ45 خامسة؛ ما تأكدناش من وصلة فعلية له. في إصدارنا ده LAN4/WAN بتتصرف كـ LAN، **مش WAN Router جاهز**.

## إيه هو DSA؟

**DSA — Distributed Switch Architecture** هو أسلوب Linux لإظهار فتحات الـ Ethernet switch كـ Interfaces منفصلة (`port0`...`port3`)، مع وجود واجهة متصلة بالـ CPU (`eth0`). إعداد Bridge في OpenWrt بيجمع الفتحات مع بعض، لكن نوع الشغل وطريقه عبور الباكِت بيتغير حسب هل هي للـ CPU ولا من LAN إلى LAN.

## إيه هو QDMA؟

الـ **DMA** يسمح بنقل بيانات بين الـ Memory والهاردوير بدون نسخ كل Byte بالـ CPU مباشرة. الـ **QDMA** جزء من مسار إرسال/استقبال Ethernet في الـ SoC. الـ driver بيعرّف Linux **256 TX software queues**؛ دي مش نفس عدد Hardware rings أو عدد فتحات RJ45.

لما Linux عايز يبعت Packet، الـ qdisc وTX queue بينظّموا الإرسال، وبعدين الـ driver يسلّم البيانات للهاردوير. **BQL** بيراقب عدد Bytes المرسلة والمعلّقة داخل الـ driver. عشان كده تغيير BQL كان له تأثير على سرعة TCP للراوتر نفسه.

## الـ Modules اللي اشتغلت

```sh
echo pfifo_fast > /proc/sys/net/core/default_qdisc
insmod /lib/modules/$(uname -r)/mt7530.ko
insmod /lib/modules/$(uname -r)/mt7530-mmio.ko
insmod /lib/modules/$(uname -r)/econet-eth.ko
```

ده كان الترتيب اليدوي اللي اشتغل، وبعد كده خليناه تلقائي في alpha.1. **ما بنحمّلش `mt7530-mdio`** على البورد دي؛ المسار اللي اتجرب هو MMIO.

## ليه الـ Ping للراوتر فيه sawtooth؟

كان فيه تغيّر متكرر للـ RTT من حوالي 1 لـ 10 ms. ممكن يكون بسبب Interrupts أو Scheduling أو Packet processing في CPU، **لكن السبب غير معروف**. فصل ووصل كابلات LAN كان بيعمل انقطاعات أطول، ودي حاجة مختلفة عن نمط الـ Ping المستمر.

## أوامر تحقق بسيطة

```sh
brctl show
cat /proc/sys/net/core/default_qdisc
for d in eth0 port0 port1 port2 port3; do
    echo "$d"
    cat /sys/class/net/$d/statistics/rx_errors
    cat /sys/class/net/$d/statistics/tx_errors
done
```

نسخة BusyBox في alpha.1 ما بتدعمش `ip -s`، ومش مثبت فيها `tc`، فنستخدم عدادات `/sys/class/net/` بدلها.

[شرح BQL والـ queues](bql-queue-investigation.ar.md) · [English original](ethernet-packet-path.md)
