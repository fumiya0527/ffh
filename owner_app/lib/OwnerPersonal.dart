import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OwnerPersonalInfoScreen extends StatefulWidget {
  final String ownerId;
  const OwnerPersonalInfoScreen({super.key, required this.ownerId});

  @override
  State<OwnerPersonalInfoScreen> createState() => _OwnerPersonalInfoScreenState();
}

class _OwnerPersonalInfoScreenState extends State<OwnerPersonalInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBarはホーム画面にあるのでここでは不要
      body: StreamBuilder<QuerySnapshot>(
        // 'schedules'コレクションから、自分がオーナーのものを監視
        stream: FirebaseFirestore.instance
            .collection('schedules')
            .where('ownerId', isEqualTo: widget.ownerId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          /*if (snapshot.hasError) {
            return Center(child: Text('エラー: ${snapshot.error}'));
          }*/
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('ユーザーからの日程調整リクエストはまだありません。'));
          }

          final schedules = snapshot.data!.docs;

          return ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final data = schedules[index].data() as Map<String, dynamic>;
              final List<Timestamp> desiredTimes = (data['desiredTimes'] as List<dynamic>).map((t) => t as Timestamp).toList();
              
              // ユーザー情報を取得するためにFutureBuilderを使用
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('user_ID').doc(data['userId']).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Card(margin: EdgeInsets.all(8), child: ListTile(title: Text('ユーザー情報を読み込み中...')));
                  }
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final userName = "${userData['familyName'] ?? ''} ${userData['givenName'] ?? ''}";

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Divider(),
                          const Text('希望日時:', style: TextStyle(color: Colors.grey)),
                          ...desiredTimes.map((ts) {
                            final dt = ts.toDate();
                            return Text("・ ${DateFormat('yyyy/MM/dd (E) HH:mm', 'ja_JP').format(dt)}");
                          }).toList(),
                          const SizedBox(height: 10),
                          // ここに「日時を確定する」「Zoomリンクを送る」などのボタンを将来的に追加できます
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}