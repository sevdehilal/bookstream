import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/service.dart';
import '../models/register.dart';
import 'user_profile_page.dart'; // 👈 mutlaka import et

class FollowingsPage extends StatefulWidget {
  final int userId;

  const FollowingsPage({super.key, required this.userId});

  @override
  State<FollowingsPage> createState() => _FollowingsPageState();
}

class _FollowingsPageState extends State<FollowingsPage> {
  List<UserModel> followings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowings();
  }

  Future<void> _loadFollowings() async {
    try {
      final fetchedFollowings = await ApiService.fetchFollowings(widget.userId);
      setState(() {
        followings = fetchedFollowings;
        _isLoading = false;
      });
    } catch (e) {
      print('Takip edilenler yüklenemedi: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  ImageProvider _getProfileImage(String? photo) {
    try {
      if (photo == null || photo.isEmpty) {
        throw Exception();
      }

      if (photo.startsWith('http') || photo.startsWith('https')) {
        return NetworkImage(photo);
      } else if (photo.startsWith('data:image')) {
        final base64Str = photo.split(',').last.trim();
        final decodedBytes = base64Decode(base64Str);
        return MemoryImage(decodedBytes);
      } else {
        throw Exception();
      }
    } catch (e) {
      return const AssetImage('lib/assets/logo.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 223, 231),
      appBar: AppBar(
        title: const Text('Takip Edilenler'),
        backgroundColor: const Color.fromARGB(255, 212, 223, 231),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : followings.isEmpty
              ? const Center(child: Text('Henüz kimseyi takip etmiyor.'))
              : ListView.builder(
                  itemCount: followings.length,
                  itemBuilder: (context, index) {
                    final user = followings[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                _getProfileImage(user.profilePhoto),
                          ),
                          title: Text("${user.name} ${user.surname}"),
                          subtitle: Text("@${user.username}"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    UserProfilePage(userId: user.id),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          thickness: 1,
                          height: 2,
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
