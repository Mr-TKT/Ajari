import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Profile_Page.dart';
import 'User_Registration.dart';
import 'Request_Michijune.dart';
import 'Login_Page.dart'; // ログインページ

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebaseの初期化
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // 初期ルート（ログイン画面またはプロフィールページ）
      home: AuthGate(),
      routes: {
        '/profile': (context) => ProfilePage(), // プロフィールページ
        '/register': (context) => UserRegistrationPage(), // 登録ページ
        '/request_michijune': (context) => RequestMichijunePage(), // 道じゅねー申請ページ
      },
    );
  }
}

// ログイン状態を管理して、適切なページへリダイレクトする
class AuthGate extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // ユーザーがログインしている場合、プロフィールページへ
          return ProfilePage();
        } else {
          // ログインしていない場合、ログインページへ
          return LoginPage();
        }
      },
    );
  }
}
