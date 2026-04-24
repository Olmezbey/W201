import 'package:flutter/material.dart';

// ─── ARAÇ ───
const kPlate      = '34 AU 966';
const kCarName    = 'Mercedes E190';
const kCarModel   = 'W201 · 1992';
const kPinCode    = '1992';          // Giriş şifresi — değiştir

// ─── ESP32 ───
const kEspIp      = '192.168.4.1';
const kMqttHost   = '192.168.4.1';
const kMqttPort   = 1883;
const kCamFront   = 'http://192.168.4.2/stream';
const kCamRear    = 'http://192.168.4.3/stream';

// ─── MQTT TOPIC'LER ───
class T {
  static const speed      = 'e190/gps/speed';
  static const lat        = 'e190/gps/lat';
  static const lon        = 'e190/gps/lon';
  static const sats       = 'e190/gps/sats';
  static const motorTemp  = 'e190/sensors/motor_temp';
  static const batt       = 'e190/sensors/batt';
  static const cabinTemp  = 'e190/sensors/cabin_temp';
  static const cabinHumid = 'e190/sensors/cabin_humid';
  static const frontDist  = 'e190/sensors/front_dist';
  static const rearDist   = 'e190/sensors/rear_dist';
  static const vibration  = 'e190/alarm/vibration';
  static const motion     = 'e190/alarm/motion';
  static const cmdLock    = 'e190/cmd/lock';
  static const cmdWindows = 'e190/cmd/windows';
  static const cmdLed     = 'e190/cmd/led';
  static const cmdImmob   = 'e190/cmd/immobilizer';
  static const cmdAlarm   = 'e190/cmd/alarm';
}

// ─── EŞIKLER ───
const kBleNear       = -70.0;   // dBm — yakın sayılma eşiği
const kBleFar        = -85.0;   // dBm — uzak sayılma eşiği
const kAutoLockSpeed = 30.0;    // km/h — otomatik kilit
const kMotorWarn     = 95.0;    // °C
const kMotorDanger   = 105.0;   // °C
const kBattWarn      = 11.5;    // V
const kBattDanger    = 10.8;    // V
const kParkWarn      = 80.0;    // cm
const kParkDanger    = 40.0;    // cm

// ─── RENKLER ───
class C {
  static const bg0   = Color(0xFF080A0C);
  static const bg1   = Color(0xFF0D1014);
  static const bg2   = Color(0xFF111518);
  static const bg3   = Color(0xFF181D22);
  static const bg4   = Color(0xFF1E252C);
  static const green = Color(0xFF00E87A);
  static const gDim  = Color(0x1F00E87A);
  static const amber = Color(0xFFFFB020);
  static const aDim  = Color(0x1FFFB020);
  static const red   = Color(0xFFFF4545);
  static const rDim  = Color(0x1FFF4545);
  static const blue  = Color(0xFF3D9EFF);
  static const bDim  = Color(0x1A3D9EFF);
  static const t1    = Color(0xFFF0F4F8);
  static const t2    = Color(0xFF8A9BB0);
  static const t3    = Color(0xFF4A5A6A);
  static const bord  = Color(0x0FFFFFFF);
  static const bord2 = Color(0x1AFFFFFF);
}
