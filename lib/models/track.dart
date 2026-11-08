class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String image;
  final String audio; // URL stream MP3
  final int duration; // detik

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.image,
    required this.audio,
    required this.duration,
  });

  factory Track.fromJamendo(Map<String, dynamic> j) => Track(
        id: j['id'].toString(),
        title: (j['name'] ?? 'Tanpa judul').toString(),
        artist: (j['artist_name'] ?? 'Unknown').toString(),
        album: (j['album_name'] ?? '').toString(),
        image: (j['image'] ?? j['album_image'] ?? '').toString(),
        audio: (j['audio'] ?? '').toString(),
        duration: int.tryParse('${j['duration']}') ?? 0,
      );

  factory Track.fromJson(Map<String, dynamic> j) => Track(
        id: j['id'] as String,
        title: j['title'] as String,
        artist: j['artist'] as String,
        album: j['album'] as String,
        image: j['image'] as String,
        audio: j['audio'] as String,
        duration: j['duration'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'image': image,
        'audio': audio,
        'duration': duration,
      };
}
