class Comment {
  final int id;
  final int postId;
  final int userId;
  final String text;
  final String createdAt;
  final String username;
  final String? profilePhoto;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.username,
    required this.profilePhoto,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      text: json['text'],
      createdAt: json['createdAt'],
      username: json['user']?['username'] ?? '',
      profilePhoto: json['user']?['profilePhoto'],
    );
  }
}
