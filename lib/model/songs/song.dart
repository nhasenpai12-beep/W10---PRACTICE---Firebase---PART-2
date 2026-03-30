class Song {
  final String id;
  final String title;
  final String artistId;
  final Duration duration;
  final Uri imageUrl;
  final int likes;

  Song({
    required this.id,
    required this.title,
    required this.artistId,
    required this.duration,
    required this.imageUrl,
    this.likes = 0,
  });

  Song copyWith({int? likes}) {
    return Song(
      id: this.id,
      title: this.title,
      artistId: this.artistId,
      duration: this.duration,
      imageUrl: this.imageUrl,
      likes: likes ?? this.likes,
    );
  }

  @override
  String toString() {
    return 'Song(id: $id, title: $title, artist id: $artistId, duration: $duration, likes: $likes)';
  }
}
