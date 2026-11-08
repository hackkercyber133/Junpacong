import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/liquid_nav_bar.dart';
import '../widgets/mini_player.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'search_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tab = 0;

  static const _items = [
    NavItemData(Icons.home_rounded, 'Beranda', JP.gradMain),
    NavItemData(Icons.search_rounded, 'Cari', JP.gradCyan),
    NavItemData(Icons.favorite_rounded, 'Favorit', JP.gradOrange),
  ];

  @override
  void initState() {
    super.initState();
    // Android 13+: izin notifikasi untuk kontrol musik di notifikasi/lockscreen
    Permission.notification.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [HomeScreen(), SearchScreen(), LibraryScreen()],
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniPlayer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
              child: LiquidNavBar(
                index: _tab,
                items: _items,
                onTap: (i) => setState(() => _tab = i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
