import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'screens/root_shell.dart';
import 'screens/splash_screen.dart';
import 'services/player_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: JP.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Background playback: musik lanjut saat layar mati / app diminimalkan
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.junpacong.audio',
    androidNotificationChannelName: 'junpacong',
    androidNotificationOngoing: true,
  );
  await PlayerService.instance.init();
  runApp(const JunpacongApp());
}

class JunpacongApp extends StatefulWidget {
  const JunpacongApp({super.key});

  @override
  State<JunpacongApp> createState() => _JunpacongAppState();
}

class _JunpacongAppState extends State<JunpacongApp> {
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'junpacong',
      debugShowCheckedModeBanner: false,
      theme: JP.theme(),
      scaffoldMessengerKey: JP.messengerKey,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: _ready
            ? const RootShell(key: ValueKey('root'))
            : SplashScreen(
                key: const ValueKey('splash'),
                onDone: () => setState(() => _ready = true),
              ),
      ),
    );
  }
}
