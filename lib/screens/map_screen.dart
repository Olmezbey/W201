import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/car_state.dart';
import '../utils/constants.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final car = context.watch<CarState>();
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: _header(car)),
      SliverToBoxAdapter(child: _mapView()),
      SliverToBoxAdapter(child: _stats(car)),
      SliverToBoxAdapter(child: _history()),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
    ]);
  }

  Widget _header(CarState car) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
    child: Row(children: [
      const Text('GPS · Konum', style: TextStyle(fontFamily: 'Syne', fontSize: 18, fontWeight: FontWeight.w700, color: C.t1)),
      const Spacer(),
      Text('${car.lat.toStringAsFixed(4)}° N, ${car.lon.toStringAsFixed(4)}° E',
          style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: C.green)),
    ]),
  );

  Widget _mapView() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: Container(
      height: 200,
      decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.bord)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: CustomPaint(painter: _MapPainter(), child: Stack(children: [
          const Positioned(bottom: 10, right: 12, child: Text('▲ KUZEY', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9, color: C.t3))),
        ])),
      ),
    ),
  );

  Widget _stats(CarState car) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: Row(children: [
      _StatBox('HIZ', '${car.speed.toInt()}', 'km/h'),
      const SizedBox(width: 6),
      _StatBox('UYDU', '${car.gpsSats}', 'bağlı'),
      const SizedBox(width: 6),
      _StatBox('GÜNLÜK', '87', 'km'),
    ]),
  );

  Widget _history() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Text('GEÇMIŞ ROTALAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: C.t3, letterSpacing: 0.18)),
    ),
    _TripTile('Bugün · 08:23',  'Ev → İş',          '34.2 km', C.green),
    _TripTile('Dün · 19:45',    'İş → Market',       '18.7 km', C.blue),
    _TripTile('Dün · 07:55',    'Ev → İş',           '33.1 km', C.amber),
    _TripTile('Pazartesi · 20:10','Market → Ev',     '12.4 km', C.t3),
  ]);
}

class _StatBox extends StatelessWidget {
  final String label, val, unit;
  const _StatBox(this.label, this.val, this.unit);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.bord)),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 9, color: C.t3, letterSpacing: 0.1)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 20, color: C.t1)),
        Text(unit, style: const TextStyle(fontSize: 9, color: C.t3)),
      ]),
    ),
  );
}

class _TripTile extends StatelessWidget {
  final String time, label, km;
  final Color color;
  const _TripTile(this.time, this.label, this.km, this.color);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.bord)),
      child: Row(children: [
        Container(width: 2, height: 36, decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color, C.bg4]),
        )),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(time,  style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: color)),
          Text(label, style: const TextStyle(fontSize: 13, color: C.t2)),
        ])),
        Text(km, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: C.t3)),
      ]),
    ),
  );
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = Colors.white.withOpacity(0.03)..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 30) canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    for (double y = 0; y < size.height; y += 30) canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);

    final road = Paint()..color = Colors.white.withOpacity(0.06)..strokeWidth = 6..strokeCap = StrokeCap.round;
    final path1 = Path()..moveTo(0, size.height * 0.5)..quadraticBezierTo(size.width * 0.5, size.height * 0.4, size.width, size.height * 0.5);
    canvas.drawPath(path1, road);
    final path2 = Path()..moveTo(size.width * 0.5, 0)..quadraticBezierTo(size.width * 0.45, size.height * 0.5, size.width * 0.5, size.height);
    canvas.drawPath(path2, road);

    // Route
    final route = Paint()..color = const Color(0xFF00E87A).withOpacity(0.3)..strokeWidth = 2..style = PaintingStyle.stroke;
    final routePath = Path()..moveTo(size.width * 0.2, size.height * 0.8)..quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width * 0.5, size.height * 0.5);
    canvas.drawPath(routePath, route);

    // Dot
    final cx = size.width * 0.5, cy = size.height * 0.5;
    canvas.drawCircle(Offset(cx, cy), 14, Paint()..color = const Color(0xFF00E87A).withOpacity(0.15));
    canvas.drawCircle(Offset(cx, cy), 6, Paint()..color = const Color(0xFF00E87A)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = Colors.white);
  }
  @override
  bool shouldRepaint(_) => false;
}
