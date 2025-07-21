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
                  final String propertyId = propertyDocs[index].id; // 物件IDを取得
                  final Timestamp? timestamp = data['timestamp'] as Timestamp?;
                  String formattedTime = '登録日時不明';
                  if (timestamp != null) {
                    formattedTime = DateFormat('yyyy/MM/dd HH:mm').format(timestamp.toDate());
                  }
                  final String? imageUrl = data['imageUrl'] as String?;

                  // userHope配列を取得
                  final List<dynamic> userHope = data['userHope'] as List<dynamic>? ?? [];

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
                          Text('興味を示したユーザー数: ${userHope.length}', style: TextStyle(fontWeight: FontWeight.bold, color: userHope.isNotEmpty ? Colors.blue : Colors.grey)), // ユーザー数を表示
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      // ★ここから修正
                      onTap: () {
                        if (userHope.isNotEmpty) {
                          // userHope配列にユーザーIDがある場合、次のページに飛ぶ
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserHopeListScreen(
                                propertyId: propertyId,
                                userHopeList: userHope.cast<String>(), // String型にキャスト
                              ),
                            ),
                          );
                        } else {
                          // userHope配列が空の場合、SnackBarを表示
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${data['propertyName'] ?? '不明'} に興味を示しているユーザーはまだいません。')),
                          );
                        }
                      },
                      // ★ここまで修正
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

// ★追加: 興味を示したユーザー一覧を表示する新しい画面
class UserHopeListScreen extends StatefulWidget {
  final String propertyId;
  final List<String> userHopeList; // 興味を示したユーザーのUIDのリスト

  const UserHopeListScreen({
    super.key,
    required this.propertyId,
    required this.userHopeList,
  });

  @override
  State<UserHopeListScreen> createState() => _UserHopeListScreenState();
}

class _UserHopeListScreenState extends State<UserHopeListScreen> {
  // ユーザー情報を保持するリスト
  List<Map<String, dynamic>> _interestedUsersData = [];
  bool _isLoading = true; // データロード中かどうかのフラグ
  String? _errorMessage; // エラーメッセージ

  @override
  void initState() {
    super.initState();
    _fetchInterestedUsersData(); // 画面初期化時にユーザーデータを取得
  }

  Future<void> _fetchInterestedUsersData() async {
    setState(() {
      _isLoading = true; // ロード開始
      _errorMessage = null; // エラーメッセージをリセット
    });

    try {
      if (widget.userHopeList.isEmpty) {
        // 興味を示したユーザーがいない場合
        setState(() {
          _isLoading = false;
        });
        return;
      }

      List<Map<String, dynamic>> fetchedUsers = [];
      // userHopeList の各 userId を使って user_ID コレクションからデータを取得
      for (String userId in widget.userHopeList) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user_ID')
            .doc(userId)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          // 取得したデータをマップとして追加
          // ここでUIDもマップに追加しておくと、後でボタンのonPressedで使いやすい
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          userData['uid'] = userDoc.id; // ドキュメントID（UID）も追加
          fetchedUsers.add(userData);
        } else {
          print('DEBUG: ユーザーID: $userId のデータが見つからないか空です。');
        }
      }

      setState(() {
        _interestedUsersData = fetchedUsers;
        _isLoading = false; // ロード完了
      });
    } catch (e) {
      print('DEBUG: 興味あるユーザーデータの取得中にエラー: $e');
      setState(() {
        _errorMessage = 'ユーザーデータの読み込みに失敗しました: ${e.toString()}';
        _isLoading = false; // ロード完了
      });
    }
  }

  // ★追加: user_license と userHope を更新するメソッド
  Future<void> _updateUserHopeAndLicense(String userId, bool isApproved) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    DocumentReference propertyDocRef = _firestore.collection('properties').doc(widget.propertyId);

    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(propertyDocRef);

        if (!snapshot.exists) {
          throw Exception("物件が見つかりません。");
        }

        Map<String, dynamic> currentData = snapshot.data() as Map<String, dynamic>;
        List<dynamic> currentUserHope = currentData['userHope'] ?? [];
        List<dynamic> currentUserLicense = currentData['user_license'] ?? [];

        // userHope から対象ユーザーを削除
        List<dynamic> newUserHope = List.from(currentUserHope)..remove(userId);

        if (isApproved) {
          // 許可する場合: user_license に追加 (重複は FieldValue.arrayUnion で防ぐ)
          if (!currentUserLicense.contains(userId)) {
             transaction.update(propertyDocRef, {
              'user_license': FieldValue.arrayUnion([userId]),
              'userHope': newUserHope, // userHope も同時に更新
            });
            print('DEBUG: ユーザーID $userId を user_license に追加し、userHope から削除しました。');
          } else {
            // 既にuser_licenseにいる場合はuserHopeだけ削除
            transaction.update(propertyDocRef, {
              'userHope': newUserHope,
            });
            print('DEBUG: ユーザーID $userId は既にuser_licenseに存在。userHope からのみ削除しました。');
          }
        } else {
          // 許可しない場合: user_license からも削除（念のため）、userHope から削除
          List<dynamic> newUserLicense = List.from(currentUserLicense)..remove(userId);
          transaction.update(propertyDocRef, {
            'userHope': newUserHope,
            'user_license': newUserLicense, // 念のためuser_licenseからも削除
          });
          print('DEBUG: ユーザーID $userId を userHope から削除し、user_licenseからも削除しました。');
        }
      });
    } catch (e) {
      print('DEBUG: ユーザー許可状態の更新に失敗しました: $e');
      // ここでエラーメッセージをユーザーに表示しない（指示による）
    } finally {
      // 処理が完了したら、最新の状態を再取得するためにデータをリフレッシュ
      _fetchInterestedUsersData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('ユーザーデータ取得中...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('エラー')),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (widget.userHopeList.isEmpty || _interestedUsersData.isEmpty) { // userHopeListが空の場合も考慮
      return Scaffold(
        appBar: AppBar(title: Text('物件ID: ${widget.propertyId} に興味のあるユーザー')),
        body: const Center(child: Text('この物件に興味を示したユーザーはまだいません。')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('物件ID: ${widget.propertyId} に興味のあるユーザー'),
      ),
      body: ListView.builder(
        itemCount: _interestedUsersData.length,
        itemBuilder: (context, index) {
          final userData = _interestedUsersData[index];
          final String userId = userData['uid'] ?? '不明なUID'; // UserIDを確実に取得

          // 表示したいプロフィール情報を取得
          final String familyName = userData['familyName'] ?? '不明';
          final String givenName = userData['givenName'] ?? '不明';
          final String birthDate = userData['birthDate'] ?? '不明';
          final String email = userData['email'] ?? '不明';
          final String nationality = userData['nationality'] ?? '不明';
          final String phoneNumber = userData['phoneNumber'] ?? '不明';
          final String residenceStatus = userData['residenceStatus'] ?? '不明';
          final String residenceCardNumber = userData['residenceCardNumber'] ?? '不明';
          final String emergencyContactName = userData['emergencyContactName'] ?? '不明';
          final String emergencyContactPhoneNumber = userData['emergencyContactPhoneNumber'] ?? '不明';
          final String emergencyContactRelationship = userData['emergencyContactRelationship'] ?? '不明';
          final String stayDurationInJapan = userData['stayDurationInJapan'] ?? '不明';
          final List<dynamic> selectedLanguages = userData['selectedLanguages'] ?? [];
          final String currentAddress = userData['currentAddress'] ?? '不明';
          final String guarantorSupport = userData['guarantorSupport'] ?? '不明';
          final String initialPaymentMethod = userData['initialPaymentMethod'] ?? '不明';
          final String contractPeriod = userData['contractPeriod'] ?? '不明';
          final String screeningLanguageSupport = userData['screeningLanguageSupport'] ?? '不明';


          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ユーザー名: $familyName $givenName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('ユーザーID: $userId', style: const TextStyle(fontSize: 12, color: Colors.grey)), // UIDも表示
                  Text('メールアドレス: $email'),
                  Text('電話番号: $phoneNumber'),
                  Text('国籍: $nationality'),
                  Text('生年月日: $birthDate'),
                  Text('現在の住所: $currentAddress'),
                  Text('在留資格: $residenceStatus'),
                  Text('在留カード番号: $residenceCardNumber'),
                  Text('日本での滞在期間: $stayDurationInJapan'),
                  Text('話せる言語: ${selectedLanguages.join(', ')}'),
                  Text('緊急連絡先: $emergencyContactName ($emergencyContactRelationship, $emergencyContactPhoneNumber)'),
                  Text('保証人サポート: $guarantorSupport'),
                  Text('初期費用支払い方法: $initialPaymentMethod'),
                  Text('契約期間: $contractPeriod'),
                  Text('入居審査言語サポート: $screeningLanguageSupport'),
                  const SizedBox(height: 16.0), // ボタンとのスペース

                  // 「許可する」「許可しない」ボタン
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, // 右寄せにする
                    children: [
                      ElevatedButton(
                        onPressed: () => _updateUserHopeAndLicense(userId, true), // ★修正点: 許可する場合
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('許可する'),
                      ),
                      const SizedBox(width: 10), // ボタン間のスペース
                      ElevatedButton(
                        onPressed: () => _updateUserHopeAndLicense(userId, false), // ★修正点: 許可しない場合
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red
                        ),
                        child: const Text('許可しない'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}