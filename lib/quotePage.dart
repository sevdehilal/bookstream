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
      backgroundColor: Color.fromARGB(255, 212, 223, 231),
      appBar: AppBar(
          title: Text("Alıntı Ekle"),
          backgroundColor: Color.fromARGB(255, 212, 223, 231)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_book != null)
              Row(
                children: [
                  _getImage(_book!.coverImage),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _book!.title,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Yazar: ${_book!.author.firstName} ${_book!.author.lastName}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Alıntı metni',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      final text = _textController.text.trim();
                      if (text.isEmpty) {
                        setState(() {
                          _errorMessage = 'Lütfen bir alıntı girin.';
                        });
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
                          SnackBar(content: Text('Alıntı başarıyla eklendi!')),
                        );
                        Navigator.pop(context, review);
                      } catch (e) {
                        setState(() {
                          _errorMessage = e.toString();
                        });
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    child: Text('Gönder'),
                  ),
            if (_errorMessage != null) ...[
              SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
