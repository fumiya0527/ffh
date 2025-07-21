import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'start.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase初期化失敗時のエラーハンドリング
  }
  
  await initializeDateFormatting('ja_JP', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainBackgroundColor = Color(0xFFEFF7F6);
    final Color mainColor = Colors.teal[800]!;

    return MaterialApp(
      title: 'For foreigner home',
      theme: ThemeData(
        // --- 基本設定 ---
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: mainBackgroundColor,
        
        // --- フォント設定 ---
        textTheme: GoogleFonts.notoSansJpTextTheme(
          Theme.of(context).textTheme,
        ),
        
        // --- 各ウィジェットの共通デザイン ---
        appBarTheme: AppBarTheme(
          backgroundColor: mainColor,
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 6),
        ),

        // ▼▼▼ ここが最重要ポイント ▼▼▼
        // アプリ内の全てのElevatedButtonの基本デザインをここで定義
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor, // ボタンの背景色をティール系に強制
            foregroundColor: Colors.white, // 文字色を白に
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // 丸い角
            ),
            elevation: 5,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const StartScreen(),
    );
  }
}