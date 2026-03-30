import 'dart:convert';

import 'package:http/http.dart' as http;
 
import '../../../model/artist/artist.dart';
import '../../../model/comments/comment.dart';
import '../../../model/songs/song.dart';
import '../../dtos/artist_dto.dart';
import '../../dtos/comment_dto.dart';
import '../../dtos/song_dto.dart';
import 'artist_repository.dart';

class ArtistRepositoryFirebase implements ArtistRepository {
  static const String _baseUrl =
      'w10-database-default-rtdb.asia-southeast1.firebasedatabase.app';
  List<Artist>? _cachedArtists;
  final Map<String, List<Song>> _cachedArtistSongs = {};
  final Map<String, List<Comment>> _cachedArtistComments = {};
  final Uri artistsUri = Uri.https(
    _baseUrl,
    '/artists.json',
  );

  @override
  Future<List<Artist>> fetchArtists({bool forceFetch = false}) async {
    if (!forceFetch && _cachedArtists != null) {
      return _cachedArtists!;
    }

    final http.Response response = await http.get(artistsUri);

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') {
        _cachedArtists = [];
        return _cachedArtists!;
      }

      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Artist> result = [];
      for (final entry in songJson.entries) {
        result.add(ArtistDto.fromJson(entry.key, entry.value));
      }
      _cachedArtists = result;
      return result;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {
    final Uri artistUri = Uri.https(
      _baseUrl,
      '/artists/$id.json',
    );

    final http.Response response = await http.get(artistUri);

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') {
        return null;
      }

      final Map<String, dynamic> artistJson = json.decode(response.body);
      return ArtistDto.fromJson(id, artistJson);
    } else {
      throw Exception('Failed to load artist');
    }
  }

  @override
  Future<List<Song>> fetchArtistSongs(
    String artistId, {
    bool forceFetch = false,
  }) async {
    if (!forceFetch && _cachedArtistSongs.containsKey(artistId)) {
      return _cachedArtistSongs[artistId]!;
    }

    final Uri filteredSongsUri = Uri.https(
      _baseUrl,
      '/songs.json',
      {
        'orderBy': '"artistId"',
        'equalTo': '"$artistId"',
      },
    );

    http.Response response = await http.get(filteredSongsUri);
    if (response.statusCode != 200) {
      final Uri allSongsUri = Uri.https(
        _baseUrl,
        '/songs.json',
      );
      response = await http.get(allSongsUri);
    }

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') {
        _cachedArtistSongs[artistId] = [];
        return _cachedArtistSongs[artistId]!;
      }

      final Map<String, dynamic> songJson = json.decode(response.body);
      final List<Song> result = [];
      for (final entry in songJson.entries) {
        if (entry.value is! Map<String, dynamic>) {
          continue;
        }
        final Map<String, dynamic> value =
            Map<String, dynamic>.from(entry.value);
        if (value[SongDto.artistIdKey] != artistId) {
          continue;
        }
        result.add(SongDto.fromJson(entry.key, value));
      }

      _cachedArtistSongs[artistId] = result;
      return result;
    } else {
      throw Exception('Failed to load artist songs: ${response.statusCode}');
    }
  }

  @override
  Future<List<Comment>> fetchArtistComments(
    String artistId, {
    bool forceFetch = false,
  }) async {
    if (!forceFetch && _cachedArtistComments.containsKey(artistId)) {
      return _cachedArtistComments[artistId]!;
    }

    final Uri commentsUri = Uri.https(
      _baseUrl,
      '/artist_comments/$artistId.json',
    );

    final http.Response response = await http.get(commentsUri);

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') {
        _cachedArtistComments[artistId] = [];
        return _cachedArtistComments[artistId]!;
      }

      final Map<String, dynamic> commentJson = json.decode(response.body);
      final List<Comment> result = [];
      for (final entry in commentJson.entries) {
        result.add(CommentDto.fromJson(entry.key, artistId, entry.value));
      }

      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _cachedArtistComments[artistId] = result;
      return result;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  @override
  Future<Comment> postArtistComment(String artistId, String text) async {
    final String trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      throw Exception('Comment cannot be empty');
    }

    final Uri commentUri = Uri.https(
      _baseUrl,
      '/artist_comments/$artistId.json',
    );

    final DateTime createdAt = DateTime.now();
    final http.Response response = await http.post(
      commentUri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        CommentDto.textKey: trimmedText,
        CommentDto.createdAtKey: createdAt.millisecondsSinceEpoch,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = json.decode(response.body);
      final String id = responseJson['name'] ?? '';
      final Comment comment = Comment(
        id: id,
        artistId: artistId,
        text: trimmedText,
        createdAt: createdAt,
      );

      final List<Comment> current =
          List.of(_cachedArtistComments[artistId] ?? []);
      current.insert(0, comment);
      _cachedArtistComments[artistId] = current;

      return comment;
    } else {
      throw Exception('Failed to post comment');
    }
  }
}
