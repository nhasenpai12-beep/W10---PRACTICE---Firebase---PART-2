import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';

class SongRepositoryFirebase extends SongRepository {
  static const String _baseUrl =
      'w10-database-default-rtdb.asia-southeast1.firebasedatabase.app';
  final Uri songsUri = Uri.https(
    _baseUrl,
    '/songs.json',
  );

  @override
  Future<List<Song>> fetchSongs({bool forceFetch = false}) async {
    final http.Response response = await http.get(songsUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);
      List<Song> result = [];
      for (final entry in songJson.entries) {
        result.add(SongDto.fromJson(entry.key, entry.value));
      }
      return result;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load songs');
    }
  }

  @override
  Future<Song?> fetchSongById(String id) async {
    final Uri songUri = Uri.https(
      _baseUrl,
      '/songs/$id.json',
    );

    final http.Response response = await http.get(songUri);

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') {
        return null;
      }

      final Map<String, dynamic> songJson = json.decode(response.body);
      return SongDto.fromJson(id, songJson);
    } else {
      throw Exception('Failed to load song');
    }
  }

  @override
  Future<Song> likeSong(Song song) async {
    final Song updatedSong = song.copyWith(likes: song.likes + 1);
    final Uri songUri = Uri.https(
      _baseUrl,
      '/songs/${song.id}.json',
    );

    final http.Response response = await http.patch(
      songUri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({SongDto.likesKey: updatedSong.likes}),
    );

    if (response.statusCode == 200) {
      return updatedSong;
    } else {
      throw Exception('Failed to like song');
    }
  }
}
