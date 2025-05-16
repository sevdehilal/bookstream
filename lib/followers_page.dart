import 'package:flutter/material.dart';
import '../services/service.dart';
import '../models/register.dart';
import 'dart:convert';
import 'user_profile_page.dart';

class FollowersPage extends StatefulWidget {
  final int userId;

  const FollowersPage({super.key, required this.userId});

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  List<UserModel> followers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowers();
  }

  Future<void> _loadFollowers() async {
    try {
      final fetchedFollowers = await ApiService.fetchFollowers(widget.userId);
      setState(() {
        followers = fetchedFollowers;
        _isLoading = false;
      });
    } catch (e) {
      print('Takipçiler yüklenemedi: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  ImageProvider _getProfileImage(String? photo) {
    try {
      if (photo == null || photo.isEmpty) {
        throw Exception('Fotoğraf verisi boş');
      }

      if (photo.startsWith('http') || photo.startsWith('https')) {
        return NetworkImage(photo);
      } else if (photo.startsWith('data:image')) {
        final base64Str = photo.split(',').last.trim();
        if (base64Str.isEmpty) {
          throw Exception('Base64 veri boş');
        }
        final decodedBytes = base64Decode(base64Str);
        return MemoryImage(decodedBytes);
      } else {
        throw Exception('Geçersiz format');
      }
    } catch (e) {
      print('Fotoğraf çözümleme hatası: $e');
      return const AssetImage('lib/assets/logo.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Takipçiler'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : followers.isEmpty
              ? const Center(child: Text('Henüz takipçi yok.'))
              : ListView.builder(
                  itemCount: followers.length,
                  itemBuilder: (context, index) {
                    final user = followers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: _getProfileImage(user.profilePhoto),
                      ),
                      title: Text("${user.name} ${user.surname}"),
                      subtitle: Text("@${user.username}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfilePage(userId: user.id),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
