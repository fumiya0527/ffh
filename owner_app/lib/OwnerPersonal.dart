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
import 'OwnerHomeScreen.dart'; // OwnerHomeScreen がこのファイル内にあるか、正しくインポートされている前提

// (OwnerHomeScreen クラスは以前の記憶に存在するため、ここでは省略します。)

// ★修正: OwnerPersonalInfoScreen に user_license チェックロジックを復活
class OwnerPersonalInfoScreen extends StatefulWidget {
  final String ownerId; // ログイン中のオーナーのUIDを受け取る
  const OwnerPersonalInfoScreen({super.key, required this.ownerId});

  @override
  State<OwnerPersonalInfoScreen> createState() => _OwnerPersonalInfoScreenState();
}

class _OwnerPersonalInfoScreenState extends State<OwnerPersonalInfoScreen> {
  Map<String, dynamic>? _ownerData; // オーナーの個人情報
  bool _isLoading = true; // ロード中フラグ
  String? _errorMessage; // エラーメッセージ
  bool _isLicensed = false; // ★復活: user_licenseにUIDがあるかどうかを示すフラグ

  @override
  void initState() {
    super.initState();
    _checkLicenseAndLoadOwnerData(); // 初期化時にライセンスチェックとデータ読み込み
  }

  // オーナーの個人情報をFirestoreから取得し、user_licenseをチェックする関数
  Future<void> _checkLicenseAndLoadOwnerData() async {
    setState(() {
      _isLoading = true; // ロード開始
      _errorMessage = null; // エラーメッセージをリセット
      _isLicensed = false; // フラグをリセット
    });

    try {
      final String currentOwnerUid = widget.ownerId; // ログイン中のオーナーID

      // 1. 全ての物件の user_license をチェックし、オーナーUIDが含まれているか確認
      // オーナーが登録した物件に絞ることも可能ですが、ここでは「どの物件のuser_licenseでも良い」と解釈します
      QuerySnapshot propertiesSnapshot = await FirebaseFirestore.instance
          .collection('properties')
          .get();

      bool foundInLicense = false;
      for (var doc in propertiesSnapshot.docs) {
        List<dynamic> userLicenseList = (doc.data() as Map<String, dynamic>)['user_license'] ?? [];
        if (userLicenseList.contains(currentOwnerUid)) {
          foundInLicense = true;
          break; // 見つかったらループ終了
        }
      }

      setState(() {
        _isLicensed = foundInLicense; // ライセンスフラグを更新
      });

      if (foundInLicense) {
        // 2. user_license にUIDがあれば、そのUIDのuser_IDドキュメントを読み込む
        DocumentSnapshot ownerDoc = await FirebaseFirestore.instance
            .collection('user_ID')
            .doc(currentOwnerUid)
            .get();

        if (ownerDoc.exists && ownerDoc.data() != null) {
          setState(() {
            _ownerData = ownerDoc.data() as Map<String, dynamic>;
          });
        } else {
          // ドキュメントが見つからないか、データが空の場合
          _errorMessage = 'オーナーの個人情報が見つかりません。'; // エラーメッセージを設定
          _ownerData = null;
        }
      } else {
        // user_license にUIDがない場合
        // _errorMessage は設定せず、_isLicensed = false のままにしてUIで「権限がありません」と表示させる
        _ownerData = null; // データは表示しない
      }
    } catch (e) {
      // データ取得中の予期せぬエラー
      _errorMessage = 'データ取得中にエラーが発生しました: ${e.toString()}'; // エラーメッセージを設定
      _ownerData = null; // データは表示しない
    } finally {
      setState(() {
        _isLoading = false; // ロード完了
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator()); // ロード中はインジケーターを表示
    }

    // ★修正: user_license の有無に基づいてUIを切り替える
    if (!_isLicensed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, color: Colors.orange, size: 50),
              SizedBox(height: 10),
              Text(
                '個人情報を表示するための権限がありません。\n（オーナーUIDがuser_licenseに登録されていません）',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange, fontSize: 16),
              ),
              // ★再試行ボタンは削除 (ご要望により)
              // SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: _checkLicenseAndLoadOwnerData,
              //   child: Text('再試行'),
              // ),
            ],
          ),
        ),
      );
    }

    // データがロードされたが、_ownerDataがnullの場合（_isLicensedがtrueでもデータが取得できない場合）
    if (_ownerData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.grey, size: 50),
              SizedBox(height: 10),
              Text(
                _errorMessage ?? 'オーナーの個人情報が見つかりません。', // エラーメッセージがあれば表示
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // 個人情報が表示されるべき部分
    final String familyName = _ownerData!['familyName'] ?? '不明';
    final String givenName = _ownerData!['givenName'] ?? '不明';
    final String birthDate = _ownerData!['birthDate'] ?? '不明';
    final String email = _ownerData!['email'] ?? '不明';
    final String nationality = _ownerData!['nationality'] ?? '不明';
    final String phoneNumber = _ownerData!['phoneNumber'] ?? '不明';
    final String residenceStatus = _ownerData!['residenceStatus'] ?? '不明';
    final String residenceCardNumber = _ownerData!['residenceCardNumber'] ?? '不明';
    final String emergencyContactName = _ownerData!['emergencyContactName'] ?? '不明';
    final String emergencyContactPhoneNumber = _ownerData!['emergencyContactPhoneNumber'] ?? '不明';
    final String emergencyContactRelationship = _ownerData!['emergencyContactRelationship'] ?? '不明';
    final String stayDurationInJapan = _ownerData!['stayDurationInJapan'] ?? '不明';
    final List<dynamic> selectedLanguages = _ownerData!['selectedLanguages'] ?? [];
    final String currentAddress = _ownerData!['currentAddress'] ?? '不明';
    final String guarantorSupport = _ownerData!['guarantorSupport'] ?? '不明';
    final String initialPaymentMethod = _ownerData!['initialPaymentMethod'] ?? '不明';
    final String contractPeriod = _ownerData!['contractPeriod'] ?? '不明';
    final String screeningLanguageSupport = _ownerData!['screeningLanguageSupport'] ?? '不明';


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'オーナーの個人情報',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 10),
          Text('氏名: $familyName $givenName'),
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
          // 他の個人情報もここに追加
        ],
      ),
    );
  }
}