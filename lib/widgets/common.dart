import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/track.dart';
import '../services/player_service.dart';
import '../theme.dart';

/// Ikon bergaya 3D: gradient, highlight kaca, bayangan jatuh & inner glow.
class Icon3D extends StatelessWidget {
  final IconData icon;
  final double size;
  final List<Color> colors;
  final bool circle;

  const Icon3D(
    this.icon, {
    super.key,
    this.size = 22,
    this.colors = JP.gradMain,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    final box = size * 1.75;
    final radius = circle ? box / 2 : box * .32;
    return Container(
      width: box,
      height: box,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: .55),
            blurRadius: box * .35,
            offset: Offset(0, box * .16),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: .3),
            blurRadius: 3,
            offset: const Offset(-1.5, -1.5),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // highlight kaca di bagian atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: box * .5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(radius), bottom: const Radius.circular(40)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: .38),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Icon(
            icon,
            size: size,
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.black38, blurRadius: 5, offset: Offset(1.5, 3)),
            ],
          ),
        ],
      ),
    );
  }
}

class CoverImage extends StatelessWidget {
  final String url;
  final double size;
  final double radius;
  const CoverImage({super.key, required this.url, this.size = 56, this.radius = 14});

  Widget _placeholder() => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A2250), Color(0xFF3B1E4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(Icons.music_note_rounded,
            color: Colors.white54, size: size * .45),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url.isEmpty
          ? _placeholder()
          : CachedNetworkImage(
              imageUrl: url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, __) => _placeholder(),
              errorWidget: (_, __, ___) => _placeholder(),
            ),
    );
  }
}

class TrackTile extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;
  const TrackTile({super.key, required this.track, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PlayerService.instance,
      builder: (context, _) {
        final s = PlayerService.instance;
        final isCur = s.current?.id == track.id;
        final fav = s.isFav(track);
        final dur = track.duration > 0 ? ' • ${fmt(Duration(seconds: track.duration))}' : '';
        return ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
          leading: CoverImage(url: track.image, size: 54, radius: 14),
          title: Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isCur ? JP.pink : Colors.white,
            ),
          ),
          subtitle: Text(
            '${track.artist}$dur',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 12.5),
          ),
          trailing: IconButton(
            onPressed: () => s.toggleFav(track),
            icon: Icon(
              fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: fav ? JP.pink : Colors.white38,
            ),
          ),
        );
      },
    );
  }
}

class TrackCard extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;
  const TrackCard({super.key, required this.track, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: JP.purple.withValues(alpha: .35),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CoverImage(url: track.image, size: 140, radius: 22),
            ),
            const SizedBox(height: 10),
            Text(track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
            const SizedBox(height: 2),
            Text(track.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// Memuat Future<List<Track>> dengan loading & error + tombol coba lagi.
class TracksFuture extends StatelessWidget {
  final Future<List<Track>> future;
  final VoidCallback onRetry;
  final Widget Function(List<Track>) builder;
  final double loadingHeight;
  const TracksFuture({
    super.key,
    required this.future,
    required this.onRetry,
    required this.builder,
    this.loadingHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Track>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return SizedBox(
            height: loadingHeight,
            child: const Center(child: CircularProgressIndicator(color: JP.pink)),
          );
        }
        if (snap.hasError || (snap.data?.isEmpty ?? true)) {
          return SizedBox(
            height: loadingHeight,
            child: Center(
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Gagal memuat. Coba lagi'),
              ),
            ),
          );
        }
        return builder(snap.data!);
      },
    );
  }
}
