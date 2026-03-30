import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../model/artist/artist.dart';
import '../../../../model/comments/comment.dart';
import '../../../../model/songs/song.dart';
import '../../../widgets/song/song_tile.dart';
import '../view_model/artist_detail_view_model.dart';
import 'comment_tile.dart';

class ArtistDetailContent extends StatelessWidget {
  const ArtistDetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    final ArtistDetailViewModel mv = context.watch<ArtistDetailViewModel>();
    final Artist artist = mv.artist;

    final List<Widget> children = [
      _ArtistHeader(artist: artist),
    ];

    if (mv.isLoading) {
      children.add(
        const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (mv.error != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Center(
            child: Text(
              'error = ${mv.error!}',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    children.addAll([
      const _SectionTitle(title: 'Songs'),
      ..._buildSongs(mv.songs),
      const _SectionTitle(title: 'Comments'),
      ..._buildComments(mv.comments),
      const SizedBox(height: 24),
    ]);

    return RefreshIndicator(
      onRefresh: mv.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: children,
      ),
    );
  }

  List<Widget> _buildSongs(List<Song> songs) {
    if (songs.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('No songs for this artist yet.'),
        ),
      ];
    }

    return songs.map((song) => SongTile(song: song)).toList();
  }

  List<Widget> _buildComments(List<Comment> comments) {
    if (comments.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('No comments yet. Be the first to post!'),
        ),
      ];
    }

    return comments.map((comment) => CommentTile(comment: comment)).toList();
  }
}

class _ArtistHeader extends StatelessWidget {
  final Artist artist;

  const _ArtistHeader({required this.artist});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: NetworkImage(artist.imageUrl.toString()),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                artist.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text('Genre: ${artist.genre}'),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
