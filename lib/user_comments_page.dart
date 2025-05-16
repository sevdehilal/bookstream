import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/service.dart';
import '../widgets/review_card.dart';

class UserCommentsPage extends StatefulWidget {
  final int userId;

  const UserCommentsPage({super.key, required this.userId});

  @override
  _UserCommentsPageState createState() => _UserCommentsPageState();
}

class _UserCommentsPageState extends State<UserCommentsPage> {
  bool _isLoading = true;
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadUserReviews();
  }

  Future<void> _loadUserReviews() async {
    try {
      final reviews = await ApiService.fetchReviewsByUserId(widget.userId);
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      print('Yorumlar yüklenirken hata oluştu: $e');
      setState(() {
        _reviews = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviews.isEmpty) {
      return const Center(child: Text('Bu kullanıcı henüz yorum yapmamış.'));
    }

    return ListView.builder(
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return ReviewCard(
          review: review,
          isInitiallyLiked: false,
          showDeleteButton: false,
        );
      },
    );
  }
}
