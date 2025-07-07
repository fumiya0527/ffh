import 'package:flutter/material.dart';
import 'start.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'For foreigner home', // アプリのタイトル
      theme: ThemeData(
        primarySwatch: Colors.teal, // テーマのプライマリーカラーをティール系に
      ),
      home: const StartScreen(), 
    );
  }
}

//↓user_conditionだけを開きたいときここより上をコメントアウトして下を使う↓

// import 'package:flutter/material.dart';
// import 'user_condition.dart'; // UserCondition へのパスをインポート
// // import 'package:your_app_name/user_regist.dart'; // user_regist を使わない場合はコメントアウト

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '利用条件デモ', // タイトルを適切に修正
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const UserCondition( // ★ここを UserCondition に変更
//         // UserCondition ウィジェットの必須パラメータをダミーデータで渡す
//         name: 'テスト ユーザー',
//         birthdate: '1990/01/01',
//         email: 'test@example.com',
//         password: 'password123',
//         nationality: '日本 (Japan)',
//         phoneNumber: '090-1234-5678',
//         residenceStatus: '', // 日本国籍の場合など、空文字列でOK
//         residenceCardNumber: '', // 同上
//         emergencyContactName: '緊急連絡先',
//         emergencyContactPhoneNumber: '090-9876-5432',
//         emergencyContactRelationship: 'その他 (Other)',
//         stayDurationInJapan: '', // 同上
//       ),
//     );
//   }
// }