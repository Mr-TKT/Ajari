import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestMichijunePage extends StatefulWidget {
  @override
  _RequestMichijunePageState createState() => _RequestMichijunePageState();
}

class _RequestMichijunePageState extends State<RequestMichijunePage> {
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isPresident = false;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  void _checkUserStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        setState(() {
          _isPresident = userDoc.data()?['isPresident'] ?? false;
        });
      }
    }
  }

  void _submitRequest() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('requests').add({
        'userId': currentUser.uid,
        'date': _dateController.text,
        'location': _locationController.text,
        'permission': false,
        'requestDenied': false,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPresident) {
      return Scaffold(
        body: Center(child: Text('青年会会長ではないため、このページを開くことができません。')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('道じゅねー申請')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: '日時 (YYYYMMDDHHMM)'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: '場所'),
            ),
            ElevatedButton(
              onPressed: _submitRequest,
              child: Text('申請'),
            ),
          ],
        ),
      ),
    );
  }
}
