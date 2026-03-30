import 'dart:convert';

import 'package:http/http.dart' as http;
 
import '../../../model/artist/artist.dart';
import '../../dtos/artist_dto.dart';
import 'artist_repository.dart';

class ArtistRepositoryFirebase implements ArtistRepository {
  static const String _baseUrl =
      'w10-database-default-rtdb.asia-southeast1.firebasedatabase.app';
  List<Artist>? _cachedArtists;
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
}
