import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:firebase_storage/firebase_storage.dart'; 
import 'firebase_options.dart';
import 'Auth.dart';
import 'OwnerHomeScreen.dart';

//オーナー物件一覧クラス
class OwnedPropertiesListScreen extends StatelessWidget {
  final String currentOwnerId;
  const OwnedPropertiesListScreen({super.key, required this.currentOwnerId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'あなたの所持物件一覧',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'ログイン中のオーナーID: ${currentOwnerId}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('properties')
                .where('ownerId', isEqualTo: currentOwnerId)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('物件データ取得失敗: ${snapshot.error.toString()}\n詳細: ${snapshot.error.runtimeType}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final propertyDocs = snapshot.data!.docs;
              if (propertyDocs.isEmpty) {
                return const Center(child: Text('まだ物件が登録されていません。'));
              }

              return ListView.builder(
                itemCount: propertyDocs.length,
                itemBuilder: (context, index) {
                  final data = propertyDocs[index].data() as Map<String, dynamic>;
                  final Timestamp? timestamp = data['timestamp'] as Timestamp?;
                  String formattedTime = '登録日時不明';
                  if (timestamp != null) {
                    formattedTime = DateFormat('yyyy/MM/dd HH:mm').format(timestamp.toDate());
                  }
                  final String? imageUrl = data['imageUrl'] as String?;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 3,
                    child: ListTile(
                      leading: imageUrl != null && imageUrl.isNotEmpty
                          ? SizedBox(
                              width: 60,
                              height: 60,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image, size: 40);
                                },
                              ),
                            )
                          : Icon(Icons.home_work, color: Theme.of(context).primaryColor),
                      title: Text(data['propertyName'] ?? '名称不明', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('所在地: ${data['address'] ?? '不明'}'),
                          Text('家賃: ${data['rent']?.toString() ?? '不明'}円'),
                          Text('間取り: ${data['floorPlan'] ?? '不明'}'),
                          Text('築年数: ${data['buildingAge'] ?? '不明'}'), 
                          Text('駅距離: ${data['distanceToStation'] ?? '不明'}'),
                          Text('設備: ${(data['amenities'] as List?)?.join(', ') ?? 'なし'}'),
                          Text('登録日時: $formattedTime'),
                          Text('オーナーID: ${data['ownerId'] ?? '不明'}'),
                          Text('物件ID: ${propertyDocs[index].id}'), 
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${data['propertyName'] ?? '不明'} の詳細')),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}