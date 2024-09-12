import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'User_Registration.dart';

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Center(child: Text('ログインしていません。'));
    }

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    return FutureBuilder<DocumentSnapshot>(
      future: userDocRef.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // プロフィール未登録の場合は登録ページへ遷移
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserRegistrationPage()),
            );
          });
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        return Scaffold(
          appBar: AppBar(title: Text('プロフィール')),
          body: Column(
            children: [
              Text('氏名: ${userData['name']}'),
              Text('会員タイプ: ${userData['isPresident'] ? '会長' : '一般会員'}'),
              Text('所属青年会: ${userData['youthGroup']}'),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/request_michijune');
                },
                child: Text('道じゅねー申請ページへ'),
              ),
            ],
          ),
        );
      },
    );
  }
}
