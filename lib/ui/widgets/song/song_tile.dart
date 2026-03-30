import 'package:flutter/material.dart';
import '../../../model/songs/song.dart';

class SongTile extends StatelessWidget {
  final Song song;

  const SongTile({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          title: Text(song.title),
          subtitle: Text('${song.duration.inMinutes} mins'),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(song.imageUrl.toString()),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
              const SizedBox(width: 4),
              Text('${song.likes}'),
            ],
          ),
        ),
      ),
    );
  }
}
