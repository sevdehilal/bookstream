import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/service.dart';

class LibraryBookCard extends StatefulWidget {
  final dynamic book;
  final int userId;
  final int status;
  final VoidCallback onUpdate;
  final Set<int> favoriteBookIds;
  final VoidCallback onFavoriteUpdated;

  const LibraryBookCard({
    Key? key,
    required this.book,
    required this.userId,
    required this.status,
    required this.onUpdate,
    required this.favoriteBookIds,
    required this.onFavoriteUpdated,
  }) : super(key: key);

  @override
  State<LibraryBookCard> createState() => _LibraryBookCardState();
}

class _LibraryBookCardState extends State<LibraryBookCard> {
  ImageProvider _getImage(String imageStr) {
    try {
      if (imageStr.startsWith('http') || imageStr.startsWith('https')) {
        return NetworkImage(imageStr);
      } else if (imageStr.startsWith('data:image')) {
        final base64Str = imageStr.split(',').last;
        final bytes = base64Decode(base64Str);
        return MemoryImage(bytes);
      } else {
        throw Exception('Geçersiz resim');
      }
    } catch (e) {
      return const AssetImage('assets/logo.png');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final success = await ApiService.toggleFavorite(
        widget.userId,
        widget.book['id'],
      );

      if (success) {
        widget.onFavoriteUpdated();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.favoriteBookIds.contains(widget.book['id'])
                  ? 'Kitap favorilerden çıkarıldı.'
                  : 'Kitap favorilere eklendi.',
            ),
          ),
        );
      } else {
        throw Exception('Favori durumu güncellenemedi.');
      }
    } catch (e) {
      print('Favori güncelleme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşlem başarısız oldu.')),
      );
    }
  }

  Future<void> _removeFromLibrary() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Emin misin?"),
        content: const Text("Bu kitap kütüphanenden silinecek."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("İptal")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Sil")),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.removeBookFromLibrary(
          widget.userId, widget.book['id']);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kitap kütüphaneden silindi.")),
        );
        widget.onUpdate();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Silme işlemi başarısız.")),
        );
      }
    }
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Durumu Güncelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusButton('Okuyacağım', 'toRead'),
            _buildStatusButton('Okuyorum', 'reading'),
            _buildStatusButton('Okudum', 'read'),
            _buildStatusButton('Yarıda Bıraktım', 'abandoned'),
            const SizedBox(height: 12),

            /// ✅ Kitaplıktan Kaldır butonu popup içinde
            TextButton.icon(
              onPressed: () async {
                Navigator.pop(ctx); // popup'u kapat
                await _removeFromLibrary(); // kitap silme fonksiyonu
              },
              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
              label: const Text(
                'Kitaplığımdan Kaldır',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.redAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, String statusType) {
    return ElevatedButton(
      onPressed: () async {
        bool success = false;

        if (statusType == 'read' || statusType == 'abandoned') {
          final selectedRating = await _showRatingDialog(context);
          if (selectedRating != null) {
            success = await ApiService.updateLibraryStatus(
              userId: widget.userId,
              bookId: widget.book['id'],
              statusType: statusType,
              rating: selectedRating,
            );
          }
        } else {
          success = await ApiService.updateLibraryStatus(
            userId: widget.userId,
            bookId: widget.book['id'],
            statusType: statusType,
          );
        }

        if (!context.mounted) return;
        Navigator.pop(context);

        if (success) {
          widget.onUpdate();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Durum güncellendi!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Güncelleme başarısız.')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 36),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  Future<int?> _showRatingDialog(BuildContext context) async {
    int selectedRating = 5;

    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kitabı Kaç Puanla Değerlendiriyorsun?'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: selectedRating.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$selectedRating',
                    onChanged: (value) {
                      setState(() {
                        selectedRating = value.toInt();
                      });
                    },
                  ),
                  Text('$selectedRating Puan',
                      style: const TextStyle(fontSize: 18)),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, selectedRating),
              child: const Text('Onayla'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final author = widget.book['author'];
    final bool isFavorite = widget.favoriteBookIds.contains(widget.book['id']);

    return Container(
      width: 120,
      height: 240,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(5)),
                  image: DecorationImage(
                    image: _getImage(widget.book['coverImage'] ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  widget.book['title'] ?? 'Başlık Yok',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  author != null
                      ? '${author['firstName']} ${author['lastName']}'
                      : 'Bilinmeyen Yazar',
                  style: TextStyle(color: Colors.grey[700], fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => _showUpdateDialog(context),
                child: const Text(
                  'Durumu Güncelle',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.deepPurple,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: -8,
            right: -8,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.redAccent,
                size: 22,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
        ],
      ),
    );
  }
}
