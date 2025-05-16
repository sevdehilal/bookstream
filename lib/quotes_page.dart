import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';
import '../services/service.dart';
import '../widgets/review_card.dart';

class QuotesPage extends StatefulWidget {
  @override
  _QuotesPageState createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  bool _isLoading = true;
  List<Review> _quotes = [];
  Map<int, bool> _likedMap = {};

  @override
  void initState() {
    super.initState();
    _loadUserQuotes();
  }

  Future<void> _loadUserQuotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    if (userId != null) {
      try {
        final quotes = await ApiService.fetchAlintiByUserId(userId);
        final likedStatuses = <int, bool>{};

        // Her alıntı için beğeni durumu kontrolü
        for (final quote in quotes) {
          final isLiked = await ApiService.isPostLiked(quote.id);
          likedStatuses[quote.id] = isLiked;
        }

        setState(() {
          _quotes = quotes;
          _likedMap = likedStatuses;
          _isLoading = false;
        });
      } catch (e) {
        print('Alıntılar yüklenirken hata oluştu: $e');
        setState(() {
          _quotes = [];
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _quotes = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteQuote(int postId, int index) async {
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
          _quotes.removeAt(index);
          _likedMap.remove(postId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alıntı başarıyla silindi')),
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

    if (_quotes.isEmpty) {
      return const Center(child: Text('Henüz alıntı yapılmamış.'));
    }

    return ListView.builder(
      itemCount: _quotes.length,
      itemBuilder: (context, index) {
        final quote = _quotes[index];
        final isLiked = _likedMap[quote.id] ?? false;

        return ReviewCard(
          onLikeChanged: (_) => _loadUserQuotes(),
          review: quote,
          isInitiallyLiked: isLiked,
          showDeleteButton: true,
          onDelete: () => _deleteQuote(quote.id, index),
        );
      },
    );
  }
}
