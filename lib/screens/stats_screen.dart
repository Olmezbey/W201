import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/car_state.dart';
import '../utils/constants.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final car = context.watch<CarState>();
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: _header()),
      SliverToBoxAdapter(child: _topCards(car)),
      SliverToBoxAdapter(child: _weekChart(car)),
      SliverToBoxAdapter(child: _driveScore(car)),
      SliverToBoxAdapter(child: _sensorHistory(car)),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
    ]);
  }

  Widget _header() => const Padding(
    padding: EdgeInsets.fromLTRB(20, 12, 20, 10),
    child: Text('İstatistik · Analiz', style: TextStyle(fontFamily: 'Syne', fontSize: 18, fontWeight: FontWeight.w700, color: C.t1)),
  );

  Widget _topCards(CarState car) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: Row(children: [
      _StatCard('TOPLAM KM',  '${(car.totalKm / 1000).toStringAsFixed(1)}k', 'tüm zamanlar', C.t1),
      const SizedBox(width: 6),
      _StatCard('BU AY',      '${car.monthKm.toInt()}', 'km · Nisan', C.green),
      const SizedBox(width: 6),
      _StatCard('ORT. HIZ',   '48', 'km/h bu hafta', C.blue),
    ]),
  );

  Widget _weekChart(CarState car) {
    const days = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pa'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.bord)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('HAFTALIK KM', style: TextStyle(fontSize: 9, color: C.t3, letterSpacing: 0.15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true, reservedSize: 20,
                  getTitlesWidget: (v, _) => Text(days[v.toInt()], style: const TextStyle(fontSize: 9, color: C.t3)),
                )),
              ),
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (_) => FlLine(color: C.bord, strokeWidth: 0.5),
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: false),
              barGroups: car.weekKm.asMap().entries.map((e) => BarChartGroupData(
                x: e.key,
                barRods: [BarChartRodData(
                  toY: e.value,
                  color: e.key == 6 ? C.green : C.bg4,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: C.bg3),
                )],
              )).toList(),
            )),
          ),
        ]),
      ),
    );
  }

  Widget _driveScore(CarState car) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.bord)),
      child: Row(children: [
        SizedBox(
          width: 80, height: 80,
          child: Stack(alignment: Alignment.center, children: [
            CircularProgressIndicator(
              value: car.driveScore / 100,
              backgroundColor: C.bg4,
              valueColor: const AlwaysStoppedAnimation(C.green),
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
            ),
            Text('${car.driveScore.toInt()}', style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 22, color: C.green)),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('SÜRÜŞ SKORU', style: TextStyle(fontSize: 9, color: C.t3, letterSpacing: 0.15)),
          const SizedBox(height: 4),
          const Text('İYİ', style: TextStyle(fontFamily: 'Syne', fontSize: 20, fontWeight: FontWeight.w700, color: C.green)),
          const SizedBox(height: 6),
          const Text('Sert fren: 2 kez', style: TextStyle(fontSize: 11, color: C.t3)),
          const Text('Hızlı ivme: 3 kez', style: TextStyle(fontSize: 11, color: C.t3)),
          const Text('Sakin sürüş: %78', style: TextStyle(fontSize: 11, color: C.t2)),
        ])),
      ]),
    ),
  );

  Widget _sensorHistory(CarState car) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _StatCard('AKÜ', '${car.batt}V', 'ortalama 24s', car.battColor)),
      const SizedBox(width: 6),
      Expanded(child: _StatCard('MOTOR', '${car.motorTemp.toInt()}°C', 'günlük ort.', car.motorColor)),
      const SizedBox(width: 6),
      Expanded(child: _StatCard('MAX HIZ', '124', 'km/h bu hafta', C.amber)),
    ]),
  );
}

class _StatCard extends StatelessWidget {
  final String label, val, sub;
  final Color color;
  const _StatCard(this.label, this.val, this.sub, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.bord)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 9, color: C.t3, letterSpacing: 0.12)),
        const SizedBox(height: 6),
        Text(val, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 22, fontWeight: FontWeight.w300, color: color, height: 1)),
        const SizedBox(height: 3),
        Text(sub, style: const TextStyle(fontSize: 10, color: C.t3)),
      ]),
    ),
  );
}
