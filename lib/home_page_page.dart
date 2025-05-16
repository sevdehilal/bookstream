import 'package:flutter/material.dart';
import '../services/service.dart';
import '../models/review.dart';
import '../widgets/review_card.dart';

class HomePagePage extends StatefulWidget {
  const HomePagePage({super.key});

  @override
  State<HomePagePage> createState() => _HomePagePageState();
}

class _HomePagePageState extends State<HomePagePage> {
  List<Review> reviews = [];
  Map<int, bool> likedPosts = {};
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _pageSize = 5;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchReviews();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !_isLoading &&
          _hasMore) {
        _fetchReviews();
      }
    });
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newReviews =
          await ApiService.fetchPagedPosts(page: _page, pageSize: _pageSize);

      for (var review in newReviews) {
        final isLiked = await ApiService.isPostLiked(review.id);
        likedPosts[review.id] = isLiked;
      }

      setState(() {
        _page++;
        reviews.addAll(newReviews);
        if (newReviews.length < _pageSize) {
          _hasMore = false;
        }
      });
    } catch (e) {
      print('Yorumlar alınırken hata oluştu: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 223, 231),
      body: _isLoading && reviews.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: reviews.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < reviews.length) {
                  final review = reviews[index];
                  return ReviewCard(
                    review: review,
                    isInitiallyLiked: likedPosts[review.id] ?? false,
                    onLikeChanged: (liked) {
                      setState(() {
                        likedPosts[review.id] = liked;
                      });
                    },
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
    );
  }
}
