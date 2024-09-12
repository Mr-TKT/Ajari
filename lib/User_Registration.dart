import 'package:ajari/Profile_Page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRegistrationPage extends StatefulWidget {
  @override
  _UserRegistrationPageState createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final _nameController = TextEditingController();
  String? _selectedYouthGroup;
  bool _isPresident = false;
  List<String> _youthGroups = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchYouthGroups();
  }

  void _fetchYouthGroups() async {
    final snapshot = await FirebaseFirestore.instance.collection('youthGroups').get();
    final youthGroups = snapshot.docs.map((doc) => doc.id).toList();
    setState(() {
      _youthGroups = youthGroups;
    });
  }

  void _registerUser() async {
    if (_selectedYouthGroup != null) {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
          'name': _nameController.text,
          'isPresident': _isPresident,
          'youthGroup': _selectedYouthGroup,
          'permission': false,
          'requestDenied': false,
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProfilePage(),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = '青年会を選択してください。';
      });
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
            DropdownButton<String>(
              value: _selectedYouthGroup,
              hint: Text('所属青年会名'),
              items: _youthGroups.map((group) {
                return DropdownMenuItem<String>(
                  value: group,
                  child: Text(group),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedYouthGroup = value;
                  _errorMessage = ''; // Clear error message on selection
                });
              },
            ),
            SwitchListTile(
              title: Text('会長ですか？'),
              value: _isPresident,
              onChanged: (val) => setState(() => _isPresident = val),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
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
