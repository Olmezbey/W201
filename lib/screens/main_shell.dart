import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/car_state.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';
import 'map_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  static const _pages = [
    DashboardScreen(),
    MapScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final car = context.watch<CarState>();
    final alarm = car.alarm == AlarmState.triggered;

    return Scaffold(
      backgroundColor: C.bg0,
      // Alarm banner
      body: Column(children: [
        if (alarm) _AlarmBanner(onDismiss: () => car.resetAlarm()),
        Expanded(child: _pages[_idx]),
      ]),
      bottomNavigationBar: _NavBar(
        current: _idx,
        onTap: (i) => setState(() => _idx = i),
      ),
    );
  }
}

class _AlarmBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  const _AlarmBanner({required this.onDismiss});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.rDim,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 8, left: 16, right: 16),
      child: Row(children: [
        const _PulseDot(color: C.red),
        const SizedBox(width: 10),
        const Expanded(child: Text('⚠  ALARM — Titreşim/Hareket Algılandı', style: TextStyle(color: C.red, fontSize: 13, fontWeight: FontWeight.w600))),
        GestureDetector(onTap: onDismiss, child: const Icon(Icons.close, color: C.red, size: 18)),
      ]),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color)),
  );
}

class _NavBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _NavBar({required this.current, required this.onTap});

  static const _items = [
    (Icons.dashboard_rounded,       Icons.dashboard_outlined,       'PANEL'),
    (Icons.location_on_rounded,     Icons.location_on_outlined,     'HARİTA'),
    (Icons.bar_chart_rounded,       Icons.bar_chart_outlined,       'STATS'),
    (Icons.settings_rounded,        Icons.settings_outlined,        'AYARLAR'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: C.bg1,
        border: Border(top: BorderSide(color: C.bord, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(_items.length, (i) {
              final (activeIco, ico, label) = _items[i];
              final active = i == current;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(active ? activeIco : ico, size: 22, color: active ? C.green : C.t3),
                      const SizedBox(height: 3),
                      Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: active ? C.green : C.t3, letterSpacing: 0.08)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
