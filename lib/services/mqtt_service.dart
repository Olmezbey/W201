import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../utils/car_state.dart';
import '../utils/constants.dart';
import 'package:flutter/material.dart';

class MqttService {
  late MqttServerClient _c;
  final CarState state;
  MqttService(this.state);

  Future<void> connect() async {
    _c = MqttServerClient(kMqttHost, 'e190_${DateTime.now().millisecondsSinceEpoch}');
    _c.port = kMqttPort;
    _c.keepAlivePeriod = 20;
    _c.autoReconnect = true;
    _c.resubscribeOnAutoReconnect = true;
    _c.logging(on: false);
    _c.onConnected    = () => state.setConn(ConnState.connected);
    _c.onDisconnected = () => state.setConn(ConnState.disconnected);
    _c.onAutoReconnected = () => state.setConn(ConnState.connecting);
    _c.connectionMessage = MqttConnectMessage().withClientIdentifier('e190_app').startClean();

    state.setConn(ConnState.connecting);
    try { await _c.connect(); } catch (_) { state.setConn(ConnState.disconnected); return; }

    for (final t in [T.speed, T.lat, T.lon, T.sats, T.motorTemp, T.batt,
                     T.cabinTemp, T.cabinHumid, T.frontDist, T.rearDist, T.vibration, T.motion]) {
      _c.subscribe(t, MqttQos.atMostOnce);
    }
    _c.updates!.listen(_onMsg);
  }

  void _onMsg(List<MqttReceivedMessage<MqttMessage>> msgs) {
    final msg  = msgs[0];
    final val  = MqttPublishPayload.bytesToStringAsString(
        (msg.payload as MqttPublishMessage).payload.message);
    final d    = double.tryParse(val) ?? 0;
    switch (msg.topic) {
      case T.speed:      state.updateGps(s: d); break;
      case T.lat:        state.updateGps(la: d); break;
      case T.lon:        state.updateGps(lo: d); break;
      case T.sats:       state.updateGps(sats: d.toInt()); break;
      case T.motorTemp:  state.updateSensors(mt: d); break;
      case T.batt:       state.updateSensors(b: d); break;
      case T.cabinTemp:  state.updateSensors(ct: d); break;
      case T.cabinHumid: state.updateSensors(ch: d); break;
      case T.frontDist:  state.updateSensors(fd: d); break;
      case T.rearDist:   state.updateSensors(rd: d); break;
      case T.vibration:
      case T.motion:     if (val == '1') state.triggerAlarm(); break;
    }
  }

  void _pub(String topic, String val) {
    if (_c.connectionStatus?.state != MqttConnectionState.connected) return;
    final b = MqttClientPayloadBuilder()..addString(val);
    _c.publishMessage(topic, MqttQos.atLeastOnce, b.payload!);
  }

  void sendLock(bool v)   => _pub(T.cmdLock,    v ? '1' : '0');
  void sendWindows(bool v)=> _pub(T.cmdWindows,  v ? '1' : '0');
  void sendImmob(bool v)  => _pub(T.cmdImmob,    v ? '1' : '0');
  void sendLed(bool on, Color c, double bright) =>
      _pub(T.cmdLed, on ? '${c.red},${c.green},${c.blue},${(bright*255).toInt()}' : '0,0,0,0');
  void disconnect() => _c.disconnect();
}
