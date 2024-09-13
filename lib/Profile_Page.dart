import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userFuture;
  late Future<List<String>> _youthGroups;
  late Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _permittedDataFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserData();
    _youthGroups = _fetchYouthGroups();
    _permittedDataFuture = _fetchPermittedData(); // 道じゅねーのデータを取得
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    } else {
      throw Exception('No user logged in');
    }
  }

  Future<List<String>> _fetchYouthGroups() async {
    final snapshot = await FirebaseFirestore.instance.collection('youthGroups').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchPermittedData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final youthGroup = userData.data()?['youthGroup'];
      if (youthGroup != null) {
        final snapshot = await FirebaseFirestore.instance.collection('permitted')
            .where('youthGroup', isEqualTo: youthGroup)
            .get();
        return snapshot.docs;
      }
    }
    return [];
  }

  void _showImageDialog(String url) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: InteractiveViewer(
              child: Image.network(url),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog(String fieldName, String initialValue, List<String>? options, Function(String) onUpdate) async {
    final TextEditingController _controller = TextEditingController(text: initialValue);
    String? selectedValue = initialValue;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $fieldName'),
          content: options == null
              ? TextField(
                  controller: _controller,
                  decoration: InputDecoration(labelText: fieldName),
                )
              : DropdownButtonFormField<String>(
                  value: selectedValue,
                  items: options.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value;
                    });
                  },
                  decoration: InputDecoration(labelText: fieldName),
                ),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('変更する'),
              onPressed: () async {
                if (selectedValue != null) {
                  await onUpdate(selectedValue!);
                  setState(() {
                    _userFuture = _fetchUserData(); // Fetch updated data
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateField(String fieldName, dynamic value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({fieldName: value});
    }
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ログアウトの確認'),
          content: Text('本当にログアウトしますか？'),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ログアウト'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', // ログイン画面のルート名
                  (route) => false, // すべての画面をポップする
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'プロフィール',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 4.0,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
            var userData = snapshot.data!.data()!;
            bool isPresident = userData['isPresident'] ?? false;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoCard(
                            'Name',
                            userData['name'] ?? 'N/A',
                            null,
                            (newValue) async {
                              await _updateField('name', newValue);
                            },
                          ),
                          SizedBox(height: 8),
                          _buildInfoCard(
                            'Member Type',
                            isPresident ? '青年会会長' : '青年会会員',
                            ['青年会会長', '青年会会員'],
                            (newValue) async {
                              await _updateField('isPresident', newValue == '青年会会長');
                            },
                          ),
                          SizedBox(height: 8),
                          FutureBuilder<List<String>>(
                            future: _youthGroups,
                            builder: (context, youthGroupsSnapshot) {
                              if (youthGroupsSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              if (youthGroupsSnapshot.hasError) {
                                return Center(child: Text('Error: ${youthGroupsSnapshot.error}'));
                              }

                              List<String> youthGroups = youthGroupsSnapshot.data ?? [];

                              return _buildInfoCard(
                                'Association',
                                userData['youthGroup'] ?? 'N/A',
                                youthGroups,
                                (newValue) async {
                                  await _updateField('youthGroup', newValue);
                                },
                              );
                            },
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _showLogoutConfirmationDialog(context),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                            ),
                            child: Text('ログアウト'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "許可済み道じゅねー",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 14),
                          Expanded(
                            child: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                              future: _permittedDataFuture,
                              builder: (context, permittedSnapshot) {
                                if (permittedSnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }
                            
                                if (permittedSnapshot.hasError) {
                                  return Center(child: Text('Error: ${permittedSnapshot.error}'));
                                }
                            
                                if (permittedSnapshot.hasData && permittedSnapshot.data != null) {
                                  final permittedDocs = permittedSnapshot.data!;
                                  if (permittedDocs.isEmpty) {
                                    return _buildNoPermittedCard();
                                  }
                                  return ListView(
                                    children: permittedDocs.map((doc) {
                                      final data = doc.data();
                                      final date = data['date'] ?? 'N/A';
                                      final startTime = data['startTime'] ?? 'N/A';
                                      final endTime = data['endTime'] ?? 'N/A';
                                      final imageUrl = data['url'] ?? ''; // 画像URLを取得
                            
                                      return Container(
                                        color: Colors.white,
                                        child: Card(
                                          color: Colors.white,
                                          margin: EdgeInsets.symmetric(vertical: 8.0),
                                          child: ListTile(
                                            contentPadding: EdgeInsets.all(16.0),
                                            title: Text('Date: $date'),
                                            subtitle: Text('Start Time: $startTime\nEnd Time: $endTime'),
                                            onTap: () {
                                              if (imageUrl.isNotEmpty) {
                                                _showImageDialog(imageUrl); // 画像を表示
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                }
                            
                                return _buildNoPermittedCard();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamed(context, '/register').then((_) {
                // ProfilePageに戻ったときにリフレッシュする
                setState(() {
                  // 必要なデータを再取得する処理など
                  _userFuture = _fetchUserData();
                  _youthGroups = _fetchYouthGroups();
                  _permittedDataFuture = _fetchPermittedData(); // 道じゅねーのデータを取得
                });
              });
            });
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, List<String>? options, Function(String) onUpdate) {
    return GestureDetector(
      onTap: () => _showEditDialog(
        title,
        value,
        options,
        onUpdate,
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.teal),
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$title:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoPermittedCard() {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        title: Text('No Permitted Junes'),
        subtitle: Text('許可された道じゅねーはまだありません。'),
      ),
    );
  }
}
