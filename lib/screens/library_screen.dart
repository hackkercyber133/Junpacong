import 'package:flutter/material.dart';

import '../services/player_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = PlayerService.instance;
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          final favs = s.favorites;
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                child: Row(
                  children: [
                    const Icon3D(Icons.favorite_rounded, size: 18, colors: JP.gradMain),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Favorit saya',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w900)),
                          Text('${favs.length} lagu',
                              style: const TextStyle(color: Colors.white54)),
                        ],
                      ),
                    ),
                    if (favs.isNotEmpty)
                      GestureDetector(
                        onTap: () => s.playList(favs, 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            gradient: const LinearGradient(colors: JP.gradMain),
                            boxShadow: [
                              BoxShadow(
                                color: JP.pink.withValues(alpha: .45),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.play_arrow_rounded),
                              SizedBox(width: 4),
                              Text('Putar',
                                  style: TextStyle(fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (favs.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: Text(
                      'Belum ada favorit.\nTekan ikon hati pada lagu untuk menyimpan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, height: 1.5),
                    ),
                  ),
                ),
              for (int i = 0; i < favs.length; i++)
                TrackTile(track: favs[i], onTap: () => s.playList(favs, i)),
            ],
          );
        },
      ),
    );
  }
}
