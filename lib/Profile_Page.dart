import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // ユーザーがダイアログの外をタップしても閉じない
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ログアウトの確認'),
          content: Text('本当にログアウトしますか？'),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
            TextButton(
              child: Text('ログアウト'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
          ],
        );
      },
    );
  }

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
          bool isPresident = userData?['isPresident'] ?? false;
          return Scaffold(
            appBar: AppBar(title: Text('Profile Page')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${userData!['name'] ?? 'N/A'}'),
                  Text('Member Type: ${isPresident ? '青年会会長' : '青年会会員'}'),
                  Text('Association: ${userData['youthGroup'] ?? 'N/A'}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showLogoutConfirmationDialog(context),
                    child: Text('ログアウト'),
                  ),
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
