import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/service.dart';

class CreateCampaignPage extends StatefulWidget {
  @override
  _CreateCampaignPageState createState() => _CreateCampaignPageState();
}

class _CreateCampaignPageState extends State<CreateCampaignPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {
    'institutionName': '',
    'institutionCity': '',
    'institutionAddress': '',
    'detail': '',
    'targetBookCount': 0,
    'contactName': '',
    'contactEmail': '',
    'contactPhone': '',
  };

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final mimeType =
            pickedFile.path.endsWith('.png') ? 'image/png' : 'image/jpeg';
        final base64Image = base64Encode(bytes);
        final fullBase64 = "data:$mimeType;base64,$base64Image";

        print("Base64 Görsel Verisi:");
        print(fullBase64);

        setState(() {
          _selectedImage = File(pickedFile.path);
          formData['image'] = fullBase64;
        });
      }
    } catch (e) {
      print("Görsel seçme hatası: $e");
    }
  }

  Future<void> submitCampaign() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lütfen bir görsel seçin')),
        );
        return;
      }

      try {
        final result = await ApiService.createDonationCampaign(formData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kampanya başarıyla oluşturuldu')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
        print('$e');
      }
    }
  }

  Widget buildTextField(String label, String field, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) =>
            value == null || value.isEmpty ? 'Zorunlu alan' : null,
        onSaved: (value) {
          formData[field] =
              isNumber ? int.tryParse(value ?? '0') ?? 0 : value ?? '';
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 212, 223, 231),
      appBar: AppBar(
        title: Text('Kampanya Oluştur'),
        backgroundColor: Color.fromARGB(255, 212, 223, 231),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField('Kurum Adı', 'institutionName'),
              buildTextField('Şehir', 'institutionCity'),
              buildTextField('Adres', 'institutionAddress'),
              buildTextField('Açıklama', 'detail'),
              buildTextField('Hedef Kitap Sayısı', 'targetBookCount',
                  isNumber: true),
              buildTextField('İletişim Adı', 'contactName'),
              buildTextField('İletişim E-Posta', 'contactEmail'),
              buildTextField('İletişim Telefon', 'contactPhone'),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.photo),
                label: Text('Görsel Seç'),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Image.file(_selectedImage!, height: 200),
                ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: submitCampaign,
                child: Text('Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
