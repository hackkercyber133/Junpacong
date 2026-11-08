import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/track.dart';
import '../theme.dart';

/// Pemutar musik tunggal (singleton). Berjalan sebagai foreground service
/// lewat just_audio_background, jadi musik tetap main saat layar mati /
/// aplikasi diminimalkan, lengkap dengan kontrol di notifikasi & lockscreen.
class PlayerService extends ChangeNotifier {
  PlayerService._();
  static final PlayerService instance = PlayerService._();

  final AudioPlayer player = AudioPlayer();

  List<Track> queue = [];
  int index = -1;
  bool shuffle = false;
  LoopMode loop = LoopMode.off;
  double speed = 1.0;
  List<Track> favorites = [];
  DateTime? sleepEnd;
  Timer? _sleepTimer;

  Track? get current =>
      (index >= 0 && index < queue.length) ? queue[index] : null;

  Future<void> init() async {
    await _loadFavs();
    player.currentIndexStream.listen((i) {
      if (i != null && i != index) {
        index = i;
        notifyListeners();
      }
    });
    player.playerStateStream.listen((_) => notifyListeners());
    player.playbackEventStream.listen((_) {}, onError: (Object e, StackTrace st) {
      JP.toast('Gagal memutar lagu, coba lagu lain / cek internet.');
    });
  }

  AudioSource _src(Track t) => AudioSource.uri(
        Uri.parse(t.audio),
        tag: MediaItem(
          id: t.id,
          title: t.title,
          artist: t.artist,
          album: t.album,
          artUri: t.image.isEmpty ? null : Uri.tryParse(t.image),
          duration: t.duration > 0 ? Duration(seconds: t.duration) : null,
        ),
      );

  Future<void> playList(List<Track> tracks, int start) async {
    if (tracks.isEmpty) return;
    try {
      queue = List.of(tracks);
      index = start;
      notifyListeners();
      await player.setAudioSources(
        queue.map(_src).toList(),
        initialIndex: start,
        initialPosition: Duration.zero,
      );
      await player.setSpeed(speed);
      unawaited(player.play());
    } catch (e) {
      JP.toast('Gagal memutar lagu. Cek koneksi internet.');
    }
  }

  Future<void> toggleShuffle() async {
    shuffle = !shuffle;
    await player.setShuffleModeEnabled(shuffle);
    if (shuffle) await player.shuffle();
    notifyListeners();
  }

  Future<void> cycleLoop() async {
    loop = switch (loop) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    await player.setLoopMode(loop);
    notifyListeners();
  }

  Future<void> setSpeed(double s) async {
    speed = s;
    await player.setSpeed(s);
    notifyListeners();
  }

  void setSleep(Duration? d) {
    _sleepTimer?.cancel();
    if (d == null) {
      sleepEnd = null;
    } else {
      sleepEnd = DateTime.now().add(d);
      _sleepTimer = Timer(d, () {
        player.pause();
        sleepEnd = null;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  // ---------- Favorit ----------
  bool isFav(Track t) => favorites.any((x) => x.id == t.id);

  Future<void> toggleFav(Track t) async {
    if (isFav(t)) {
      favorites.removeWhere((x) => x.id == t.id);
    } else {
      favorites.insert(0, t);
    }
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(
        'favs', favorites.map((e) => jsonEncode(e.toJson())).toList());
  }

  Future<void> _loadFavs() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList('favs') ?? [];
    favorites = raw
        .map((e) => Track.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }
}
