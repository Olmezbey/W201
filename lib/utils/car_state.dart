import 'package:flutter/material.dart';
import 'constants.dart';

enum LockState  { locked, unlocked }
enum AlarmState { armed, triggered }
enum ConnState  { disconnected, connecting, connected }

class CarState extends ChangeNotifier {
  ConnState  conn     = ConnState.disconnected;
  double     bleRssi  = -999;
  bool       bleNear  = false;

  LockState  lock      = LockState.locked;
  bool       windows   = false;
  bool       led       = false;
  Color      ledColor  = C.green;
  double     ledBright = 0.7;
  bool       immob     = false;
  AlarmState alarm     = AlarmState.armed;

  // Sensörler
  double motorTemp  = 92;
  double batt       = 13.8;
  double cabinTemp  = 24;
  double cabinHumid = 62;
  double frontDist  = 180;
  double rearDist   = 220;
  int    gpsSats    = 9;
  double speed      = 0;
  double lat        = 41.0082;
  double lon        = 28.9784;

  // İstatistik
  final List<double> weekKm = [34, 12, 67, 45, 89, 23, 87];
  double totalKm   = 128450;
  double monthKm   = 1234;
  double driveScore = 83;

  // Renk hesaplama
  Color get motorColor => motorTemp >= kMotorDanger ? C.red  : motorTemp >= kMotorWarn ? C.amber : C.green;
  Color get battColor  => batt  <= kBattDanger  ? C.red  : batt  <= kBattWarn  ? C.amber : C.green;
  Color get frontColor => frontDist <= kParkDanger ? C.red  : frontDist <= kParkWarn ? C.amber : C.green;
  Color get rearColor  => rearDist  <= kParkDanger ? C.red  : rearDist  <= kParkWarn ? C.amber : C.green;

  void setConn(ConnState s) { conn = s; notifyListeners(); }
  void setBle(double rssi)  { bleRssi = rssi; bleNear = rssi > kBleNear; notifyListeners(); }

  void updateGps({double? s, double? la, double? lo, int? sats}) {
    if (s    != null) speed  = s;
    if (la   != null) lat    = la;
    if (lo   != null) lon    = lo;
    if (sats != null) gpsSats = sats;
    if (speed > kAutoLockSpeed && lock == LockState.unlocked) {
      lock = LockState.locked;
    }
    notifyListeners();
  }

  void updateSensors({double? mt, double? b, double? ct, double? ch, double? fd, double? rd}) {
    if (mt != null) motorTemp  = mt;
    if (b  != null) batt       = b;
    if (ct != null) cabinTemp  = ct;
    if (ch != null) cabinHumid = ch;
    if (fd != null) frontDist  = fd;
    if (rd != null) rearDist   = rd;
    notifyListeners();
  }

  void toggleLock()        { lock    = lock == LockState.locked ? LockState.unlocked : LockState.locked; notifyListeners(); }
  void toggleWindows()     { windows = !windows; notifyListeners(); }
  void toggleLed()         { led     = !led;     notifyListeners(); }
  void toggleImmob()       { immob   = !immob;   notifyListeners(); }
  void setLedColor(Color c){ ledColor  = c;       notifyListeners(); }
  void setLedBright(double v){ ledBright = v;     notifyListeners(); }
  void triggerAlarm()      { alarm = AlarmState.triggered; notifyListeners(); }
  void resetAlarm()        { alarm = AlarmState.armed;     notifyListeners(); }
}
