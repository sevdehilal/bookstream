import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/service.dart';

class LikedPostsPage extends StatefulWidget {
  final int userId;
  const LikedPostsPage({super.key, required this.userId});

  @override
  State<LikedPostsPage> createState() => _LikedPostsPageState();
}

class _LikedPostsPageState extends State<LikedPostsPage> {
  List<Review> likedReviews = [];
  int _page = 1;
  final int _pageSize = 5;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchLikedPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !_isLoading &&
          _hasMore) {
        _fetchLikedPosts();
      }
    });
  }

  Future<void> _fetchLikedPosts() async {
    setState(() => _isLoading = true);
    try {
      final newPosts = await ApiService.fetchLikedPosts(
        userId: widget.userId,
        page: _page,
        pageSize: _pageSize,
      );
      setState(() {
        likedReviews.addAll(newPosts);
        _page++;
        if (newPosts.length < _pageSize) _hasMore = false;
      });
    } catch (e) {
      print('Beğenilen gönderiler alınamadı: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unlikeAndRefresh(int reviewId) async {
    try {
      await ApiService.unlikePost(reviewId);
      setState(() {
        likedReviews.removeWhere((r) => r.id == reviewId);
        if (likedReviews.length < _pageSize) {
          _hasMore = true;
          _page = 1;
          likedReviews.clear();
          _fetchLikedPosts();
        }
      });
    } catch (e) {
      print('Beğeni kaldırma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Beğeni kaldırılamadı")),
      );
    }
  }

  ImageProvider _getImage(String? imageStr) {
    try {
      if (imageStr == null || imageStr.isEmpty) throw Exception();
      if (imageStr.startsWith('http')) return NetworkImage(imageStr);
      if (imageStr.startsWith('data:image')) {
        final bytes = base64Decode(imageStr.split(',').last);
        return MemoryImage(bytes);
      }
    } catch (_) {}
    return const AssetImage('lib/assets/logo.png');
  }

  Widget _buildPost(Review review) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kullanıcı Bilgisi + Tip + Kalp
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: _getImage(review.user.profilePhoto),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "@${review.user.username}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        review.type == "quote"
                            ? "alıntı"
                            : review.type == "summary"
                                ? "özet"
                                : "gönderi",
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.redAccent),
                  onPressed: () async {
                    await _unlikeAndRefresh(review.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              review.text,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 239, 245, 249),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.book.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${review.book.author.firstName} ${review.book.author.lastName}",
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading && likedReviews.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            controller: _scrollController,
            itemCount: likedReviews.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < likedReviews.length) {
                return _buildPost(likedReviews[index]);
              } else {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          );
  }
}
