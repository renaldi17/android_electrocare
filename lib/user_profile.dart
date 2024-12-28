import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final formKey = GlobalKey<FormState>();
  String _id = "";
  String _nama = '';
  String _email = '';
  String _nomor = '';
  String _pass = '';
  String _displayName = '';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final response = await http.get(Uri.parse('http://localhost/apielectrocare/get_user.php?id=$_userId'));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData != null && responseData['status'] == 'success') {
        setState(() {
          _id = responseData['user']['id'];
          _nama = responseData['user']['nama'];
          _email = responseData['user']['email'];
          _nomor = responseData['user']['nomor'];
          _displayName = responseData['user']['username'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Red curved container with profile image
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF1E1E),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),

                  // Profile information
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      children: [
                        _buildProfileField('ID', _id, (value) => _id = value, enabled: false),
                        const Divider(),
                        _buildProfileField('Username', _displayName, (value) => _displayName = value),
                        const Divider(),
                        _buildProfileField('Nama', _nama, (value) => _nama = value),
                        const Divider(),
                        _buildProfileField('Email', _email, (value) => _email = value),
                        const Divider(),
                        _buildProfileField('Password', _pass, (value) => _pass = value, obscureText: true),
                        const Divider(),
                        _buildProfileField('No. Handphone', _nomor, (value) => _nomor = value),
                        const Divider(),
                        _buildProfileFieldWithoutEdit('Versi Aplikasi', 'Electrocare 1.0'),
                      ],
                    ),
                  ),
                ],
              ),

              // Profile image and name - positioned on top of the curve
              Positioned(
                top: 130,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(Icons.person, size: 50, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _nama,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            updateData(_id, _displayName, _email, _pass, _nomor);
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  void updateData(String id, String name, String email, String password, String nomor) async {
    String uri = "http://localhost/apielectrocare/update_user.php";
    try {
      final response = await http.post(Uri.parse(uri), body: {
        "id": id,
        "nama": name,
        "email": email,
        "nomor": nomor,
        "password": password
      });

      if (response.statusCode == 200) {
        print('Data updated successfully');
        // Optionally show a success message or navigate back
      } else {
        print('Failed to update data');
      }
    } catch (e) {
      print(e);
    }
  }

  Widget _buildProfileField(String label, String value, Function(String) onChanged, {bool enabled = true, bool obscureText = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          TextFormField(
            onChanged: enabled ? onChanged : null,
            initialValue: value,
            enabled: enabled,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileFieldWithoutEdit(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
