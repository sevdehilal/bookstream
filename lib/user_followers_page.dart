import 'package:flutter/material.dart';
import '../services/service.dart';
import '../models/register.dart'; // 👈 Çünkü UserModel burada (register.dart içinde UserModel var)
import 'user_profile_page.dart';
import 'dart:convert'; // 👈 base64Decode için şart

class UserFollowersPage extends StatefulWidget {
  final int userId;

  const UserFollowersPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserFollowersPage> createState() => _UserFollowersPageState();
}

class _UserFollowersPageState extends State<UserFollowersPage> {
  List<UserModel> _followers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowers();
  }

  Future<void> _loadFollowers() async {
    try {
      final followers = await ApiService.fetchFollowers(widget.userId);
      setState(() {
        _followers = followers;
        _isLoading = false;
      });
    } catch (e) {
      print('Takipçiler yüklenemedi: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  ImageProvider? _getProfileImage(String? photo) {
    if (photo == null) return null;
    try {
      if (photo.startsWith('data:image')) {
        final base64String = photo.split(',').last;
        return MemoryImage(base64Decode(base64String));
      } else {
        return NetworkImage(photo);
      }
    } catch (e) {
      print("Profil fotoğrafı çözümlenemedi: $e");
      return null;
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
          : _followers.isEmpty
              ? const Center(child: Text('Takipçi bulunamadı.'))
              : ListView.builder(
                  itemCount: _followers.length,
                  itemBuilder: (context, index) {
                    final follower = _followers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            _getProfileImage(follower.profilePhoto),
                        child: follower.profilePhoto == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text("${follower.name} ${follower.surname}"),
                      subtitle: Text("@${follower.username}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UserProfilePage(userId: follower.id),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
