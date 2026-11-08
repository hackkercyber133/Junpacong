import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _duration = Duration(milliseconds: 2800);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_duration, widget.onDone);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/splash.jpg', fit: BoxFit.cover),
          // gelapkan bagian bawah supaya teks terbaca
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, .45, 1],
                colors: [
                  Colors.black.withValues(alpha: .35),
                  Colors.transparent,
                  Colors.black.withValues(alpha: .92),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 18),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 900),
                  builder: (context, v, child) => Opacity(opacity: v, child: child),
                  child: const Text(
                    'junpacong',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 12)],
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOut,
                    builder: (context, v, child) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                          offset: Offset(0, 20 * (1 - v)), child: child),
                    ),
                    child: Column(
                      children: [
                        // garis yang terisi sebagai indikator loading
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: _duration,
                          builder: (context, v, _) => Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 3,
                              width: (MediaQuery.of(context).size.width - 56) * v,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                gradient: const LinearGradient(colors: JP.gradMain),
                                boxShadow: [
                                  BoxShadow(
                                    color: JP.pink.withValues(alpha: .7),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'kata jaol, di telpon kok berdering eh gatau nya lagi gaya miring',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ShaderMask(
                          shaderCallback: (r) =>
                              const LinearGradient(colors: [JP.cyan, JP.pink])
                                  .createShader(r),
                          child: const Text(
                            '#jaol  #nyoks  #nay  #ibor',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 34),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
