import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/car_state.dart';
import '../utils/constants.dart';
import 'camera_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final car = context.watch<CarState>();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Header(car: car)),
        SliverToBoxAdapter(child: _SpeedRing(speed: car.speed)),
        SliverToBoxAdapter(child: _BleBar(car: car)),
        const SliverToBoxAdapter(child: _SecTitle('SENSÖRLER')),
        SliverToBoxAdapter(child: _SensorGrid(car: car)),
        const SliverToBoxAdapter(child: _SecTitle('KONTROLLER')),
        SliverToBoxAdapter(child: _Controls(car: car)),
        const SliverToBoxAdapter(child: _SecTitle('KAMERALAR')),
        SliverToBoxAdapter(child: _Cameras(context: context)),
        const SliverToBoxAdapter(child: _SecTitle('PARK SENSÖRÜ')),
        SliverToBoxAdapter(child: _ParkSensor(car: car)),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

// ─── HEADER ───
class _Header extends StatelessWidget {
  final CarState car;
  const _Header({required this.car});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(kCarName, style: TextStyle(fontFamily: 'Syne', fontSize: 20, fontWeight: FontWeight.w700, color: C.t1)),
            Text(kPlate, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: C.green, letterSpacing: 2)),
          ]),
          const Spacer(),
          _ConnChip(state: car.conn),
        ],
      ),
    );
  }
}

class _ConnChip extends StatelessWidget {
  final ConnState state;
  const _ConnChip({required this.state});
  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (state) {
      ConnState.connected    => (C.green, 'BAĞLI'),
      ConnState.connecting   => (C.amber, 'BAĞLANIYOR'),
      ConnState.disconnected => (C.red,   'BAĞLANTI YOK'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.5)),
      ]),
    );
  }
}

// ─── SPEED RING ───
class _SpeedRing extends StatelessWidget {
  final double speed;
  const _SpeedRing({required this.speed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: SizedBox(
          width: 180, height: 180,
          child: Stack(alignment: Alignment.center, children: [
            CustomPaint(painter: _RingPainter(speed: speed), size: const Size(180, 180)),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(speed.toInt().toString(),
                  style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 54, fontWeight: FontWeight.w300, color: C.t1, height: 1)),
              const Text('KM/H', style: TextStyle(fontSize: 10, color: C.t3, letterSpacing: 3)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double speed;
  _RingPainter({required this.speed});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2 - 8;

    // BG arc
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -pi / 2, 2 * pi, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 6..color = C.bg4..strokeCap = StrokeCap.round);

    // Speed arc
    final ratio = (speed / 180).clamp(0.0, 1.0);
    final color = speed > 120 ? C.red : speed > 80 ? C.amber : C.green;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -pi / 2, 2 * pi * ratio, false,
        Paint()
          ..style = PaintingStyle.stroke..strokeWidth = 6
          ..color = color..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3));
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.speed != speed;
}

// ─── BLE BAR ───
class _BleBar extends StatelessWidget {
  final CarState car;
  const _BleBar({required this.car});

  @override
  Widget build(BuildContext context) {
    final bars = ((car.bleRssi + 100) / 15).clamp(0, 5).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.bord)),
        child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: C.bDim, borderRadius: BorderRadius.circular(7), border: Border.all(color: C.blue.withOpacity(0.2))),
            child: const Icon(Icons.bluetooth, color: C.blue, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Telefon Bluetooth', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: C.t1)),
            Text('RSSI: ${car.bleRssi.toInt()} dBm · ${car.bleNear ? "Yakın — Kilit açılacak" : "Uzak"}',
                style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: C.t3)),
          ])),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(5, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 4, height: 4.0 + i * 4,
              margin: const EdgeInsets.only(left: 2),
              decoration: BoxDecoration(
                color: i < bars ? C.blue : C.bg4,
                borderRadius: BorderRadius.circular(2),
              ),
            )),
          ),
        ]),
      ),
    );
  }
}

// ─── SENSOR GRID ───
class _SensorGrid extends StatelessWidget {
  final CarState car;
  const _SensorGrid({required this.car});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.1,
        children: [
          _SCard('Motor', '${car.motorTemp.toInt()}°C', car.motorColor, car.motorTemp / 120),
          _SCard('Akü',   '${car.batt}V',               car.battColor,  (car.batt - 10) / 4),
          _SCard('Kabin', '${car.cabinTemp.toInt()}°C',  C.t2,           car.cabinTemp / 40),
          _SCard('Uydu',  '${car.gpsSats}',             C.green,         car.gpsSats / 12),
          _SCard('Nem',   '%${car.cabinHumid.toInt()}',  car.cabinHumid > 70 ? C.amber : C.t2, car.cabinHumid / 100),
          _SCard('Hız',   '${car.speed.toInt()} km', C.t2, car.speed / 180),
        ],
      ),
    );
  }
}

class _SCard extends StatelessWidget {
  final String label, val;
  final Color  color;
  final double ratio;
  const _SCard(this.label, this.val, this.color, this.ratio);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: C.bg2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.bord),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, color: C.t3, letterSpacing: 0.1)),
        const Spacer(),
        Text(val, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 15, color: color)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(1),
          child: LinearProgressIndicator(
            value: ratio.clamp(0, 1),
            minHeight: 2,
            backgroundColor: C.bg4,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ]),
    );
  }
}

// ─── CONTROLS ───
class _Controls extends StatelessWidget {
  final CarState car;
  const _Controls({required this.car});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 2.5,
        children: [
          _CtrlCard(
            icon: car.lock == LockState.locked ? Icons.lock_rounded : Icons.lock_open_rounded,
            label: car.lock == LockState.locked ? 'KİLİTLİ' : 'AÇIK',
            sub: '4 kapı · oto-kilit',
            active: car.lock == LockState.locked,
            color: C.green,
            onTap: () { car.toggleLock(); },
          ),
          _CtrlCard(
            icon: Icons.window_rounded,
            label: car.windows ? 'CAM AÇIK' : 'CAM KAPALI',
            sub: 'kontak bazlı auto',
            active: car.windows,
            color: C.blue,
            onTap: () => car.toggleWindows(),
          ),
          _CtrlCard(
            icon: Icons.lightbulb_rounded,
            label: car.led ? 'LED AÇIK' : 'AMBIENT LED',
            sub: car.led ? 'Renk aktif' : 'Kapalı',
            active: car.led,
            color: car.ledColor,
            onTap: () => car.toggleLed(),
          ),
          _CtrlCard(
            icon: Icons.shield_rounded,
            label: car.immob ? 'İMMOB AKTİF' : 'İMMOBİLİZER',
            sub: 'ateşleme devresi',
            active: car.immob,
            color: C.red,
            onTap: () => _immobConfirm(context, car),
          ),
        ],
      ),
    );
  }

  void _immobConfirm(BuildContext context, CarState car) {
    if (!car.immob) {
      showDialog(context: context, builder: (_) => AlertDialog(
        backgroundColor: C.bg2,
        title: const Text('İmmobilizer', style: TextStyle(color: C.t1, fontFamily: 'Syne')),
        content: const Text('Ateşleme devresi kesilecek. Araç çalışmaz hale gelir. Devam?', style: TextStyle(color: C.t2)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal', style: TextStyle(color: C.t3))),
          TextButton(onPressed: () { car.toggleImmob(); Navigator.pop(context); }, child: const Text('Aktifleştir', style: TextStyle(color: C.red))),
        ],
      ));
    } else {
      car.toggleImmob();
    }
  }
}

class _CtrlCard extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _CtrlCard({required this.icon, required this.label, required this.sub, required this.active, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.1) : C.bg2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? color.withOpacity(0.35) : C.bord),
        ),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: active ? color.withOpacity(0.15) : C.bg4, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 18, color: active ? color : C.t3),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? color : C.t2, letterSpacing: 0.3)),
            Text(sub, style: const TextStyle(fontSize: 10, color: C.t3)),
          ])),
        ]),
      ),
    );
  }
}

// ─── CAMERAS ───
class _Cameras extends StatelessWidget {
  final BuildContext context;
  const _Cameras({required this.context});

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(children: [
        Expanded(child: _CamCard('ÖN', kCamFront, ctx)),
        const SizedBox(width: 6),
        Expanded(child: _CamCard('ARKA', kCamRear, ctx)),
      ]),
    );
  }
}

class _CamCard extends StatelessWidget {
  final String label, url;
  final BuildContext ctx;
  const _CamCard(this.label, this.url, this.ctx);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => CameraScreen(label: label, url: url))),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          decoration: BoxDecoration(
            color: C.bg2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: C.bord),
          ),
          child: Stack(children: [
            Center(child: Icon(Icons.videocam_rounded, color: C.t3.withOpacity(0.3), size: 32)),
            Positioned(top: 8, left: 8, child: Row(children: [
              Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: C.red)),
              const SizedBox(width: 4),
              const Text('CANLI', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 8, color: C.red, letterSpacing: 0.1)),
            ])),
            Positioned(bottom: 8, left: 0, right: 0, child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: C.t3, letterSpacing: 0.1))),
          ]),
        ),
      ),
    );
  }
}

// ─── PARK SENSOR ───
class _ParkSensor extends StatelessWidget {
  final CarState car;
  const _ParkSensor({required this.car});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.bord)),
        child: Row(children: [
          Expanded(child: _DistGauge('ÖN', car.frontDist, car.frontColor)),
          const SizedBox(width: 20),
          Expanded(child: _DistGauge('ARKA', car.rearDist, car.rearColor)),
        ]),
      ),
    );
  }
}

class _DistGauge extends StatelessWidget {
  final String label;
  final double dist, maxDist = 250;
  final Color color;
  const _DistGauge(this.label, this.dist, this.color);

  @override
  Widget build(BuildContext context) {
    final ratio = (1 - dist / maxDist).clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 9, color: C.t3, letterSpacing: 0.1)),
      const SizedBox(height: 6),
      Row(children: List.generate(8, (i) {
        final filled = i < (ratio * 8).round();
        Color barColor = C.green;
        if (i >= 6) barColor = C.red;
        else if (i >= 4) barColor = C.amber;
        return Expanded(child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 4.0 + i * 2.5,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(color: filled ? barColor : C.bg4, borderRadius: BorderRadius.circular(2)),
        ));
      })),
      const SizedBox(height: 5),
      Text('${dist.toInt()} cm', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, color: color)),
    ]);
  }
}

// ─── SECTION TITLE ───
class _SecTitle extends StatelessWidget {
  final String text;
  const _SecTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
    child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: C.t3, letterSpacing: 0.18)),
  );
}
