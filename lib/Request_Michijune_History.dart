import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // 日付フォーマット用

const Color kPrimaryColor = Colors.teal; // エイサーのイメージカラー

class RequestMichijuneHistoryPage extends StatefulWidget {
  @override
  _RequestMichijuneHistoryPageState createState() => _RequestMichijuneHistoryPageState();
}

class _RequestMichijuneHistoryPageState extends State<RequestMichijuneHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _showDeleteConfirmationDialog(String requestId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // ダイアログ外のタップで閉じるのを無効にする
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認'),
          content: Text('この申請を削除しますか？'),
          actions: <Widget>[
            TextButton(
              child: Text('いいえ'),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
            TextButton(
              child: Text('はい'),
              onPressed: () async {
                try {
                  await _firestore.collection('requests').doc(requestId).delete();
                  Navigator.of(context).pop(); // ダイアログを閉じる
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('削除しました'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  // エラー処理
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('削除中にエラーが発生しました: $e')),
                  );
                }
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
          '申請履歴',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kPrimaryColor, // エイサーのイメージに合わせた色
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('requests')
            .where('userId', isEqualTo: _auth.currentUser?.uid)
            .orderBy('requestDateTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('申請履歴はありません'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final requestData = request.data() as Map<String, dynamic>;

              final requestDate = (requestData['requestDateTime'] as Timestamp).toDate();
              final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(requestDate);

              // 承認状況と却下状況に応じてカードの縁の色を設定
              Color borderColor;
              if (requestData['permission']) {
                borderColor = Colors.blue; // 承認済み
              } else if (requestData['requestDenied']) {
                borderColor = Colors.red; // 却下済み
              } else {
                borderColor = Colors.grey; // 未承認
              }

              return Card(
                margin: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: borderColor, width: 2.0), // カードの縁の色
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  tileColor: Colors.white,
                  title: Text('申請日時: $formattedDate'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('日付: ${requestData['date']}'),
                      Text('開始時間: ${requestData['startTime']}'),
                      Text('終了時間: ${requestData['endTime']}'),
                      Text('場所: ${requestData['location']}'),
                      Text('承認状況: ${requestData['permission'] ? '承認済み' : '未承認'}'),
                      Text('却下状況: ${requestData['requestDenied'] ? '却下済み' : '未却下'}'),
                    ],
                  ),
                  onTap: () {
                    _showDeleteConfirmationDialog(request.id); // ダイアログを表示
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
