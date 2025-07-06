import 'package:flutter/material.dart';
import 'email_verification_screen.dart';
import 'start.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'For foreign home',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartScreen(),
    );
  }
}

// class LoginChoiceScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center( // ← ここで Column 全体を中央に配置
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min, // ← 内容サイズに合わせて縮める
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   'Welcome For foreign home',
//                   style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 60),
//                 ElevatedButton(
//                   child: Text('はじめての方'),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => UserRegistrationScreen()),
//                     );
//                   },
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   child: Text('登録済みの方'),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => LoginScreen()),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// /* ↓↓↓アプリを分ける方向性に変更したためユーザーとオーナー選択画面は削除↓↓↓
// class SignUpScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;

//     final buttonSize = screenWidth * 0.25; // 少し小さめに

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('新規登録'),
//       ),
//       body: Stack(
//         children: [
//           // タイトル
//           Positioned(
//             top: screenHeight * 0.12,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Text(
//                 'your position',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),

//           // Orner ボタン（左下寄りに上げた位置）
//           Positioned(
//             left: screenWidth * 0.25 - buttonSize / 2,
//             top: screenHeight * 0.30,
//             child: SizedBox(
//               width: buttonSize,
//               height: buttonSize,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => OrnerScreen()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   'orner',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Player ボタン（右下寄りに上げた位置）
//           Positioned(
//             left: screenWidth * 0.75 - buttonSize / 2,
//             top: screenHeight * 0.30,
//             child: SizedBox(
//               width: buttonSize,
//               height: buttonSize,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => UserRegistrationScreen()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   'player',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// */

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('ログイン'),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // メール入力
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'メールアドレス',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 20),

//               // パスワード入力 + アイコン表示切替
//               TextField(
//                 controller: _passwordController,
//                 obscureText: _obscurePassword,
//                 decoration: InputDecoration(
//                   labelText: 'パスワード',
//                   border: OutlineInputBorder(),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10),

//               // パスワードを忘れた方ボタン（小さめ）
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: _navigateToResetFlow, // ← ここが今回の変更ポイント！
//                   child: Text(
//                     'パスワードを忘れてしまった方',
//                     style: TextStyle(fontSize: 14),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),

//               // ログインボタン
//               ElevatedButton(
//                 onPressed: () {
//                   // ログイン処理（仮）
//                   print('ログイン処理');
//                 },
//                 child: Text('ログイン'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // 変更点：このメソッドで認証コード送信画面へ遷移
//   void _navigateToResetFlow() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => EmailVerificationScreen()),
//     );
//   }
// }



// class ResetPasswordScreen extends StatefulWidget {
//   @override
//   _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   bool _obscureNewPassword = true;
//   bool _obscureConfirmPassword = true;

//   @override
//   void dispose() {
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   void _handleReset() {
//     final newPassword = _newPasswordController.text;
//     final confirmPassword = _confirmPasswordController.text;

//     if (newPassword.isEmpty || confirmPassword.isEmpty) {
//       _showMessage('すべての項目を入力してください');
//     } else if (newPassword != confirmPassword) {
//       _showMessage('パスワードが一致しません');
//     } else {
//       _showMessage('パスワードをリセットしました');
//       Navigator.pop(context);
//     }
//   }

//   void _showMessage(String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('OK'),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('パスワード再設定'),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // 新しいパスワード入力欄
//               TextField(
//                 controller: _newPasswordController,
//                 obscureText: _obscureNewPassword,
//                 decoration: InputDecoration(
//                   labelText: '新しいパスワード',
//                   border: OutlineInputBorder(),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscureNewPassword
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscureNewPassword = !_obscureNewPassword;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),

//               // 新しいパスワード（確認）
//               TextField(
//                 controller: _confirmPasswordController,
//                 obscureText: _obscureConfirmPassword,
//                 decoration: InputDecoration(
//                   labelText: '新しいパスワード（確認）',
//                   border: OutlineInputBorder(),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscureConfirmPassword
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscureConfirmPassword = !_obscureConfirmPassword;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(height: 30),

//               ElevatedButton(
//                 onPressed: _handleReset,
//                 child: Text('パスワードを再設定'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// class EmailVerificationScreen extends StatefulWidget {
//   @override
//   _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
// }

// class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
//   final _emailController = TextEditingController();

//   void _sendVerificationCode() {
//     final email = _emailController.text;

//     if (email.isEmpty || !email.contains('@')) {
//       _showMessage('有効なメールアドレスを入力してください');
//       return;
//     }

//     // TODO: 実際はここで認証コードを送信（API呼び出しなど）
//     print('認証コードを $email に送信しました');

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CodeInputScreen(email: email),
//       ),
//     );
//   }

//   void _showMessage(String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         content: Text(message),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('認証コード送信')),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(
//                 labelText: 'メールアドレス',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _sendVerificationCode,
//               child: Text('認証コードを送信'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// class CodeInputScreen extends StatefulWidget {
//   final String email;

//   CodeInputScreen({required this.email});

//   @override
//   _CodeInputScreenState createState() => _CodeInputScreenState();
// }

// class _CodeInputScreenState extends State<CodeInputScreen> {
//   final TextEditingController _codeController = TextEditingController();

//   void _verifyCode() {
//     final code = _codeController.text.trim();

//     if (code == '1111') {
//       // 成功：パスワード再設定画面へ遷移
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ResetPasswordScreen(),
//         ),
//       );
//     } else {
//       // 失敗：ダイアログでエラーメッセージ表示
//       _showMessage('認証コードが間違っています');
//     }
//   }

//   void _showMessage(String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('認証コード入力')),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('メールアドレス: ${widget.email}'),
//             SizedBox(height: 20),
//             TextField(
//               controller: _codeController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: '認証コード',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _verifyCode,
//               child: Text('認証する'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

<<<<<<< HEAD
/* ↓↓↓アプリを分ける方向性に変更したためユーザーとオーナー選択画面は削除↓↓↓
class OrnerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orner画面'),
      ),
      body: Center(
        child: Text('これは Orner 用の画面です'),
      ),
    );
  }
}
*/
=======

// class OrnerScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Orner画面'),
//       ),
//       body: Center(
//         child: Text('これは Orner 用の画面です'),
//       ),
//     );
//   }
// }
>>>>>>> 8671e466f74afdad56319bb496f70e08eead005a
