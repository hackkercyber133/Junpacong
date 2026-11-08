import 'package:flutter/material.dart';

import '../models/track.dart';
import '../services/jamendo_service.dart';
import '../services/player_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const genres = <String, List<dynamic>>{
    'Pop': ['pop', Icons.auto_awesome_rounded],
    'Chill': ['chill', Icons.waves_rounded],
    'Akustik': ['acoustic', Icons.music_note_rounded],
    'Rock': ['rock', Icons.electric_bolt_rounded],
    'Elektronik': ['electronic', Icons.graphic_eq_rounded],
    'Hip-Hop': ['hiphop', Icons.mic_external_on_rounded],
    'Jazz': ['jazz', Icons.piano_rounded],
    'Lo-fi': ['lofi', Icons.nightlight_round],
    'Klasik': ['classical', Icons.library_music_rounded],
    'Ambient': ['ambient', Icons.spa_rounded],
    'Reggae': ['reggae', Icons.beach_access_rounded],
    'Metal': ['metal', Icons.whatshot_rounded],
  };

  late Future<List<Track>> _trending;
  late Future<List<Track>> _newest;
  late Future<List<Track>> _indo;
  late Future<List<Track>> _genreTracks;
  String _genre = 'Pop';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _trending = JamendoService.trending();
    _newest = JamendoService.newest();
    _indo = JamendoService.indonesia();
    _loadGenre();
  }

  void _loadGenre() {
    _genreTracks = JamendoService.byTag(genres[_genre]![0] as String);
  }

  Future<void> _refresh() async {
    setState(_load);
    await Future.wait([_trending, _newest, _indo, _genreTracks]
        .map((f) => f.catchError((_) => <Track>[])));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: JP.pink,
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _header(context),
            _title('Lagi ramai minggu ini', Icons.local_fire_department_rounded,
                JP.gradOrange),
            _horizontal(_trending, () => setState(() => _trending = JamendoService.trending())),
            _title('Musik Indonesia', Icons.flag_rounded, JP.gradMain),
            _horizontal(_indo, () => setState(() => _indo = JamendoService.indonesia())),
            _title('Rilis terbaru', Icons.new_releases_rounded, JP.gradCyan),
            _horizontal(_newest, () => setState(() => _newest = JamendoService.newest())),
            _title('Jelajahi genre', Icons.category_rounded, JP.gradGreen),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  for (final e in genres.entries) _genreChip(e.key, e.value[1] as IconData),
                ],
              ),
            ),
            const SizedBox(height: 6),
            TracksFuture(
              future: _genreTracks,
              onRetry: () => setState(_loadGenre),
              loadingHeight: 180,
              builder: (list) => Column(
                children: [
                  for (int i = 0; i < list.length; i++)
                    TrackTile(
                      track: list[i],
                      onTap: () => PlayerService.instance.playList(list, i),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 6),
      child: Row(
        children: [
          const Icon3D(Icons.graphic_eq_rounded, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (r) =>
                      const LinearGradient(colors: [Colors.white, Color(0xFFE9D5FF)])
                          .createShader(r),
                  child: const Text('junpacong',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .5,
                          color: Colors.white)),
                ),
                const Text('musik tanpa iklan',
                    style: TextStyle(color: Colors.white54, fontSize: 12.5)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'junpacong',
              applicationVersion: '1.0.0',
              children: const [
                Text('Developer: Muhammad Ady Afriansyah'),
                SizedBox(height: 8),
                Text('Musik online tanpa iklan, stream MP3 dari Jamendo.'),
              ],
            ),
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _title(String text, IconData icon, List<Color> colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
      child: Row(
        children: [
          Icon3D(icon, size: 15, colors: colors),
          const SizedBox(width: 12),
          Text(text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _horizontal(Future<List<Track>> f, VoidCallback retry) {
    return TracksFuture(
      future: f,
      onRetry: retry,
      loadingHeight: 200,
      builder: (list) => SizedBox(
        height: 214,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, i) => TrackCard(
            track: list[i],
            onTap: () => PlayerService.instance.playList(list, i),
          ),
        ),
      ),
    );
  }

  Widget _genreChip(String name, IconData icon) {
    final sel = name == _genre;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() {
          _genre = name;
          _loadGenre();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: sel ? const LinearGradient(colors: JP.gradMain) : null,
            color: sel ? null : JP.surface,
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: JP.pink.withValues(alpha: .4),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: sel ? Colors.white : Colors.white54),
              const SizedBox(width: 8),
              Text(name,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
