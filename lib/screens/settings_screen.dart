import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/car_state.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _bleThreshold  = kBleNear;
  double _lockSpeed     = kAutoLockSpeed;
  double _lockDelay     = 3;
  double _geoFence      = 500;
  int    _camQuality    = 1;
  bool   _sdLoop        = true;
  bool   _notifications = true;

  static const _qualities = ['640×480', '800×600', '1024×768'];

  @override
  Widget build(BuildContext context) {
    final car = context.watch<CarState>();
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: _header()),
      SliverToBoxAdapter(child: _section('BLE & OTOMATİK KİLİT')),
      SliverToBoxAdapter(child: _slider('Yaklaşma Eşiği', '${_bleThreshold.toInt()} dBm', _bleThreshold, -90, -50,
          (v) => setState(() => _bleThreshold = v))),
      SliverToBoxAdapter(child: _slider('Hız Kilitleme', '${_lockSpeed.toInt()} km/h', _lockSpeed, 10, 80,
          (v) => setState(() => _lockSpeed = v))),
      SliverToBoxAdapter(child: _slider('Kilit Gecikmesi', '${_lockDelay.toInt()} sn', _lockDelay, 1, 10,
          (v) => setState(() => _lockDelay = v))),
      SliverToBoxAdapter(child: _section('AMBIENT LED')),
      SliverToBoxAdapter(child: _ledPanel(car)),
      SliverToBoxAdapter(child: _section('GÜVENLİK')),
      SliverToBoxAdapter(child: _slider('Geo-fence Yarıçapı', '${_geoFence.toInt()} m', _geoFence, 100, 2000,
          (v) => setState(() => _geoFence = v))),
      SliverToBoxAdapter(child: _toggle('Push Bildirimler', 'Alarm ve uyarılar', _notifications, Icons.notifications_rounded,
          (v) => setState(() => _notifications = v))),
      SliverToBoxAdapter(child: _section('KAMERA')),
      SliverToBoxAdapter(child: _camQualityPicker()),
      SliverToBoxAdapter(child: _toggle('SD Kayıt Loop', 'Dolunca eski kayıtları sil', _sdLoop, Icons.loop_rounded,
          (v) => setState(() => _sdLoop = v))),
      SliverToBoxAdapter(child: _section('CİHAZ')),
      SliverToBoxAdapter(child: _deviceInfo(car)),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ]);
  }

  Widget _header() => const Padding(
    padding: EdgeInsets.fromLTRB(20, 12, 20, 10),
    child: Text('Ayarlar · $kPlate', style: TextStyle(fontFamily: 'Syne', fontSize: 18, fontWeight: FontWeight.w700, color: C.t1)),
  );

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
    child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: C.t3, letterSpacing: 0.18)),
  );

  Widget _slider(String name, String val, double current, double min, double max, ValueChanged<double> onChanged) =>
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.bord)),
        child: Column(children: [
          Row(children: [
            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.t1)),
            const Spacer(),
            Text(val, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: C.green)),
          ]),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: C.green,
              inactiveTrackColor: C.bg4,
              thumbColor: C.green,
              overlayColor: C.gDim,
              trackHeight: 2,
            ),
            child: Slider(value: current, min: min, max: max, onChanged: onChanged),
          ),
        ]),
      ),
    );

  Widget _toggle(String name, String sub, bool val, IconData icon, ValueChanged<bool> onChanged) =>
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.bord)),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: C.bg3, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: C.t2),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.t1)),
            Text(sub,  style: const TextStyle(fontSize: 11, color: C.t3)),
          ])),
          Switch(value: val, onChanged: onChanged, activeColor: C.green, inactiveTrackColor: C.bg4),
        ]),
      ),
    );

  Widget _ledPanel(CarState car) {
    final colors = [C.green, C.blue, Colors.purple, C.red, C.amber, Colors.white];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.bord)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Renk Seç', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.t1)),
            const Spacer(),
            Switch(value: car.led, onChanged: (_) => car.toggleLed(), activeColor: C.green, inactiveTrackColor: C.bg4),
          ]),
          const SizedBox(height: 12),
          Row(children: colors.map((c) => GestureDetector(
            onTap: () => car.setLedColor(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28, height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c,
                border: Border.all(color: car.ledColor == c ? Colors.white : Colors.transparent, width: 2),
                boxShadow: car.ledColor == c ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)] : null,
              ),
            ),
          )).toList()),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Parlaklık', style: TextStyle(fontSize: 12, color: C.t2)),
            const Spacer(),
            Text('%${(car.ledBright * 100).toInt()}', style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: C.green)),
          ]),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(activeTrackColor: C.green, inactiveTrackColor: C.bg4, thumbColor: C.green, overlayColor: C.gDim, trackHeight: 2),
            child: Slider(value: car.ledBright, onChanged: car.setLedBright),
          ),
        ]),
      ),
    );
  }

  Widget _camQualityPicker() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.bord)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Video Kalitesi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.t1)),
        const SizedBox(height: 10),
        Row(children: List.generate(3, (i) => Expanded(child: GestureDetector(
          onTap: () => setState(() => _camQuality = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _camQuality == i ? C.gDim : C.bg3,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _camQuality == i ? C.green.withOpacity(0.4) : C.bord),
            ),
            child: Text(_qualities[i], textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: _camQuality == i ? C.green : C.t3)),
          ),
        )))),
      ]),
    ),
  );

  Widget _deviceInfo(CarState car) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: C.bg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.bord)),
      child: Column(children: [
        _infoRow('Araç',      '$kCarName $kCarModel'),
        _infoRow('Plaka',     kPlate),
        _infoRow('ESP32 IP',  kEspIp),
        _infoRow('Firmware',  'v1.0.0'),
        _infoRow('MQTT',      car.conn == ConnState.connected ? 'Bağlı' : 'Bağlı Değil'),
        _infoRow('Uygulama',  'E190 Smart v1.0.0'),
      ]),
    ),
  );

  Widget _infoRow(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Text(k, style: const TextStyle(fontSize: 12, color: C.t3)),
      const Spacer(),
      Text(v, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: C.t2)),
    ]),
  );
}
