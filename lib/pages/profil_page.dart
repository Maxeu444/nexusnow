import 'package:flutter/material.dart';
import 'package:nexus_now/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilPage extends StatefulWidget {
  ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        _pseudoController.text = data?['pseudo_user'] ?? '';
        _tagController.text = data?['tag_user'] ?? '';
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'email_user': user.email,
          'pseudo_user': _pseudoController.text,
          'tag_user': _tagController.text,
        }, SetOptions(merge: true));
      } catch (e) {
        print("Error saving profile data: $e");
      }
    }
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign out'),
    );
  }

  Widget _inputField(
      {required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _saveButton() {
    return ElevatedButton(
      onPressed: _saveProfileData,
      child: const Text('Save'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Mon profil', style: TextStyle(fontSize: 24)),
                  _inputField(controller: _pseudoController, label: 'Pseudo'),
                  _inputField(controller: _tagController, label: 'Tag'),
                  _saveButton(),
                  const SizedBox(height: 20),
                  _signOutButton(),
                ],
              ),
            ),
    );
  }
}
