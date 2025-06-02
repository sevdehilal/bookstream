import 'package:flutter/material.dart';
import '../services/service.dart';
import '../models/review.dart';
import '../models/book.dart';
import '../widgets/review_card.dart';
import '../widgets/book_card.dart';

class HomePagePage extends StatefulWidget {
  const HomePagePage({super.key});

  @override
  State<HomePagePage> createState() => _HomePagePageState();
}

class _HomePagePageState extends State<HomePagePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  List<Review> reviews = [];
  Map<int, bool> likedPosts = {};
  bool _isLoadingReviews = false;
  bool _hasMoreReviews = true;
  int _reviewPage = 1;
  final int _pageSize = 5;

  List<Book> recommendedBooks = [];
  bool _isLoadingBooks = false;

  void _refreshAllReviews() {
    setState(() {
      _reviewPage = 1;
      _hasMoreReviews = true;
      reviews.clear();
    });
    _fetchReviews();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchReviews();
    _fetchRecommendedBooks();

    _scrollController.addListener(() {
      if (_tabController.index == 0 &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !_isLoadingReviews &&
          _hasMoreReviews) {
        _fetchReviews();
      }
    });
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final newReviews = await ApiService.fetchPagedPosts(
          page: _reviewPage, pageSize: _pageSize);
      for (var review in newReviews) {
        final isLiked = await ApiService.isPostLiked(review.id);
        likedPosts[review.id] = isLiked;
      }
      setState(() {
        _reviewPage++;
        reviews.addAll(newReviews);
        if (newReviews.length < _pageSize) _hasMoreReviews = false;
      });
    } catch (e) {
      print('Yorumlar alınırken hata: $e');
    } finally {
      setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _refreshCurrentReviewsPage() async {
    setState(() => _isLoadingReviews = true);
    try {
      final refreshedReviews = await ApiService.fetchPagedPosts(
          page: _reviewPage - 1, pageSize: _pageSize);
      for (var review in refreshedReviews) {
        final isLiked = await ApiService.isPostLiked(review.id);
        likedPosts[review.id] = isLiked;
      }
      setState(() {
        final start = (_reviewPage - 2) * _pageSize;
        if (start >= 0 && start < reviews.length) {
          reviews.replaceRange(
              start, start + refreshedReviews.length, refreshedReviews);
        }
      });
    } catch (e) {
      print('Sayfa yenileme hatası: $e');
    } finally {
      setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _fetchRecommendedBooks() async {
    setState(() => _isLoadingBooks = true);
    try {
      final books = await ApiService.fetchRecommendedBooks(
          userId: 4, page: 1, pageSize: 5);
      setState(() => recommendedBooks = books);
    } catch (e) {
      print('Tavsiye edilen kitaplar alınırken hata: $e');
    } finally {
      setState(() => _isLoadingBooks = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 211, 226, 237),
        body: Column(
          children: [
            Container(
              color: const Color.fromARGB(255, 211, 226, 237),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Genel Bakış'),
                  Tab(text: 'Önerilen Kitaplar'),
                ],
                indicatorColor: Colors.deepPurple,
                labelColor: Colors.black,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildReviewTab(),
                  _buildBookTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewTab() {
    return _isLoadingReviews && reviews.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            controller: _scrollController,
            itemCount: reviews.length + (_hasMoreReviews ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < reviews.length) {
                final review = reviews[index];
                return ReviewCard(
                  review: review,
                  isInitiallyLiked: likedPosts[review.id] ?? false,
                  onLikeChanged: (liked) {
                    setState(() => likedPosts[review.id] = liked);
                    _refreshCurrentReviewsPage(); // ✅ Sayfayı yeniden çek
                  },
                  onCommentAdded: _refreshAllReviews,
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          );
  }

  Widget _buildBookTab() {
    if (_isLoadingBooks && recommendedBooks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isLoadingBooks && recommendedBooks.isEmpty) {
      return const Center(
        child: Text(
          "Önerilen kitap bulunamadı.",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: recommendedBooks.length,
      itemBuilder: (context, index) {
        final book = recommendedBooks[index];
        return BookCard(book: book);
      },
    );
  }
}
