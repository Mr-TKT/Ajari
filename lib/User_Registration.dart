import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRegistrationPage extends StatefulWidget {
  @override
  _UserRegistrationPageState createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final _nameController = TextEditingController();
  final _youthGroupController = TextEditingController();
  bool _isPresident = false;

  void _registerUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
        'name': _nameController.text,
        'isPresident': _isPresident,
        'youthGroup': _youthGroupController.text,
        'permission': false,
        'requestDenied': false,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ユーザー登録')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '氏名'),
            ),
            TextField(
              controller: _youthGroupController,
              decoration: InputDecoration(labelText: '所属青年会名'),
            ),
            SwitchListTile(
              title: Text('会長ですか？'),
              value: _isPresident,
              onChanged: (val) => setState(() => _isPresident = val),
            ),
            ElevatedButton(
              onPressed: _registerUser,
              child: Text('登録'),
            ),
          ],
        ),
      ),
    );
  }
}
