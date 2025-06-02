import 'book.dart';
import 'register.dart';
import 'review_type.dart';

class Review {
  final int id;
  final int userId;
  final UserModel user;
  final int bookId;
  final Book book;
  final int typeId;
  final ReviewType type;
  final String text;
  final DateTime? createDate;
  final bool isFavorite; // ✅ Burayı ekledik
  final int likeCount;
  final int commentCount;

  Review({
    required this.id,
    required this.userId,
    required this.user,
    required this.bookId,
    required this.book,
    required this.typeId,
    required this.type,
    required this.text,
    required this.createDate,
    required this.isFavorite,
    required this.likeCount,
    required this.commentCount, // ✅ Constructor'a da ekledik
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      user: UserModel.fromJson(json['user'] ?? {}),
      bookId: json['bookId'] ?? 0,
      book: Book.fromJson(json['book'] ?? {}),
      typeId: json['typeId'] ?? 0,
      type: ReviewType.fromJson(json['type'] ?? {}),
      text: json['text'] ?? '',
      createDate: json['createDate'] != null
          ? DateTime.tryParse(json['createDate'])
          : null,
      isFavorite: json['isFavorite'] ?? false,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0, // ✅ JSON'dan da çektik
    );
  }
}
