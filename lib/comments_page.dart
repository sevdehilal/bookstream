import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';
import '../services/service.dart';
import '../widgets/review_card.dart';

class CommentsPage extends StatefulWidget {
  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  List<Review> _reviews = [];
  Map<int, bool> _likedMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserReviews();
  }

  Future<void> _loadUserReviews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    if (userId != null) {
      try {
        final reviews = await ApiService.fetchReviewsByUserId(userId);
        final likedStatuses = <int, bool>{};

        for (final review in reviews) {
          final isLiked = await ApiService.isPostLiked(review.id);
          likedStatuses[review.id] = isLiked;
        }

        setState(() {
          _reviews = reviews;
          _likedMap = likedStatuses;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _reviews = [];
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _reviews = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteReview(int postId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteAlinti(postId);
      if (success) {
        setState(() {
          _reviews.removeAt(index);
          _likedMap.remove(postId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorum başarıyla silindi')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silme işlemi başarısız oldu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviews.isEmpty) {
      return const Center(child: Text('Henüz yorum yapılmamış.'));
    }

    return ListView.builder(
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        final isLiked = _likedMap[review.id] ?? false;

        return ReviewCard(
          review: review,
          isInitiallyLiked: isLiked,
          showDeleteButton: true,
          onDelete: () => _deleteReview(review.id, index),
          onLikeChanged: (_) => _loadUserReviews(),
        );
      },
    );
  }
}
