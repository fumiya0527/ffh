import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 
import 'start.dart';

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

  runApp(const MyApp()); // constを追加
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // const constructor

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
