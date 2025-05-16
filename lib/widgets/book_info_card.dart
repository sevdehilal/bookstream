import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:flutter/gestures.dart';

class BookInfoCard extends StatefulWidget {
  final Book book;

  const BookInfoCard({Key? key, required this.book}) : super(key: key);

  @override
  State<BookInfoCard> createState() => _BookInfoCardState();
}

class _BookInfoCardState extends State<BookInfoCard> {
  bool _showFullDescription = false;
  final int _maxLength = 200;

  ImageProvider _getImage(String imageStr) {
    try {
      if (imageStr.isEmpty || imageStr.toLowerCase() == "yok") {
        throw FormatException("Geçersiz resim");
      }

      if (imageStr.startsWith("http") || imageStr.startsWith("https")) {
        return NetworkImage(imageStr);
      } else {
        final base64Image =
            imageStr.contains(',') ? imageStr.split(',')[1] : imageStr;
        final decodedBytes = base64Decode(base64Image);
        return MemoryImage(decodedBytes);
      }
    } catch (e) {
      return const AssetImage('assets/logo.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final description = book.description;
    final isLong = description.length > _maxLength;
    final displayText = _showFullDescription || !isLong
        ? description
        : '${description.substring(0, _maxLength)}...';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resim + Bilgiler
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                    image: _getImage(book.coverImage),
                    width: 120,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                          'Yazar: ${book.author.firstName} ${book.author.lastName}'),
                      const SizedBox(height: 4),
                      Text('Yayınevi: ${book.publisher}'),
                      const SizedBox(height: 4),
                      Text('Yayın Yılı: ${book.publishedYear}'),
                      const SizedBox(height: 4),
                      Text('Tür: ${book.genre.name}'),
                      const SizedBox(height: 4),
                      Text('Sayfa Sayısı: ${book.pageCount}'),
                      const SizedBox(height: 4),
                      Text('ISBN: ${book.isbn}'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Açıklama
            const Text(
              'Açıklama:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            // Açıklama + Devamını Gör
            RichText(
              text: TextSpan(
                text: displayText,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                children: isLong && !_showFullDescription
                    ? [
                        TextSpan(
                          text: ' Devamını Gör',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              setState(() {
                                _showFullDescription = true;
                              });
                            },
                        ),
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
