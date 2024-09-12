import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Profile_Page.dart';
import 'User_Registration.dart';
import 'Request_Michijune.dart';
import 'Login_Page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthGate(),
      routes: {
        '/profile': (context) => ProfilePage(),
        '/register': (context) => UserRegistrationPage(),
        '/request_michijune': (context) => RequestMichijunePage(),
      },
    );
  }
}

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
          return UserHomePage(); // Homeページにリダイレクト
        } else {
          return LoginPage();
        }
      },
    );
  }
}

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  late bool _isPresident;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  void _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _isPresident = userData['isPresident'] ?? false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? ProfilePage()
          : _isPresident
              ? RequestMichijunePage()
              : Scaffold(
                  appBar: AppBar(title: Text('アクセス権限')),
                  body: Center(child: Text('青年会会長ではないので、このページを開くことができません。')),
                ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'プロフィール'),
          BottomNavigationBarItem(icon: Icon(Icons.request_page), label: '道じゅねー申請'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
