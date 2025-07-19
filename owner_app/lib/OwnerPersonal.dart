// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:multi_select_flutter/multi_select_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:firebase_auth/firebase_auth.dart'; 
// import 'package:firebase_storage/firebase_storage.dart'; 
// import 'firebase_options.dart';
// import 'Auth.dart';
// import 'OwnerHomeScreen.dart'; 

// // (OwnedPropertiesListScreen と OwnerPersonalInfoScreen は以前の記憶に存在するため、ここでは省略します。)

// // UserHopeListScreen は、興味を示したユーザーリストの表示と、許可/拒否ボタンの機能を持つ
// class UserHopeListScreen extends StatefulWidget {
//   final String propertyId;
//   final List<String> userHopeList; // 興味を示したユーザーのUIDのリスト

//   const UserHopeListScreen({
//     super.key,
//     required this.propertyId,
//     required this.userHopeList,
//   });

//   @override
//   State<UserHopeListScreen> createState() => _UserHopeListScreenState();
// }

// class _UserHopeListScreenState extends State<UserHopeListScreen> {
//   List<Map<String, dynamic>> _interestedUsersData = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchInterestedUsersData();
//   }

//   // user_ID コレクションからユーザーデータを取得する
//   Future<void> _fetchInterestedUsersData() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       if (widget.userHopeList.isEmpty) {
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       List<Map<String, dynamic>> fetchedUsers = [];
//       for (String userId in widget.userHopeList) {
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('user_ID')
//             .doc(userId)
//             .get();

//         if (userDoc.exists && userDoc.data() != null) {
//           Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
//           userData['uid'] = userDoc.id; // ドキュメントID（UID）も追加
//           fetchedUsers.add(userData);
//         } else {
//           print('DEBUG: ユーザーID: $userId のデータが見つからないか空です。');
//         }
//       }

//       setState(() {
//         _interestedUsersData = fetchedUsers;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('DEBUG: 興味あるユーザーデータの取得中にエラー: $e');
//       setState(() {
//         _errorMessage = 'ユーザーデータの読み込みに失敗しました: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }

//   // ★修正: user_license と userHope を更新するメソッド（「許可する」「許可しない」ボタンの機能）
//   Future<void> _handleUserAction(String userId, bool isApproved) async {
//     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//     DocumentReference propertyDocRef = _firestore.collection('properties').doc(widget.propertyId);

//     try {
//       if (isApproved) {
//         // 「許可する」場合：user_license に追加し、userHope から削除
//         await propertyDocRef.update({
//           'user_license': FieldValue.arrayUnion([userId]), // user_license に追加
//           'userHope': FieldValue.arrayRemove([userId]),    // userHope から削除
//         });
//         print('DEBUG: ユーザーID $userId を user_license に追加し、userHope から削除しました。');

//         // 処理成功後、新しい画面へ遷移し、そのユーザーの個人情報を表示
//         if (mounted) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => UserLicenseDetailScreen(userId: userId), // 新しい画面にユーザーIDを渡す
//             ),
//           ).then((_) => _fetchInterestedUsersData()); // 戻ってきたらデータを再取得してリスト更新
//         }

//       } else {
//         // 「許可しない」場合：userHope から削除（user_licenseからの削除は不要）
//         await propertyDocRef.update({
//           'userHope': FieldValue.arrayRemove([userId]), // userHope から削除
//           // 'user_license': FieldValue.arrayRemove([userId]), // 許可しない場合は user_license から削除しない（要件による）
//         });
//         print('DEBUG: ユーザーID $userId を userHope から削除しました。');
//       }
//     } catch (e) {
//       print('DEBUG: ユーザー許可状態の更新に失敗しました: $e');
//       // エラーメッセージは表示しない（指示による）
//     } finally {
//       // 処理が完了したら、最新の状態を再取得するためにデータをリフレッシュ
//       _fetchInterestedUsersData();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: Text('ユーザーデータ取得中...')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (_errorMessage != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('エラー')),
//         body: Center(child: Text(_errorMessage!)),
//       );
//     }

//     if (widget.userHopeList.isEmpty || _interestedUsersData.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: Text('物件ID: ${widget.propertyId} に興味のあるユーザー')),
//         body: const Center(child: Text('この物件に興味を示したユーザーはまだいません。')),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('物件ID: ${widget.propertyId} に興味のあるユーザー'),
//       ),
//       body: ListView.builder(
//         itemCount: _interestedUsersData.length,
//         itemBuilder: (context, index) {
//           final userData = _interestedUsersData[index];
//           final String userId = userData['uid'] ?? '不明なUID'; // UserIDを確実に取得

//           // 表示したいプロフィール情報を取得
//           final String familyName = userData['familyName'] ?? '不明';
//           final String givenName = userData['givenName'] ?? '不明';
//           final String birthDate = userData['birthDate'] ?? '不明';
//           final String email = userData['email'] ?? '不明';
//           final String nationality = userData['nationality'] ?? '不明';
//           final String phoneNumber = userData['phoneNumber'] ?? '不明';
//           final String residenceStatus = userData['residenceStatus'] ?? '不明';
//           final String residenceCardNumber = userData['residenceCardNumber'] ?? '不明';
//           final String emergencyContactName = userData['emergencyContactName'] ?? '不明';
//           final String emergencyContactPhoneNumber = userData['emergencyContactPhoneNumber'] ?? '不明';
//           final String emergencyContactRelationship = userData['emergencyContactRelationship'] ?? '不明';
//           final String stayDurationInJapan = userData['stayDurationInJapan'] ?? '不明';
//           final List<dynamic> selectedLanguages = userData['selectedLanguages'] ?? [];
//           final String currentAddress = userData['currentAddress'] ?? '不明';
//           final String guarantorSupport = userData['guarantorSupport'] ?? '不明';
//           final String initialPaymentMethod = userData['initialPaymentMethod'] ?? '不明';
//           final String contractPeriod = userData['contractPeriod'] ?? '不明';
//           final String screeningLanguageSupport = userData['screeningLanguageSupport'] ?? '不明';


//           return Card(
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             elevation: 3,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('ユーザー名: $familyName $givenName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   Text('ユーザーID: $userId', style: const TextStyle(fontSize: 12, color: Colors.grey)), // UIDも表示
//                   Text('メールアドレス: $email'),
//                   Text('電話番号: $phoneNumber'),
//                   Text('国籍: $nationality'),
//                   Text('生年月日: $birthDate'),
//                   Text('現在の住所: $currentAddress'),
//                   Text('在留資格: $residenceStatus'),
//                   Text('在留カード番号: $residenceCardNumber'),
//                   Text('日本での滞在期間: $stayDurationInJapan'),
//                   Text('話せる言語: ${selectedLanguages.join(', ')}'),
//                   Text('緊急連絡先: $emergencyContactName ($emergencyContactRelationship, $emergencyContactPhoneNumber)'),
//                   Text('保証人サポート: $guarantorSupport'),
//                   Text('初期費用支払い方法: $initialPaymentMethod'),
//                   Text('契約期間: $contractPeriod'),
//                   Text('入居審査言語サポート: $screeningLanguageSupport'),
//                   const SizedBox(height: 16.0), // ボタンとのスペース

//                   // 「許可する」「許可しない」ボタン
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end, // 右寄せにする
//                     children: [
//                       ElevatedButton(
//                         onPressed: () => _handleUserAction(userId, true), // 許可する処理を呼び出す
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green, // 許可の色
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                         child: const Text('許可する'),
//                       ),
//                       const SizedBox(width: 10), // ボタン間のスペース
//                       ElevatedButton(
//                         onPressed: () => _handleUserAction(userId, false), // 許可しない処理を呼び出す
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red, // 許可しないの色
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                         child: const Text('許可しない'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // ★追加: 許可されたユーザーの詳細情報を表示する新しい画面
// class UserLicenseDetailScreen extends StatefulWidget {
//   final String userId; // 詳細を表示するユーザーのUID

//   const UserLicenseDetailScreen({super.key, required this.userId});

//   @override
//   State<UserLicenseDetailScreen> createState() => _UserLicenseDetailScreenState();
// }

// class _UserLicenseDetailScreenState extends State<UserLicenseDetailScreen> {
//   Map<String, dynamic>? _userDetails; // ユーザーの個人情報
//   bool _isLoading = true; // ロード中フラグ
//   String? _errorMessage; // エラーメッセージ

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserDetails(); // 初期化時にユーザーデータを取得
//   }

//   Future<void> _fetchUserDetails() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('user_ID')
//           .doc(widget.userId)
//           .get();

//       if (userDoc.exists && userDoc.data() != null) {
//         setState(() {
//           _userDetails = userDoc.data() as Map<String, dynamic>;
//         });
//       } else {
//         _errorMessage = 'ユーザー情報が見つかりません。';
//         _userDetails = null;
//       }
//     } catch (e) {
//       _errorMessage = 'ユーザー情報の取得中にエラーが発生しました: ${e.toString()}';
//       _userDetails = null;
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('ユーザー情報読み込み中...')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (_errorMessage != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('エラー')),
//         body: Center(child: Text(_errorMessage!)),
//       );
//     }

//     if (_userDetails == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('ユーザー情報')),
//         body: const Center(child: Text('ユーザー情報が見つかりません。')),
//       );
//     }

//     // ユーザー情報の項目は UserRegistrationScreen のフィールド名と一致させています
//     final String familyName = _userDetails!['familyName'] ?? '不明';
//     final String givenName = _userDetails!['givenName'] ?? '不明';
//     final String birthDate = _userDetails!['birthDate'] ?? '不明';
//     final String email = _userDetails!['email'] ?? '不明';
//     final String nationality = _userDetails!['nationality'] ?? '不明';
//     final String phoneNumber = _userDetails!['phoneNumber'] ?? '不明';
//     final String residenceStatus = _userDetails!['residenceStatus'] ?? '不明';
//     final String residenceCardNumber = _userDetails!['residenceCardNumber'] ?? '不明';
//     final String emergencyContactName = _userDetails!['emergencyContactName'] ?? '不明';
//     final String emergencyContactPhoneNumber = _userDetails!['emergencyContactPhoneNumber'] ?? '不明';
//     final String emergencyContactRelationship = _userDetails!['emergencyContactRelationship'] ?? '不明';
//     final String stayDurationInJapan = _userDetails!['stayDurationInJapan'] ?? '不明';
//     final List<dynamic> selectedLanguages = _userDetails!['selectedLanguages'] ?? [];
//     final String currentAddress = _userDetails!['currentAddress'] ?? '不明';
//     final String guarantorSupport = _userDetails!['guarantorSupport'] ?? '不明';
//     final String initialPaymentMethod = _userDetails!['initialPaymentMethod'] ?? '不明';
//     final String contractPeriod = _userDetails!['contractPeriod'] ?? '不明';
//     final String screeningLanguageSupport = _userDetails!['screeningLanguageSupport'] ?? '不明';


//     return Scaffold(
//       appBar: AppBar(
//         title: Text('ユーザー: $familyName $givenName'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('ユーザーID: ${widget.userId}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
//             const SizedBox(height: 10),
//             Text('氏名: $familyName $givenName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Text('メールアドレス: $email'),
//             Text('電話番号: $phoneNumber'),
//             Text('国籍: $nationality'),
//             Text('生年月日: $birthDate'),
//             Text('現在の住所: $currentAddress'),
//             Text('在留資格: $residenceStatus'),
//             Text('在留カード番号: $residenceCardNumber'),
//             Text('日本での滞在期間: $stayDurationInJapan'),
//             Text('話せる言語: ${selectedLanguages.join(', ')}'),
//             Text('緊急連絡先: $emergencyContactName ($emergencyContactRelationship, $emergencyContactPhoneNumber)'),
//             Text('保証人サポート: $guarantorSupport'),
//             Text('初期費用支払い方法: $initialPaymentMethod'),
//             Text('契約期間: $contractPeriod'),
//             Text('入居審査言語サポート: $screeningLanguageSupport'),
//             // 他の個人情報もここに追加
//           ],
//         ),
//       ),
//     );
//   }
// }