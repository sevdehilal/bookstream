import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comment.dart';
import '../services/service.dart';

class CommentListSheet extends StatefulWidget {
  final int postId;

  const CommentListSheet({super.key, required this.postId});

  @override
  State<CommentListSheet> createState() => _CommentListSheetState();
}

class _CommentListSheetState extends State<CommentListSheet> {
  final TextEditingController _controller = TextEditingController();
  List<Comment> _comments = [];
  bool _loading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserAndComments();
  }

  Future<void> _loadUserAndComments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('userId');
    });
    await _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await ApiService.fetchCommentsForPost(widget.postId);
      setState(() {
        _comments = comments;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final success = await ApiService.addComment(
      postId: widget.postId,
      text: text,
    );

    if (success) {
      _controller.clear();
      await _loadComments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum gönderildi')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum gönderilemedi')),
      );
    }
  }

  Future<void> _deleteComment(int commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Yorumu silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Vazgeç")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteComment(commentId);
      if (success) {
        await _loadComments();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Yorum silindi")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Silme başarısız")),
        );
      }
    }
  }

  ImageProvider _getImage(String? imageStr) {
    try {
      if (imageStr == null || imageStr.isEmpty) throw Exception();
      if (imageStr.startsWith('http') || imageStr.startsWith('https')) {
        return NetworkImage(imageStr);
      } else if (imageStr.startsWith('data:image')) {
        final base64Str = imageStr.split(',').last;
        final decodedBytes = base64Decode(base64Str);
        return MemoryImage(decodedBytes);
      } else {
        throw Exception();
      }
    } catch (_) {
      return const AssetImage('lib/assets/logo.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          color: const Color.fromARGB(255, 212, 223, 231),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  "Yorumlar",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(thickness: 1),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                        ? const Center(child: Text("Henüz yorum yok."))
                        : ListView.separated(
                            itemCount: _comments.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final c = _comments[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: _getImage(c.profilePhoto),
                                ),
                                title: Text(
                                  "@${c.username}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(c.text),
                                trailing: (_currentUserId != null &&
                                        c.userId != null &&
                                        _currentUserId == c.userId)
                                    ? PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'delete') {
                                            _deleteComment(c.id);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Sil'),
                                          ),
                                        ],
                                        icon: const Icon(Icons.more_vert),
                                      )
                                    : null,
                              );
                            },
                          ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Yorum yaz...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submitComment,
                      child: const Text('Gönder'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
