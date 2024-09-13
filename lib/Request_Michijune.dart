import 'package:ajari/Request_Michijune_History.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart'; // 日付フォーマット用

const Color kPrimaryColor = Colors.teal; // エイサーのイメージカラー
const Color kTextColorPrimary = Color(0xFFffffff);
const Color kTextColorSecondary = Color(0xFF9E9E9E);

class RequestMichijunePage extends StatefulWidget {
  @override
  _RequestMichijunePageState createState() => _RequestMichijunePageState();
}

class _RequestMichijunePageState extends State<RequestMichijunePage> {
  final _locationController = TextEditingController();
  String _selectedDate = ''; // 選択された日付
  String _startTime = ''; // 開始時間
  String _endTime = ''; // 終了時間
  bool _isPresident = false;
  String? _youthGroupName; // 青年会名

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
          _youthGroupName = userDoc.data()?['youthGroup']; // 青年会名を取得
        });
      }
    }
  }

  void _submitRequest() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null && _validateInput()) {
      await FirebaseFirestore.instance.collection('requests').add({
        'userId': currentUser.uid,
        'youthGroup': _youthGroupName, // 青年会名
        'date': _selectedDate,
        'startTime': _startTime,
        'endTime': _endTime,
        'location': _locationController.text,
        'permission': false,
        'requestDenied': false,
        'requestDateTime': Timestamp.now(), // 申請日時
      });

      _clearInputFields(); // 入力フィールドをリセット

      // 申請完了の通知を表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('申請しました'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearInputFields() {
    setState(() {
      _selectedDate = '';
      _startTime = '';
      _endTime = '';
      _locationController.clear();
    });
  }

  bool _validateInput() {
    if (_selectedDate.isEmpty) {
      _showErrorDialog('日付を選択してください。');
      return false;
    }
    if (_startTime.isEmpty) {
      _showErrorDialog('開始時間を選択してください。');
      return false;
    }
    if (_endTime.isEmpty) {
      _showErrorDialog('終了時間を選択してください。');
      return false;
    }
    if (_locationController.text.isEmpty) {
      _showErrorDialog('場所を入力してください。');
      return false;
    }
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('入力エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked.format(context);
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked.format(context);
      });
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
      appBar: AppBar(
        title: Text(
          '道じゅねー申請',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: kPrimaryColor, // エイサーのイメージに合わせた色
      ),
      body: LayoutBuilder(
        builder: (context, Constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: Constraints.maxHeight
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 4,
                              blurRadius: 8,
                              offset: Offset(0, 4), // changes position of shadow
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Association: $_youthGroupName',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _selectDate(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                                )
                              ),
                              child: Text(_selectedDate.isEmpty ? '日付を選択' : '選択した日付: $_selectedDate',
                              style: TextStyle(color: Colors.white),),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _selectStartTime(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                                )
                              ),
                              child: Text(_startTime.isEmpty ? '開始時間を選択' : '開始時間: $_startTime',
                              style: TextStyle(color: Colors.white),),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _selectEndTime(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                                )
                              ),
                              child: Text(_endTime.isEmpty ? '終了時間を選択' : '終了時間: $_endTime',
                              style: TextStyle(color: Colors.white),),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: '場所',
                                hintText: '場所を入力してください',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _submitRequest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                              ),
                              child: Text('申請', style: TextStyle(color: Colors.white),),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RequestMichijuneHistoryPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                        ),
                        child: Text('申請履歴', style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
