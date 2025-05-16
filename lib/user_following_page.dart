import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/service.dart';
import '../models/register.dart';
import 'user_profile_page.dart';

class UserFollowingPage extends StatefulWidget {
  final int userId;

  const UserFollowingPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserFollowingPage> createState() => _UserFollowingPageState();
}

class _UserFollowingPageState extends State<UserFollowingPage> {
  List<UserModel> _followings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowings();
  }

  Future<void> _loadFollowings() async {
    try {
      final followings = await ApiService.fetchFollowings(widget.userId);
      setState(() {
        _followings = followings;
        _isLoading = false;
      });
    } catch (e) {
      print('Takip edilenler yüklenemedi: $e');
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
        title: const Text('Takip Edilenler'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _followings.isEmpty
              ? const Center(child: Text('Takip edilen bulunamadı.'))
              : ListView.builder(
                  itemCount: _followings.length,
                  itemBuilder: (context, index) {
                    final following = _followings[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            _getProfileImage(following.profilePhoto),
                        child: following.profilePhoto == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text("${following.name} ${following.surname}"),
                      subtitle: Text("@${following.username}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UserProfilePage(userId: following.id),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
