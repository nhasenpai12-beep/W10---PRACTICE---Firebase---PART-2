import '../../../model/artist/artist.dart';
import '../../../model/comments/comment.dart';
import '../../../model/songs/song.dart';
import 'artist_repository.dart';

class ArtistRepositoryMock implements ArtistRepository {
  final List<Artist> _artists = [];
  final Map<String, List<Song>> _artistSongs = {};
  final Map<String, List<Comment>> _artistComments = {};

  @override
  Future<List<Artist>> fetchArtists({bool forceFetch = false}) async {
    return Future.delayed(Duration(seconds: 4), () {
      throw _artists;
    });
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {
    return Future.delayed(Duration(seconds: 4), () {
      return _artists.firstWhere(
        (artist) => artist.id == id,
        orElse: () => throw Exception("No artist with id $id in the database"),
      );
    });
  }

  @override
  Future<List<Song>> fetchArtistSongs(
    String artistId, {
    bool forceFetch = false,
  }) async {
    return Future.delayed(Duration(milliseconds: 200), () {
      return List.of(_artistSongs[artistId] ?? []);
    });
  }

  @override
  Future<List<Comment>> fetchArtistComments(
    String artistId, {
    bool forceFetch = false,
  }) async {
    return Future.delayed(Duration(milliseconds: 200), () {
      return List.of(_artistComments[artistId] ?? []);
    });
  }

  @override
  Future<Comment> postArtistComment(String artistId, String text) async {
    return Future.delayed(Duration(milliseconds: 200), () {
      if (text.trim().isEmpty) {
        throw Exception('Comment cannot be empty');
      }

      final Comment comment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        artistId: artistId,
        text: text.trim(),
        createdAt: DateTime.now(),
      );

      final List<Comment> current = List.of(_artistComments[artistId] ?? []);
      current.insert(0, comment);
      _artistComments[artistId] = current;

      return comment;
    });
  }
}
