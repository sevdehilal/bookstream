import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/service.dart';
import '../widgets/review_card.dart';

class UserQuotesPage extends StatefulWidget {
  final int userId;

  const UserQuotesPage({super.key, required this.userId});

  @override
  _UserQuotesPageState createState() => _UserQuotesPageState();
}

class _UserQuotesPageState extends State<UserQuotesPage> {
  bool _isLoading = true;
  List<Review> _quotes = [];

  @override
  void initState() {
    super.initState();
    _loadUserQuotes();
  }

  Future<void> _loadUserQuotes() async {
    try {
      final quotes = await ApiService.fetchAlintiByUserId(widget.userId);
      setState(() {
        _quotes = quotes;
        _isLoading = false;
      });
    } catch (e) {
      print('Alıntılar yüklenirken hata oluştu: $e');
      setState(() {
        _quotes = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_quotes.isEmpty) {
      return const Center(child: Text('Bu kullanıcı henüz alıntı yapmamış.'));
    }

    return ListView.builder(
      itemCount: _quotes.length,
      itemBuilder: (context, index) {
        final quote = _quotes[index];

        return ReviewCard(
          review: quote,
          isInitiallyLiked: false,
          showDeleteButton: false,
        );
      },
    );
  }
}
