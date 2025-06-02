import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/service.dart';
import '../models/book.dart';
import '../models/review.dart';

class QuotePage extends StatefulWidget {
  @override
  _QuotePageState createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  Book? _book;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final bookId = arguments['bookId'];
    _fetchBook(bookId);
  }

  Future<void> _fetchBook(int bookId) async {
    try {
      final book = await ApiService.fetchBookById(bookId);
      setState(() {
        _book = book;
      });
    } catch (e) {
      print('Kitap verisi çekilemedi: $e');
    }
  }

  Widget _getImage(String imageStr) {
    ImageProvider? imageProvider;

    try {
      if (imageStr.isEmpty || imageStr.toLowerCase() == "yok") {
        throw FormatException("Geçersiz resim");
      }

      if (imageStr.startsWith("http") || imageStr.startsWith("https")) {
        imageProvider = NetworkImage(imageStr);
      } else {
        final base64Image =
            imageStr.contains(',') ? imageStr.split(',')[1] : imageStr;
        final decodedBytes = base64Decode(base64Image);
        imageProvider = MemoryImage(decodedBytes);
      }
    } catch (e) {
      print("Resim yüklenemedi: $e");
      imageProvider = AssetImage('assets/logo.png');
    }

    return Image(
        image: imageProvider!, width: 80, height: 120, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final userId = arguments['userId'];
    final bookId = arguments['bookId'];
    final typeId = arguments['type'];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 223, 231),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 212, 223, 231),
        title: const Text(
          "Alıntı Ekle",
          style: TextStyle(
            color: Colors.black87,
            backgroundColor: const Color.fromARGB(255, 212, 223, 231),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_book != null)
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                color: const Color.fromARGB(255, 227, 238, 246),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _getImage(_book!.coverImage),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _book!.title,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_book!.author.firstName} ${_book!.author.lastName}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Alıntınızı Yazın',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Alıntı metni buraya yazın...',
                filled: true,
                fillColor: const Color.fromARGB(255, 227, 238, 246),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blueGrey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final text = _textController.text.trim();
                        if (text.isEmpty) {
                          setState(
                              () => _errorMessage = 'Lütfen bir alıntı girin.');
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });

                        try {
                          final review = await ApiService.postReview(
                            userId: userId,
                            bookId: bookId,
                            typeId: typeId,
                            text: text,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Alıntı başarıyla eklendi!')),
                          );
                          Navigator.pop(context, review);
                        } catch (e) {
                          setState(() => _errorMessage = e.toString());
                        } finally {
                          setState(() => _isLoading = false);
                        }
                      },
                      icon: const Icon(Icons.send,
                          color: const Color.fromARGB(255, 227, 238, 246)),
                      label: const Text(
                        'Gönder',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 227, 238, 246),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
