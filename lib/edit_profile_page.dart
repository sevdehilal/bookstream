import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/register.dart';
import '../services/service.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _bioController;

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _base64Image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _surnameController = TextEditingController(text: widget.user.surname);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final mimeType =
            pickedFile.path.endsWith('.png') ? 'image/png' : 'image/jpeg';
        final base64Image = base64Encode(bytes);
        final fullBase64 = "data:$mimeType;base64,$base64Image";

        setState(() {
          _selectedImage = File(pickedFile.path);
          _base64Image = fullBase64;
        });
      }
    } catch (e) {
      print("Görsel seçme hatası: $e");
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    final updatedData = {
      "name": _nameController.text.trim(),
      "surname": _surnameController.text.trim(),
      "bio": _bioController.text.trim(),
      "profilePhoto":
          _base64Image ?? widget.user.profilePhoto, // ✅ BURAYI DÜZELTTİK
    };

    final result = await ApiService.updateUserProfile(updatedData);

    setState(() => _isLoading = false);

    if (result["success"] == true) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Bir hata oluştu.")),
      );
    }
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          labelText: label,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider profileImage;

    if (_selectedImage != null) {
      profileImage = FileImage(_selectedImage!);
    } else if (widget.user.profilePhoto != null) {
      if (widget.user.profilePhoto!.startsWith('data:image')) {
        profileImage = MemoryImage(
            base64Decode(widget.user.profilePhoto!.split(',').last));
      } else {
        profileImage = NetworkImage(widget.user.profilePhoto!) as ImageProvider;
      }
    } else {
      profileImage = const AssetImage('lib/assets/logo.png');
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 223, 231),
      appBar: AppBar(
        title: const Text("Profili Düzenle"),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: profileImage,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_outlined),
              label: const Text("Profil Fotoğrafı Değiştir"),
            ),
            const SizedBox(height: 24),
            _buildInputCard(
              controller: _nameController,
              label: 'İsim',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            _buildInputCard(
              controller: _surnameController,
              label: 'Soyisim',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _buildInputCard(
              controller: _bioController,
              label: 'Biyografi',
              icon: Icons.edit_note,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _updateProfile,
                icon: const Icon(Icons.save),
                label: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text("Profili Güncelle"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.teal[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
