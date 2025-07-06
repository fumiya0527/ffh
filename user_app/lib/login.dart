import 'package:flutter/material.dart';
import 'package:ffh/user_regist.dart'; // user_regist.dart をインポート
import 'package:ffh/email_verification_screen.dart'; // EmailVerificationScreen をインポート

// LoginChoiceScreen (ログイン選択画面) - UI/UXを大幅に改善
class LoginChoiceScreen extends StatelessWidget {
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
                        MaterialPageRoute(builder: (context) => UserRegistrationScreen()),
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
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),

                // 区切り線
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade400)), // 色を調整
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'または (or)',
                        style: TextStyle(color: Colors.grey[700]), // 色を調整
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade400)), // 色を調整
                  ],
                ),
                const SizedBox(height: 20),

                // ソーシャルログインボタン
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white, // ボタンの背景色
                      foregroundColor: Colors.black87, // テキストとアイコンの色
                      side: BorderSide(color: Colors.grey.shade400), // 枠線の色を調整
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      // TODO: Googleログイン処理
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Googleログインは開発中です (Google login is under development)')),
                      );
                    },
                    icon: Image.network(
                      'https://www.gstatic.com/images/branding/product/1x/google_glogo_color_20dp.png', // Googleロゴ
                      height: 24,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 24), // エラー時のフォールバック
                    ),
                    label: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue with Google',
                          style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Googleで続ける',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white, // ボタンの背景色
                      foregroundColor: Colors.black87, // テキストとアイコンの色
                      side: BorderSide(color: Colors.grey.shade400), // 枠線の色を調整
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      // TODO: Appleログイン処理
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Appleログインは開発中です (Apple login is under development)')),
                      );
                    },
                    icon: const Icon(Icons.apple, size: 24), // Appleロゴ
                    label: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue with Apple',
                          style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Appleで続ける',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

// LoginScreen (ログイン画面) - UIを改善
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
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

  @override
  Widget build(BuildContext context) {
    // アプリ全体で使うメインの色を定義
    final Color mainBackgroundColor = const Color(0xFFEFF7F6); // やさしい背景色
    final Color mainColor = Colors.teal[800]!; // 濃いティール
    final Color secondaryColor = Colors.teal; // 明るいティール

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log in',
              style: TextStyle(fontSize: 14, color: Colors.white70), // 白の薄め
            ),
            const SizedBox(height: 2),
            const Text(
              'ログイン',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: mainColor, // AppBarの色を統一
        foregroundColor: Colors.white, // タイトル色
        centerTitle: false, // タイトルを左寄せに
      ),
      body: Container(
        color: mainBackgroundColor, // 単色背景に統一
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
                      style: TextStyle(fontSize: 16, color: secondaryColor), // サブカラー
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'アカウントにログイン',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: mainColor, // メインカラー
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // メール入力
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'メールアドレス',
                    hintText: '例: your.email@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.email, color: mainColor), // アイコン色もメインカラーに
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  'Email address',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // パスワード入力 + アイコン表示切替
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'パスワード',
                    hintText: 'パスワードを入力してください',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.lock, color: mainColor), // アイコン色もメインカラーに
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

                // パスワードを忘れた方ボタン
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EmailVerificationScreen()),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot password?',
                          style: TextStyle(fontSize: 12, color: secondaryColor.withOpacity(0.8)), // サブカラー
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'パスワードを忘れた方',
                          style: TextStyle(fontSize: 14, color: mainColor, fontWeight: FontWeight.bold), // メインカラー
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // ログインボタン
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor, // メインカラー
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      // TODO: ログイン処理
                      _showMessage('ログイン処理中... (Logging in...)');
                      // 例: ログイン成功後にホーム画面へ遷移
                      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                    },
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
  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
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

  void _sendVerificationCode() {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showMessage('有効なメールアドレスを入力してください (Please enter a valid email address)');
      return;
    }

    // TODO: 実際はここで認証コードを送信（API呼び出しなど）
    _showMessage('認証コードを $email に送りました (Verification code sent to $email)');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CodeInputScreen(email: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // アプリ全体で使うメインの色を定義
    final Color mainBackgroundColor = const Color(0xFFEFF7F6); // やさしい背景色
    final Color mainColor = Colors.teal[800]!; // 濃いティール
    final Color secondaryColor = Colors.teal; // 明るいティール

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
        color: mainBackgroundColor, // 単色背景に統一
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
                  onPressed: _sendVerificationCode,
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

// CodeInputScreen (認証コード入力画面) - UIを改善
class CodeInputScreen extends StatefulWidget {
  final String email;

  CodeInputScreen({required this.email});

  @override
  _CodeInputScreenState createState() => _CodeInputScreenState();
}

class _CodeInputScreenState extends State<CodeInputScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _verifyCode() {
    final code = _codeController.text.trim();

    if (code == '1111') { // 仮の認証コード
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(),
        ),
      );
    } else {
      _showMessage('認証コードが違います (Incorrect verification code)');
    }
  }

  @override
  Widget build(BuildContext context) {
    // アプリ全体で使うメインの色を定義
    final Color mainBackgroundColor = const Color(0xFFEFF7F6); // やさしい背景色
    final Color mainColor = Colors.teal[800]!; // 濃いティール
    final Color secondaryColor = Colors.teal; // 明るいティール

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter verification code',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 2),
            const Text(
              '認証コード入力',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: Container(
        color: mainBackgroundColor, // 単色背景に統一
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'Please enter the verification code sent to your email',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'メールに送られた認証コードを入力してください',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'メールアドレス: ${widget.email}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '認証コード',
                  hintText: '例: 123456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.vpn_key, color: mainColor),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                'Verification code',
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
                  onPressed: _verifyCode,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Verify',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '認証する',
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

// ResetPasswordScreen (パスワード再設定画面) - UIを改善
class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
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
      Navigator.popUntil(context, (route) => route.isFirst); // ログイン選択画面まで戻る
    }
  }

  @override
  Widget build(BuildContext context) {
    // アプリ全体で使うメインの色を定義
    final Color mainBackgroundColor = const Color(0xFFEFF7F6); // やさしい背景色
    final Color mainColor = Colors.teal[800]!; // 濃いティール
    final Color secondaryColor = Colors.teal; // 明るいティール

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
        color: mainBackgroundColor, // 単色背景に統一
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

                // 新しいパスワード入力欄
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

                // 新しいパスワード（確認）
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: '新しいパスワード（確認）',
                    hintText: 'もう一度入力してください',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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