import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ffh/user_regist.dart';
import 'house_select.dart';
import 'manner.dart';
import 'quiz_question.dart';

class LoginChoiceScreen extends StatelessWidget {
  const LoginChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // アプリ全体で使うメインの色を定義
    final Color mainBackgroundColor = const Color(0xFFEFF7F6); // やさしい背景色
    final Color mainColor = Colors.teal[800]!; // 濃いティール
    final Color secondaryColor = Colors.teal; // 明るいティール

    return Scaffold(
      backgroundColor: mainBackgroundColor, // 背景色を統一
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView( // 画面サイズが小さい場合にスクロール可能にする
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // アプリのロゴやアイコン (仮のアイコンを使用)
                Icon(
                  Icons.home_work_rounded, // 家と仕事のアイコン
                  size: 100,
                  color: mainColor, // メインカラーに合わせる
                ),
                const SizedBox(height: 20),

                // ウェルカムメッセージとアプリ名
                Column(
                  children: [
                    Text(
                      'Welcome', // 英語を上に小さく
                      style: TextStyle(
                        fontSize: 18,
                        color: mainColor.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ようこそ', // 優しい日本語を大きく
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    Text(
                      'Find your new life', // 英語を上に小さく
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryColor, // サブカラー
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'あなたの新しい暮らしを見つけよう', // 優しい日本語を大きく
                      style: TextStyle(
                        fontSize: 20,
                        color: mainColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                // 「はじめての方」ボタン
                SizedBox(
                  width: double.infinity, // 幅を最大にする
                  height: 55, // 高さを少し大きくする
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor, // ボタンの背景色をメインカラーに
                      foregroundColor: Colors.white, // ボタンのテキスト色
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // より丸い角
                      ),
                      elevation: 5, // 影を追加
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'First-time user', // 英語を上に小さく
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'はじめての方', // 優しい日本語を大きく
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  UserRegistrationScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // 「登録済みの方」ボタン
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor, // ボタンの背景色をメインカラーに
                      foregroundColor: Colors.white, // ボタンのテキスト色
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Registered user', // 英語を上に小さく
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '登録済みの方', // 優しい日本語を大きく
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                ),
                // ▼▼▼ ソーシャルログイン関連のUIをここから削除 ▼▼▼
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// LoginScreen (ログイン画面) - UIを改善
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loginUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      _showMessage('ログインしました！ (Logged in successfully!)');

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HouseSelectScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'ユーザーが見つかりません。 (No user found for that email.)';
      } else if (e.code == 'wrong-password') {
        message = 'パスワードが間違っています。 (Wrong password provided for that user.)';
      } else if (e.code == 'invalid-email') {
        message = 'メールアドレスの形式が正しくありません。 (The email address is not valid.)';
      } else {
        message = 'ログインに失敗しました: ${e.message ?? '不明なエラー'} (Login failed: ${e.message ?? 'Unknown error'})';
      }
      _showMessage(message);
    } catch (e) {
      _showMessage('エラーが発生しました: ${e.toString()} (An error occurred: ${e.toString()})');
    }
  }


  @override
  Widget build(BuildContext context) {
    final Color mainBackgroundColor = const Color(0xFFEFF7F6);
    final Color mainColor = Colors.teal[800]!;
    final Color secondaryColor = Colors.teal;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log in',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 2),
            const Text(
              'ログイン',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: Container(
        color: mainBackgroundColor,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Log in to your account',
                      style: TextStyle(fontSize: 16, color: secondaryColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'アカウントにログイン',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'メールアドレス',
                    hintText: '例: your.email@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.email, color: mainColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  'Email address',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'パスワード',
                    hintText: 'パスワードを入力してください',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.lock, color: mainColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  'Password',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 15),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EmailVerificationScreen()),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot password?',
                          style: TextStyle(fontSize: 12, color: secondaryColor.withOpacity(0.8)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'パスワードを忘れた方',
                          style: TextStyle(fontSize: 14, color: mainColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    onPressed: _loginUser,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Log in',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'ログイン',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// EmailVerificationScreen (メール認証コード送信画面) - UIを改善
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showMessage('有効なメールアドレスを入力してください (Please enter a valid email address)');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessage('パスワードリセットのメールを送信しました。ご確認ください。 (Password reset email sent. Please check your inbox.)');
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'このメールアドレスを持つユーザーは見つかりません。 (No user found for that email.)';
      } else if (e.code == 'invalid-email') {
        message = 'メールアドレスの形式が正しくありません。 (The email address is not valid.)';
      } else {
        message = 'パスワードリセットメールの送信に失敗しました: ${e.message ?? '不明なエラー'} (Failed to send password reset email: ${e.message ?? 'Unknown error'})';
      }
      _showMessage(message);
    } catch (e) {
      _showMessage('エラーが発生しました: ${e.toString()} (An error occurred: ${e.toString()})');
    }
  }


  @override
  Widget build(BuildContext context) {
    final Color mainBackgroundColor = const Color(0xFFEFF7F6);
    final Color mainColor = Colors.teal[800]!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send verification code',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 2),
            const Text(
              '認証コードを送る',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: Container(
        color: mainBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'Enter your email to reset your password',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'パスワードをリセットするために、\nメールアドレスを入力してください',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'メールアドレス',
                  hintText: '例: your.email@example.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.email, color: mainColor),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                'Email address',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _sendPasswordResetEmail,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Send code',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '認証コードを送る',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleReset() {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage('すべての項目を入力してください (Please enter all fields)');
    } else if (newPassword != confirmPassword) {
      _showMessage('パスワードが一致しません (Passwords do not match)');
    } else {
      _showMessage('パスワードを再設定しました (Password reset successful)');
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainBackgroundColor = const Color(0xFFEFF7F6);
    final Color mainColor = Colors.teal[800]!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reset password',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 2),
            const Text(
              'パスワードを再設定',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: Container(
        color: mainBackgroundColor,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Text(
                      'Please set your new password',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '新しいパスワードを設定してください',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                TextField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: '新しいパスワード',
                    hintText: '6文字以上で入力してください',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.lock_open, color: mainColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  'New password',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),
                
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: '新しいパスワード（確認）',
                    hintText: 'もう一度入力してください',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.lock_reset, color: mainColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  'Confirm new password',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    onPressed: _handleReset,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Reset password',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'パスワードを再設定する',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
