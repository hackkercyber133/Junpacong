import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../screens/player_screen.dart';
import '../services/player_service.dart';
import '../theme.dart';
import 'common.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final s = PlayerService.instance;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final t = s.current;
        if (t == null) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => openPlayer(context),
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 6),
            padding: const EdgeInsets.fromLTRB(10, 8, 6, 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  JP.purple.withValues(alpha: .5),
                  JP.pink.withValues(alpha: .35),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: .1)),
              boxShadow: [
                BoxShadow(
                  color: JP.purple.withValues(alpha: .35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CoverImage(url: t.image, size: 44, radius: 12),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800)),
                          Text(t.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    StreamBuilder<PlayerState>(
                      stream: s.player.playerStateStream,
                      builder: (context, snap) {
                        final playing = snap.data?.playing ?? false;
                        return IconButton(
                          onPressed: () =>
                              playing ? s.player.pause() : s.player.play(),
                          icon: Icon(
                            playing
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                            size: 38,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () => s.player.seekToNext(),
                      icon: const Icon(Icons.skip_next_rounded, size: 30),
                    ),
                  ],
                ),
                StreamBuilder<Duration>(
                  stream: s.player.positionStream,
                  builder: (context, snap) {
                    final pos = snap.data?.inMilliseconds ?? 0;
                    final total = (s.player.duration?.inMilliseconds ??
                        t.duration * 1000);
                    final v = total <= 0 ? 0.0 : (pos / total).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.only(right: 4, top: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: v,
                          minHeight: 3,
                          backgroundColor: Colors.white.withValues(alpha: .12),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
