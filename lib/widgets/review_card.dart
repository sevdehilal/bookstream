import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';
import '../services/service.dart';
import '../comment_list_sheet.dart';
import '../user_profile_page.dart';
import '../home_page_page.dart';

class ReviewCard extends StatefulWidget {
  final Review review;
  final bool isInitiallyLiked;
  final void Function(bool)? onLikeChanged;
  final bool showDeleteButton;
  final VoidCallback? onDelete;
  final VoidCallback? onCommentAdded;

  const ReviewCard({
    super.key,
    required this.review,
    required this.isInitiallyLiked,
    this.onLikeChanged,
    this.showDeleteButton = false,
    this.onDelete,
    this.onCommentAdded,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isInitiallyLiked;
  }

  ImageProvider _getImage(String? imageStr) {
    try {
      if (imageStr == null || imageStr.isEmpty) throw Exception();
      if (imageStr.startsWith('http') || imageStr.startsWith('https')) {
        return NetworkImage(imageStr);
      } else if (imageStr.startsWith('data:image')) {
        final base64Str = imageStr.split(',').last;
        final decodedBytes = base64Decode(base64Str);
        return MemoryImage(decodedBytes);
      } else {
        throw Exception();
      }
    } catch (_) {
      return const AssetImage('lib/assets/logo.png');
    }
  }

  void _openCommentsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CommentListSheet(
        postId: widget.review.id,
        onCommentAdded: widget.onCommentAdded, // ✅ burası önemli
      ),
    );
  }

  void _toggleLike() async {
    try {
      if (isLiked) {
        await ApiService.unlikePost(widget.review.id);
      } else {
        await ApiService.likePost(widget.review.id);
      }

      final updated = await ApiService.isPostLiked(widget.review.id);
      setState(() => isLiked = updated);
      widget.onLikeChanged?.call(updated); // <<< bunu tetikle
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Beğeni işlemi başarısız')),
      );
    }
  }

  void _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Alıntıyı silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    return Card(
      color: const Color.fromARGB(255, 227, 238, 246),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePage(userId: review.user.id),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: _getImage(review.user.profilePhoto),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePage(userId: review.user.id),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "@${review.user.username}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          review.type.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(review.text, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),

            /// Kitap bilgisi
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 236, 243, 247),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image(
                      image: _getImage(review.book.coverImage),
                      width: 40,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.book.title,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${review.book.author.firstName} ${review.book.author.lastName}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 2),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                            size: 22,
                          ),
                          onPressed: _toggleLike,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 22,
                            minHeight: 22,
                          ),
                          visualDensity: VisualDensity.compact,
                          splashRadius: 18,
                        ),
                      ],
                    ),
                    const SizedBox(width: 1), // En fazla 1 ver, yoksa yapışır
                    Text(
                      '${review.likeCount}',
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.comment, color: Colors.grey, size: 22),
                  onPressed: _openCommentsBottomSheet,
                  tooltip: 'Yorum Yap',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 30,
                    minHeight: 30,
                  ),
                  visualDensity: VisualDensity.compact,
                  splashRadius: 18,
                ),
                Text(
                  '${review.commentCount}',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
