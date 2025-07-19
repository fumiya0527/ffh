import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Coreをインポート
import 'firebase_options.dart'; // Firebase Optionsをインポート
import 'start.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async { // main関数を非同期にする
  WidgetsFlutterBinding.ensureInitialized(); // Flutterバインディングの初期化を保証

  try {
    await Firebase.initializeApp( // Firebaseを初期化
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // print('Firebase Initialized Successfully!'); // デバッグログは削除済み
  } catch (e) {
    // print('Failed to initialize Firebase: $e'); // デバッグログは削除済み
    // Firebase初期化失敗時のエラーハンドリング（例: ユーザーへの通知）
    // runApp(ErrorApp(errorMessage: 'Firebaseの初期化に失敗しました: $e')); のような対処も可能
  }
  await initializeDateFormatting('ja_JP', null);
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