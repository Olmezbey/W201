import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'utils/car_state.dart';
import 'utils/constants.dart';
import 'services/mqtt_service.dart';
import 'services/ble_service.dart';
import 'screens/lock_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: C.bg0,
  ));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const E190App());
}

class E190App extends StatelessWidget {
  const E190App({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CarState(),
      child: MaterialApp(
        title: 'E190 · $kPlate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: C.bg0,
          colorScheme: const ColorScheme.dark(primary: C.green, surface: C.bg2, error: C.red),
          fontFamily: 'Rajdhani',
          useMaterial3: true,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        home: const LockScreen(),
      ),
    );
  }
}

// Servisler LockScreen geçildikten sonra başlar
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late MqttService _mqtt;
  late BleService  _ble;

  @override
  void initState() {
    super.initState();
    final car = context.read<CarState>();
    _mqtt = MqttService(car);
    _ble  = BleService(car, _mqtt);
    _mqtt.connect();
    _ble.start();
  }

  @override
  void dispose() {
    _mqtt.disconnect();
    _ble.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const MainShell();
}
