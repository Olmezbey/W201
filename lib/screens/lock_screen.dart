import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';
import 'main_shell.dart';
import '../main.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  bool   _err = false;
  bool   _ok  = false;

  void _tap(String d) {
    if (_pin.length >= 4) return;
    setState(() { _pin += d; _err = false; });
    if (_pin.length == 4) _check();
  }

  void _del() => setState(() { if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1); _err = false; });

  void _check() {
    if (_pin == kPinCode) {
      setState(() => _ok = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AppRoot(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      });
    } else {
      setState(() { _err = true; _pin = ''; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg0,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Logo & araç bilgisi
            Animate(
              effects: const [FadeEffect(duration: Duration(milliseconds: 800)), SlideEffect(begin: Offset(0, -0.1))],
              child: Column(children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: C.gDim,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: C.green.withOpacity(0.3), width: 1),
                  ),
                  child: const Icon(Icons.directions_car_rounded, color: C.green, size: 36),
                ),
                const SizedBox(height: 16),
                const Text(kCarName, style: TextStyle(fontFamily: 'Syne', fontSize: 22, fontWeight: FontWeight.w700, color: C.t1, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(kPlate, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 14, color: C.green, letterSpacing: 3)),
                const SizedBox(height: 4),
                const Text(kCarModel, style: TextStyle(fontSize: 12, color: C.t3, letterSpacing: 1)),
              ]),
            ),
            const Spacer(),
            // PIN noktalar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 14, height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _pin.length
                        ? (_err ? C.red : _ok ? C.green : C.green)
                        : C.bg4,
                    border: Border.all(
                      color: i < _pin.length ? (_err ? C.red : C.green) : C.bord2,
                      width: 1,
                    ),
                    boxShadow: i < _pin.length && !_err
                        ? [BoxShadow(color: C.green.withOpacity(0.4), blurRadius: 8)]
                        : null,
                  ),
                )),
              ),
            ),
            if (_err) ...[
              const SizedBox(height: 12),
              Animate(
                effects: const [ShakeEffect()],
                child: const Text('Hatalı PIN', style: TextStyle(color: C.red, fontSize: 13, letterSpacing: 0.5)),
              ),
            ],
            const SizedBox(height: 36),
            // Tuş takımı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  _row(['1','2','3']),
                  const SizedBox(height: 12),
                  _row(['4','5','6']),
                  const SizedBox(height: 12),
                  _row(['7','8','9']),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 72),
                      _key('0'),
                      GestureDetector(
                        onTap: _del,
                        child: Container(
                          width: 72, height: 72,
                          alignment: Alignment.center,
                          child: const Icon(Icons.backspace_outlined, color: C.t3, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _row(List<String> digits) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: digits.map(_key).toList(),
  );

  Widget _key(String d) => GestureDetector(
    onTap: () => _tap(d),
    child: Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        color: C.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.bord, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(d, style: const TextStyle(fontFamily: 'Syne', fontSize: 24, fontWeight: FontWeight.w600, color: C.t1)),
    ),
  );
}
