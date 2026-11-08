import 'package:flutter/material.dart';

class JP {
  static const bg = Color(0xFF0A0A14);
  static const surface = Color(0xFF15152A);
  static const purple = Color(0xFF8B5CF6);
  static const pink = Color(0xFFEC4899);
  static const cyan = Color(0xFF22D3EE);
  static const orange = Color(0xFFFB923C);
  static const green = Color(0xFF34D399);

  static const List<Color> gradMain = [purple, pink];
  static const List<Color> gradCyan = [cyan, Color(0xFF6366F1)];
  static const List<Color> gradOrange = [orange, pink];
  static const List<Color> gradGreen = [green, cyan];

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void toast(String msg) {
    messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: surface,
      ));
  }

  static ThemeData theme() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: purple,
          secondary: pink,
          surface: surface,
        ),
        sliderTheme: SliderThemeData(
          trackHeight: 5,
          activeTrackColor: pink,
          inactiveTrackColor: Colors.white.withValues(alpha: .14),
          thumbColor: Colors.white,
          overlayColor: pink.withValues(alpha: .2),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        ),
      );
}

String fmt(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}
