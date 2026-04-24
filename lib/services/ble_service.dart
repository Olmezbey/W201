import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../utils/car_state.dart';
import '../utils/constants.dart';
import 'mqtt_service.dart';

class BleService {
  final CarState    state;
  final MqttService mqtt;
  StreamSubscription? _sub;
  Timer? _timer;
  BleService(this.state, this.mqtt);

  Future<void> start() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 0));
    _sub = FlutterBluePlus.scanResults.listen((results) {
      if (results.isEmpty) return;
      // En güçlü cihazı al
      final best = results.reduce((a, b) => a.rssi > b.rssi ? a : b);
      final rssi = best.rssi.toDouble();
      state.setBle(rssi);

      if (rssi > kBleNear && state.lock == LockState.locked) {
        _timer?.cancel(); _timer = null;
        state.toggleLock();
        mqtt.sendLock(false);
      } else if (rssi < kBleFar && state.lock == LockState.unlocked) {
        _timer ??= Timer(const Duration(seconds: 3), () {
          state.toggleLock();
          mqtt.sendLock(true);
          _timer = null;
        });
      } else {
        _timer?.cancel(); _timer = null;
      }
    });
  }

  void stop() { FlutterBluePlus.stopScan(); _sub?.cancel(); _timer?.cancel(); }
}
