import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/track.dart';

/// Sumber musik: Jamendo (katalog musik legal & bebas iklan).
/// audioformat=mp32 => stream selalu MP3 (bukan mp4/video).
class JamendoService {
  static const String clientId = '65611029';
  static const String _base = 'https://api.jamendo.com/v3.0';

  static Future<List<Track>> _fetch(Map<String, String> extra,
      {int limit = 30}) async {
    final params = <String, String>{
      'client_id': clientId,
      'format': 'json',
      'limit': '$limit',
      'audioformat': 'mp32',
      'imagesize': '300',
      ...extra,
    };
    final uri = Uri.parse('$_base/tracks/').replace(queryParameters: params);
    final res = await http.get(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw Exception('Server error ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (data['results'] as List?) ?? const [];
    return results
        .map((e) => Track.fromJamendo(e as Map<String, dynamic>))
        .where((t) => t.audio.isNotEmpty)
        .toList();
  }

  static Future<List<Track>> trending() =>
      _fetch({'order': 'popularity_week'});

  static Future<List<Track>> newest() =>
      _fetch({'order': 'releasedate_desc'});

  /// Musik berlirik bahasa Indonesia (filter lang=id). Kalau hasilnya
  /// kosong, cadangannya pencarian kata kunci "indonesia".
  static Future<List<Track>> indonesia() async {
    final r = await _fetch({'lang': 'id', 'order': 'popularity_month'});
    if (r.isNotEmpty) return r;
    return _fetch({'search': 'indonesia', 'order': 'popularity_month'});
  }

  static Future<List<Track>> byTag(String tag) =>
      _fetch({'tags': tag, 'order': 'popularity_month'});

  static Future<List<Track>> search(String query) =>
      _fetch({'search': query, 'order': 'relevance'}, limit: 40);
}
