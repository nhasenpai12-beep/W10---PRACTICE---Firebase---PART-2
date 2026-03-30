import 'package:flutter/material.dart';
import '../../../../data/repositories/artist/artist_repository.dart';
import '../../../../model/artist/artist.dart';
import '../../../../model/comments/comment.dart';
import '../../../../model/songs/song.dart';

class ArtistDetailViewModel extends ChangeNotifier {
  final ArtistRepository artistRepository;
  final Artist artist;

  bool isLoading = true;
  Object? error;
  List<Song> songs = [];
  List<Comment> comments = [];

  ArtistDetailViewModel({
    required this.artistRepository,
    required this.artist,
  }) {
    fetchData();
  }

  Future<void> fetchData({bool forceFetch = false}) async {
    final bool shouldShowLoading =
        forceFetch || (songs.isEmpty && comments.isEmpty);
    if (shouldShowLoading) {
      isLoading = true;
      notifyListeners();
    }

    Object? nextError;

    try {
      songs = await artistRepository.fetchArtistSongs(
        artist.id,
        forceFetch: forceFetch,
      );
    } catch (e) {
      nextError = e;
    }

    try {
      comments = await artistRepository.fetchArtistComments(
        artist.id,
        forceFetch: forceFetch,
      );
    } catch (e) {
      nextError ??= e;
    }

    error = nextError;

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await fetchData(forceFetch: true);
  }

  Future<bool> addComment(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return false;
    }

    try {
      final Comment comment =
          await artistRepository.postArtistComment(artist.id, trimmed);
      comments = [comment, ...comments];
      error = null;
      notifyListeners();
      return true;
    } catch (e) {
      error = e;
      notifyListeners();
      return false;
    }
  }
}
