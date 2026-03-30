import '../../model/comments/comment.dart';

class CommentDto {
  static const String textKey = 'text';
  static const String createdAtKey = 'createdAt';

  static Comment fromJson(
    String id,
    String artistId,
    Map<String, dynamic> json,
  ) {
    return Comment(
      id: id,
      artistId: artistId,
      text: json[textKey] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json[createdAtKey] ?? 0) as int,
      ),
    );
  }

  static Map<String, dynamic> toJson(Comment comment) {
    return {
      textKey: comment.text,
      createdAtKey: comment.createdAt.millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> toJsonForCreate(String text) {
    return {
      textKey: text,
      createdAtKey: DateTime.now().millisecondsSinceEpoch,
    };
  }
}
