import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mjpeg_player/mjpeg_player.dart';
import '../utils/constants.dart';

class CameraScreen extends StatefulWidget {
  final String label, url;
  const CameraScreen({super.key, required this.label, required this.url});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _front = true;

  @override
  void initState() {
    super.initState();
    _front = widget.label == 'ÖN';
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = _front ? kCamFront : kCamRear;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // MJPEG stream
        Center(
          child: MjpegPlayer(
            stream: url,
            fit: BoxFit.contain,
            error: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.videocam_off_rounded, color: C.t3, size: 48),
              SizedBox(height: 12),
              Text('ESP32-CAM bağlanamıyor', style: TextStyle(color: C.t3, fontSize: 13)),
              Text('WiFi: 192.168.4.x', style: TextStyle(fontFamily: 'JetBrainsMono', color: C.t3, fontSize: 11)),
            ])),
            loading: const Center(child: CircularProgressIndicator(color: C.green)),
          ),
        ),
        // Üst bar
        Positioned(top: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.black87, Colors.transparent]),
            ),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Row(children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: C.red)),
                const SizedBox(width: 6),
                Text('${_front ? "ÖN" : "ARKA"} KAMERA · CANLI',
                    style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: Colors.white, letterSpacing: 0.1)),
              ]),
            ]),
          ),
        ),
        // Kamera geçiş
        Positioned(bottom: 24, left: 0, right: 0,
          child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _CamTab('ÖN',   _front,  () => setState(() => _front = true)),
              const SizedBox(width: 8),
              _CamTab('ARKA', !_front, () => setState(() => _front = false)),
            ]),
          ),
        ),
        // Bilgi bar
        Positioned(bottom: 24, right: 16,
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: const [
            Text('800×600',   style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9, color: Colors.white38)),
            Text('~15 FPS',   style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9, color: Colors.white38)),
            Text('~200ms',    style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9, color: Colors.white38)),
          ]),
        ),
      ]),
    );
  }
}

class _CamTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _CamTab(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? C.gDim : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? C.green.withOpacity(0.4) : Colors.white24),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? C.green : Colors.white54, letterSpacing: 0.1)),
      ),
    );
  }
}
