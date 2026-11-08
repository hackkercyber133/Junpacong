import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../services/player_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

void openPlayer(BuildContext context) {
  Navigator.of(context).push(PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) => const PlayerScreen(),
    transitionsBuilder: (_, anim, __, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
  ));
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  double? _drag;

  @override
  Widget build(BuildContext context) {
    final s = PlayerService.instance;
    final width = MediaQuery.of(context).size.width;
    final coverSize = math.min(width * .78, 340.0);

    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final t = s.current;
        if (t == null) {
          return const Scaffold(body: Center(child: Text('Belum ada lagu')));
        }
        final fav = s.isFav(t);
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  JP.purple.withValues(alpha: .55),
                  const Color(0xFF14102A),
                  JP.bg,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                        ),
                        const Expanded(
                          child: Text('Sedang diputar',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        IconButton(
                          onPressed: () => _queueSheet(context),
                          icon: const Icon(Icons.queue_music_rounded),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: StreamBuilder<bool>(
                        stream: s.player.playingStream,
                        builder: (context, snap) {
                          final playing = snap.data ?? false;
                          return AnimatedScale(
                            scale: playing ? 1.0 : .86,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutBack,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(34),
                                boxShadow: [
                                  BoxShadow(
                                    color: JP.pink.withValues(alpha: .38),
                                    blurRadius: 50,
                                    offset: const Offset(0, 24),
                                  ),
                                  BoxShadow(
                                    color: JP.purple.withValues(alpha: .35),
                                    blurRadius: 30,
                                    offset: const Offset(-8, 10),
                                  ),
                                ],
                              ),
                              child: CoverImage(
                                  url: t.image, size: coverSize, radius: 34),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text(t.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.white60)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => s.toggleFav(t),
                          icon: Icon(
                            fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: fav ? JP.pink : Colors.white70,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _seekBar(s, t.duration),
                  const SizedBox(height: 6),
                  _controls(s),
                  const SizedBox(height: 14),
                  _extras(context, s),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _seekBar(PlayerService s, int fallbackSec) {
    return StreamBuilder<Duration>(
      stream: s.player.positionStream,
      builder: (context, snap) {
        final pos = snap.data ?? Duration.zero;
        final total = s.player.duration ?? Duration(seconds: fallbackSec);
        final maxMs = math.max(1, total.inMilliseconds).toDouble();
        final value = (_drag ?? pos.inMilliseconds.toDouble()).clamp(0.0, maxMs);
        return Column(
          children: [
            Slider(
              value: value,
              min: 0,
              max: maxMs,
              onChanged: (v) => setState(() => _drag = v),
              onChangeEnd: (v) {
                s.player.seek(Duration(milliseconds: v.round()));
                setState(() => _drag = null);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(fmt(Duration(milliseconds: value.round())),
                      style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  Text(fmt(total),
                      style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _controls(PlayerService s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: s.toggleShuffle,
          icon: Icon(Icons.shuffle_rounded,
              color: s.shuffle ? JP.pink : Colors.white54, size: 26),
        ),
        IconButton(
          onPressed: () => s.player.seekToPrevious(),
          icon: const Icon(Icons.skip_previous_rounded, size: 44),
        ),
        StreamBuilder<PlayerState>(
          stream: s.player.playerStateStream,
          builder: (context, snap) {
            final st = snap.data;
            final playing = st?.playing ?? false;
            final proc = st?.processingState;
            final loading =
                proc == ProcessingState.loading || proc == ProcessingState.buffering;
            return GestureDetector(
              onTap: () {
                if (playing) {
                  s.player.pause();
                } else {
                  s.player.play();
                }
              },
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: JP.gradMain,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: JP.pink.withValues(alpha: .6),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: .35),
                      blurRadius: 5,
                      offset: const Offset(-3, -3),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: loading
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3),
                      )
                    : Icon(
                        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 46,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                              color: Colors.black38,
                              blurRadius: 6,
                              offset: Offset(1.5, 3)),
                        ],
                      ),
              ),
            );
          },
        ),
        IconButton(
          onPressed: () => s.player.seekToNext(),
          icon: const Icon(Icons.skip_next_rounded, size: 44),
        ),
        IconButton(
          onPressed: s.cycleLoop,
          icon: Icon(
            s.loop == LoopMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded,
            color: s.loop == LoopMode.off ? Colors.white54 : JP.pink,
            size: 26,
          ),
        ),
      ],
    );
  }

  Widget _extras(BuildContext context, PlayerService s) {
    final sleepLeft = s.sleepEnd?.difference(DateTime.now());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ExtraBtn(
          icon: Icons.bedtime_rounded,
          label: sleepLeft == null ? 'Sleep timer' : '${sleepLeft.inMinutes + 1} mnt',
          colors: JP.gradCyan,
          onTap: () => _sleepSheet(context),
        ),
        _ExtraBtn(
          icon: Icons.speed_rounded,
          label: '${s.speed}x',
          colors: JP.gradOrange,
          onTap: () => _speedSheet(context),
        ),
        _ExtraBtn(
          icon: Icons.queue_music_rounded,
          label: 'Antrian',
          colors: JP.gradGreen,
          onTap: () => _queueSheet(context),
        ),
      ],
    );
  }

  void _sleepSheet(BuildContext context) {
    final s = PlayerService.instance;
    _sheet(
      context,
      title: 'Sleep timer',
      children: [
        for (final m in [15, 30, 45, 60])
          ListTile(
            title: Text('$m menit'),
            onTap: () {
              s.setSleep(Duration(minutes: m));
              Navigator.pop(context);
            },
          ),
        ListTile(
          title: const Text('Matikan timer'),
          onTap: () {
            s.setSleep(null);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _speedSheet(BuildContext context) {
    final s = PlayerService.instance;
    _sheet(
      context,
      title: 'Kecepatan putar',
      children: [
        for (final v in [0.75, 1.0, 1.25, 1.5, 2.0])
          ListTile(
            title: Text('${v}x'),
            trailing: s.speed == v ? const Icon(Icons.check_rounded, color: JP.pink) : null,
            onTap: () {
              s.setSpeed(v);
              Navigator.pop(context);
            },
          ),
      ],
    );
  }

  void _queueSheet(BuildContext context) {
    final s = PlayerService.instance;
    showModalBottomSheet(
      context: context,
      backgroundColor: JP.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .7,
        maxChildSize: .92,
        builder: (context, controller) => Column(
          children: [
            const SizedBox(height: 14),
            const Text('Antrian lagu',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: s.queue.length,
                itemBuilder: (context, i) => TrackTile(
                  track: s.queue[i],
                  onTap: () {
                    s.player.seek(Duration.zero, index: i);
                    s.player.play();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sheet(BuildContext context,
      {required String title, required List<Widget> children}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: JP.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            ...children,
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ExtraBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;
  const _ExtraBtn(
      {required this.icon,
      required this.label,
      required this.colors,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon3D(icon, size: 20, colors: colors),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.white70)),
        ],
      ),
    );
  }
}
