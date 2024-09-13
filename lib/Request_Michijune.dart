import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // 日付フォーマット用

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
      appBar: AppBar(title: Text('道じゅねー申請')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(_selectedDate.isEmpty ? '日付を選択' : '選択した日付: $_selectedDate'),
            ),
            ElevatedButton(
              onPressed: () => _selectStartTime(context),
              child: Text(_startTime.isEmpty ? '開始時間を選択' : '開始時間: $_startTime'),
            ),
            ElevatedButton(
              onPressed: () => _selectEndTime(context),
              child: Text(_endTime.isEmpty ? '終了時間を選択' : '終了時間: $_endTime'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: '場所'),
            ),
            SizedBox(height: 16),
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
