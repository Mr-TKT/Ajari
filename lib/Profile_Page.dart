import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        }

        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          var userData = snapshot.data!.data();
          return Scaffold(
            appBar: AppBar(title: Text('Profile Page')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${userData!['name'] ?? 'N/A'}'),
                  Text('Member Type: ${userData['isPresident'] ? 'Chairman' : 'Member'}'),
                  Text('Association: ${userData['youthGroup'] ?? 'N/A'}'),
                ],
              ),
            ),
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/register');
          });
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
