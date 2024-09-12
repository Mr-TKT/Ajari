import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // ログイン成功後、次のページへ
      Navigator.pushReplacementNamed(context, '/profilePage');
    } catch (e) {
      setState(() {
        errorMessage = 'ログインに失敗しました。メールアドレスかパスワードが間違っています。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ログイン'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'メールアドレス'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'パスワード'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Text(errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: Text('ログイン'),
            ),
            TextButton(
              onPressed: () {
                // 新規登録ページに遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text('新規登録はこちら'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> signUp() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // アカウント作成後、プロフィール入力ページに遷移
      Navigator.pushReplacementNamed(context, '/profilePage');
    } catch (e) {
      setState(() {
        errorMessage = 'アカウント作成に失敗しました。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新規登録'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'メールアドレス'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'パスワード'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Text(errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUp,
              child: Text('登録'),
            ),
            TextButton(
              onPressed: () {
                // ログインページに戻る
                Navigator.pop(context);
              },
              child: Text('既にアカウントをお持ちの方はこちら'),
            ),
          ],
        ),
      ),
    );
  }
}
