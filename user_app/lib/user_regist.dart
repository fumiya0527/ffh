import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:intl/intl.dart';
import 'user_condition.dart'; // UserCondition へのパス
import 'terms_of_service.dart'; // terms_of_service.dart へのパス
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRegistrationScreen extends StatefulWidget {
  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  String _familyName = ''; // 苗字を追加
  String _givenName = ''; // 名前を追加
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _nationality = '日本 (Japan)'; // 初期値を「日本 (Japan)」に設定し、英語併記
  DateTime? _birthDate;
  List<String> _selectedLanguages = [];
  String _currentAddress = '';
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // 追加情報のための変数
  String _phoneNumber = '';
  String? _residenceStatus; // 在留資格
  String _residenceCardNumber = ''; // 在留カード番号
  String _emergencyContactName = '';
  String _emergencyContactPhoneNumber = '';
  String? _emergencyContactRelationship; // 続柄
  String? _stayDurationInJapan; // 日本での滞在期間

  // 国籍が日本かどうかを判定するフラグ
  bool _isJapanese = true; // 初期値は「日本 (Japan)」なのでtrue

  // ★修正点: これらの変数を build メソッドの外（クラスのインスタンス変数）に移動します。
  //          これで setState が適切に値を更新し、保存時に正しい値が参照されます。
  String? _guarantorSupport; // 保証人/保証会社サポート
  String? _initialPaymentMethod; // 初期費用の支払い方法
  String? _contractPeriod; // 契約期間
  String? _screeningLanguageSupport; // 入居審査の言語サポート


  final List<String> nationalities = [
    '日本 (Japan)',
    'アメリカ (USA)',
    'イギリス (UK)',
    'カナダ (Canada)',
    'オーストラリア (Australia)',
    '中国 (China)',
    '韓国 (South Korea)',
    'ベトナム (Vietnam)',
    'フィリピン (Philippines)',
    'インドネシア (Indonesia)',
    'フランス (France)',
    'ドイツ (Germany)',
    'スペイン (Spain)',
    'ブラジル (Brazil)',
    'インド (India)',
    'タイ (Thailand)',
    'ネパール (Nepal)',
    'バングラデシュ (Bangladesh)',
    'マレーシア (Malaysia)',
    'その他 (Other)'
  ];

  final List<String> languages = [
    '日本語 (Japanese)',
    '英語 (English)',
    '中国語 (Chinese)',
    '韓国語 (Korean)',
    'スペイン語 (Spanish)',
    'フランス語 (French)',
    'ベトナム語 (Vietnamese)',
    'その他 (Other)'
  ];

  // 在留資格の選択肢 (日本語 (English) 形式)
  final List<String> residenceStatuses = [
    '永住者 (Permanent Resident)',
    '日本人の配偶者等 (Spouse or Child of Japanese National)',
    '定住者 (Long-Term Resident)',
    '技術・人文知識・国際業務 (Engineer/Specialist in Humanities/International Services)',
    '留学 (Student)',
    '技能実習 (Technical Intern Training)',
    '特定技能 (Specified Skilled Worker)',
    '家族滞在 (Dependent)',
    'その他 (Other)'
  ];

  // 続柄の選択肢 (日本語 (English) 形式)
  final List<String> relationships = [
    '親 (Parent)',
    '兄弟 (Sibling)',
    '友人 (Friend)',
    'その他 (Other)'
  ];

  // 日本での滞在期間の選択肢 (日本語 (English) 形式)
  final List<String> stayDurations = [
    '1年未満 (Less than 1 year)',
    '1〜3年 (1-3 years)',
    '3〜5年 (3-5 years)',
    '5年以上 (More than 5 years)',
    '永住 (Permanent)'
  ];

  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedDay;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<int> _years = List.generate(126, (index) => 1900 + index);
  final List<int> _months = List.generate(12, (index) => index + 1);
  List<int> get _daysInMonth {
    if (_selectedYear != null && _selectedMonth != null) {
      final lastDay = DateTime(_selectedYear!, _selectedMonth! + 1, 0).day;
      return List.generate(lastDay, (index) => index + 1);
    }
    return List.generate(31, (index) => index + 1);
  }

  void _updateBirthDate() {
    if (_selectedYear != null && _selectedMonth != null && _selectedDay != null) {
      _birthDate = DateTime(_selectedYear!, _selectedMonth!, _selectedDay!);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // 利用規約をダイアログで表示する関数
  void _showTermsOfServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('利用規約'),
          content: SizedBox(
            width: double.maxFinite, // ダイアログの幅を最大にする
            height: MediaQuery.of(context).size.height * 0.7, // 画面の高さの70%を使う
            child: SingleChildScrollView(
              // 利用規約が長い場合にスクロールできるようにする
              child: Text(termsOfServiceText), // termsOfService.dart からインポートしたテキスト
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('閉じる'),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color mainBackgroundColor = const Color(0xFFEFF7F6);
    final Color mainColor = Colors.teal[800]!;
    final Color secondaryColor = Colors.teal;

    // ★修正点: build メソッド内のローカル変数宣言を削除
    // String? _guarantorSupport;
    // String? _initialPaymentMethod;
    // String? _contractPeriod;
    // String? _screeningLanguageSupport;

    final List<String> guarantorOptions = [
      '不要 (Not required)',
      '保証会社利用可 (Guarantor company available)',
      '保証人必須 (Guarantor required)'
    ];
    final List<String> paymentMethodOptions = [
      '現金 (Cash)',
      'クレジットカード (Credit Card)',
      '銀行振込 (Bank Transfer)',
      'その他 (Other)'
    ];
    final List<String> contractPeriodOptions = [
      '1年未満 (Less than 1 year)',
      '1年 (1 year)',
      '2年 (2 years)',
      '2年以上 (More than 2 years)'
    ];

    final List<String> screeningLanguageOptions = [
      '日本語のみ (Japanese only)',
      '英語対応 (English support)',
      'その他言語対応 (Other languages support)'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Registration',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 2),
            const Text(
              'ユーザー登録',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Text(
                      'Create your account',
                      style: TextStyle(fontSize: 16, color: secondaryColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'アカウントを作成',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // 苗字
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '姓',
                    hintText: '例: 岡本 (Okamoto)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.person, color: mainColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  onChanged: (val) => _familyName = val,
                  validator: (val) =>
                      val!.isEmpty ? '苗字を入力してください (Please enter your First Name)' : null,
                ),
                Text(
                  'First Name',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // 名前
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '名',
                    hintText: '例: 寿基 (Kazuki)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.person_outline, color: mainColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  onChanged: (val) => _givenName = val,
                  validator: (val) =>
                      val!.isEmpty ? '名前を入力してください (Please enter your Last Name)' : null,
                ),
                Text(
                  'Last Name',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // 生年月日選択
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date of Birth',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey.shade700.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '生年月日',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: '年',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                        ),
                        value: _selectedYear,
                        items: _years
                            .map((y) => DropdownMenuItem(value: y, child: Text('$y年')))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedYear = val;
                            _updateBirthDate();
                          });
                        },
                        validator: (val) =>
                            val == null ? '年を選んでください (Please select a year)' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: '月',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                        ),
                        value: _selectedMonth,
                        items: _months
                            .map((m) => DropdownMenuItem(value: m, child: Text('$m月')))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedMonth = val;
                            _updateBirthDate();
                          });
                        },
                        validator: (val) =>
                            val == null ? '月を選んでください (Please select a month)' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: '日',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                        ),
                        value: _selectedDay,
                        items: _daysInMonth
                            .map((d) => DropdownMenuItem(value: d, child: Text('$d日')))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedDay = val;
                            _updateBirthDate();
                          });
                        },
                        validator: (val) =>
                            val == null ? '日を選んでください (Please select a day)' : null,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Year / Month / Day',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // 国籍選択
                DropdownButtonFormField<String>(
                  value: _nationality,
                  items: nationalities
                      .map((nation) => DropdownMenuItem(value: nation, child: Text(nation)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _nationality = val!;
                      _isJapanese = (val == '日本 (Japan)');
                      if (!_isJapanese) {
                        _residenceStatus = null;
                        _residenceCardNumber = '';
                        _stayDurationInJapan = null;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    labelText: '国籍',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.public, color: mainColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  'Nationality',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // 話せる言語選択
                MultiSelectDialogField<String>(
                  items: languages.map((lang) => MultiSelectItem(lang, lang)).toList(),
                  title: const Text("話せる言語を選んでください (Select languages you speak)"),
                  buttonText: const Text("言語"),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.9),
                  ),
                  buttonIcon: Icon(Icons.language, color: mainColor),
                  onConfirm: (values) => _selectedLanguages = values,
                  validator: (values) =>
                      values == null || values.isEmpty ? '言語を選択してください (Select language)' : null,
                ),
                Text(
                  'Languages you speak',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // メールアドレス
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'メールアドレス',
                    hintText: '例: your.email@example.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.email, color: mainColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) => _email = val,
                  validator: (val) =>
                      !val!.contains('@') ? '正しいメール形式で入力してください (Please enter a valid email format)' : null,
                ),
                Text(
                  'Email address',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // パスワード
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'パスワード',
                    hintText: '6文字以上で入力してください',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  obscureText: _obscurePassword,
                  onChanged: (val) => _password = val,
                  validator: (val) =>
                      val!.length < 6 ? '6文字以上必要です (Needs 6 or more characters)' : null,
                ),
                Text(
                  'Password',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // パスワード（確認）
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'パスワード（確認）',
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
                  obscureText: _obscureConfirmPassword,
                  onChanged: (val) => _confirmPassword = val,
                  validator: (val) => val != _password ? 'パスワードが一致しません (Passwords do not match)' : null,
                ),
                Text(
                  'Confirm password',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // 電話番号 (日本人でも必要なので常に表示)
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '電話番号',
                    hintText: '例: 090-1234-5678',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.phone, color: mainColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (val) => _phoneNumber = val,
                  validator: (val) =>
                      val!.isEmpty ? '電話番号を入力してください (Please enter your phone number)' : null,
                ),
                Text(
                  'Phone Number',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // 在留資格 (外国人向け：_isJapaneseがfalseの場合のみ表示)
                if (!_isJapanese) ...[
                  DropdownButtonFormField<String>(
                    value: _residenceStatus,
                    items: residenceStatuses
                        .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                        .toList(),
                    onChanged: (val) => setState(() => _residenceStatus = val!),
                    decoration: InputDecoration(
                      labelText: '在留資格',
                      hintText: '選んでください',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.badge, color: mainColor),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? '在留資格を選んでください (Please select your residence status)'
                        : null,
                  ),
                  Text(
                    'Residence Status',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),
                ],

                // 在留カード番号 (外国人向け：_isJapaneseがfalseの場合のみ表示)
                if (!_isJapanese) ...[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '在留カード番号',
                      hintText: '例: AB12345678CD',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.credit_card, color: mainColor),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                    onChanged: (val) => _residenceCardNumber = val,
                    validator: (val) => val!.isEmpty
                        ? '在留カード番号を入力してください (Please enter your residence card number)'
                        : null,
                  ),
                  Text(
                    'Residence Card Number',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),
                ],

                // 日本での滞在期間 (外国人向け：_isJapaneseがfalseの場合のみ表示)
                if (!_isJapanese) ...[
                  DropdownButtonFormField<String>(
                    value: _stayDurationInJapan,
                    items: stayDurations
                        .map((duration) => DropdownMenuItem(value: duration, child: Text(duration)))
                        .toList(),
                    onChanged: (val) => setState(() => _stayDurationInJapan = val!),
                    decoration: InputDecoration(
                      labelText: '日本での滞在期間',
                      hintText: '選んでください',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.calendar_month, color: mainColor),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? '日本での滞在期間を選んでください (Please select your duration of stay in Japan)'
                        : null,
                  ),
                  Text(
                    'Duration of stay in Japan',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),
                ],

                // 現在の住所 (日本人でも必要なので常に表示)
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '今の住所',
                    hintText: '例: 東京都新宿区〇〇',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.location_on, color: mainColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  onChanged: (val) => _currentAddress = val,
                  validator: (val) =>
                      val!.isEmpty ? '今の住所を入力してください (Please enter your current address)' : null,
                ),
                Text(
                  'Current Address',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // 緊急連絡先 (日本人でも必要なので常に表示)
                Text(
                  '緊急連絡先',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                Text(
                  'Emergency Contact',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '氏名',
                    hintText: '例: 山田 花子',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.person_outline, color: mainColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  onChanged: (val) => _emergencyContactName = val,
                  validator: (val) =>
                      val!.isEmpty ? '緊急連絡先の氏名を入力してください (Please enter emergency contact name)' : null,
                ),
                Text(
                  'Name',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '電話番号',
                    hintText: '例: 090-9876-5432',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.phone_android, color: mainColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (val) => _emergencyContactPhoneNumber = val,
                  validator: (val) => val!.isEmpty
                      ? '緊急連絡先の電話番号を入力してください (Please enter emergency contact phone number)'
                      : null,
                ),
                Text(
                  'Phone Number',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _emergencyContactRelationship,
                  items: relationships
                      .map((rel) => DropdownMenuItem(value: rel, child: Text(rel)))
                      .toList(),
                  onChanged: (val) => setState(() => _emergencyContactRelationship = val!),
                  decoration: InputDecoration(
                    labelText: '連絡先の方との関係',
                    hintText: '選んでください',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.family_restroom, color: mainColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? '緊急連絡先の方との関係を選んでください (Please select emergency contact relationship)'
                      : null,
                ),
                Text(
                  'Relationship with contact person',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 30),

                // 契約・入居に関する条件 (UserRegistrationScreenで入力する内容)
                // ★修正点: _buildSectionTitle と以下の各 DropdownButtonFormField もインスタンス変数を更新するようにします。
                _buildSectionTitle('Contract & Move-in Conditions', '契約・入居に関する条件', mainColor, secondaryColor),
                const SizedBox(height: 15),
                _buildSubSectionTitle('Guarantor / Guarantor Company Support', '保証人 / 保証会社サポート'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _guarantorSupport,
                  items: guarantorOptions,
                  // ★修正点: setState でインスタンス変数を更新
                  onChanged: (val) => setState(() => _guarantorSupport = val!),
                  labelText: '選んでください',
                  icon: Icons.security,
                  mainColor: mainColor,
                ),
                const SizedBox(height: 20),
                _buildSubSectionTitle('Initial Payment Method', '初期費用の支払い方法'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _initialPaymentMethod,
                  items: paymentMethodOptions,
                  // ★修正点: setState でインスタンス変数を更新
                  onChanged: (val) => setState(() => _initialPaymentMethod = val!),
                  labelText: '選んでください',
                  icon: Icons.payment,
                  mainColor: mainColor,
                ),
                const SizedBox(height: 20),
                _buildSubSectionTitle('Contract Period', '契約期間'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _contractPeriod,
                  items: contractPeriodOptions,
                  // ★修正点: setState でインスタンス変数を更新
                  onChanged: (val) => setState(() => _contractPeriod = val!),
                  labelText: '選んでください',
                  icon: Icons.calendar_today,
                  mainColor: mainColor,
                ),
                const SizedBox(height: 20),
                _buildSubSectionTitle('Screening Language Support', '入居審査の言語サポート'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _screeningLanguageSupport,
                  items: screeningLanguageOptions,
                  // ★修正点: setState でインスタンス変数を更新
                  onChanged: (val) => setState(() => _screeningLanguageSupport = val!),
                  labelText: '選んでください',
                  icon: Icons.translate,
                  mainColor: mainColor,
                ),
                const SizedBox(height: 40),

                // 利用規約を見るボタン
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      _showTermsOfServiceDialog(context);
                    },
                    child: Text(
                      '利用規約を見る (View Terms and Conditions)',
                      style: TextStyle(color: secondaryColor, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 利用規約同意チェックボックス
                CheckboxListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agree to Terms and Conditions',
                        style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '利用規約に同意します',
                        style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  value: _agreeToTerms,
                  onChanged: (val) => setState(() => _agreeToTerms = val ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: mainColor,
                ),
                if (!_agreeToTerms && _formKey.currentState?.validate() == true)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      '利用規約に同意してください (Please agree to the terms and conditions)',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 30),

                // 次へボタン
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && _agreeToTerms) {
                        if (_birthDate == null) {
                          _showMessage('生年月日を全て選択してください (Please select your full birth date)');
                          return;
                        }

                        final String formattedBirthdate = DateFormat('yyyy/MM/dd').format(_birthDate!);
                        final String finalResidenceStatus = _isJapanese ? '' : (_residenceStatus ?? '');
                        final String finalResidenceCardNumber = _isJapanese ? '' : _residenceCardNumber;
                        final String finalStayDurationInJapan =
                            _isJapanese ? '' : (_stayDurationInJapan ?? '');

                        if (!_isJapanese && (finalResidenceStatus.isEmpty || finalResidenceCardNumber.isEmpty || finalStayDurationInJapan.isEmpty)) {
                          _showMessage('外国籍の方は在留資格、在留カード番号、日本での滞在期間を全て入力してください (Foreign nationals must fill in residence status, residence card number, and duration of stay in Japan)');
                          return;
                        }
                        
                        if (_selectedLanguages.isEmpty) {
                          _showMessage('話せる言語を一つ以上選択してください (Please select at least one language you speak)');
                          return;
                        }

                        if (_emergencyContactName.isEmpty || _emergencyContactPhoneNumber.isEmpty || _emergencyContactRelationship == null || _emergencyContactRelationship!.isEmpty) {
                          _showMessage('緊急連絡先の情報を全て入力してください (Please fill in all emergency contact details)');
                          return;
                        }
                        
                        // ★修正点: 契約・入居に関する条件の必須バリデーションを追加
                        if (_guarantorSupport == null || _guarantorSupport!.isEmpty ||
                            _initialPaymentMethod == null || _initialPaymentMethod!.isEmpty ||
                            _contractPeriod == null || _contractPeriod!.isEmpty ||
                            _screeningLanguageSupport == null || _screeningLanguageSupport!.isEmpty) {
                            _showMessage('契約・入居に関する条件を全て入力してください (Please fill in all contract and move-in conditions).');
                            return;
                        }


                        try {
                          // 1. Firebase Authenticationでユーザーを登録
                          UserCredential userCredential =
                              await _auth.createUserWithEmailAndPassword(
                            email: _email,
                            password: _password,
                          );

                          String uid = userCredential.user!.uid;

                          await _firestore.collection('user_ID').doc(uid).set({
                            'familyName': _familyName,
                            'givenName': _givenName,
                            'email': _email,
                            'nationality': _nationality,
                            'birthDate': formattedBirthdate,
                            'selectedLanguages': _selectedLanguages,
                            'currentAddress': _currentAddress,
                            'phoneNumber': _phoneNumber,
                            'residenceStatus': finalResidenceStatus,
                            'residenceCardNumber': finalResidenceCardNumber,
                            'emergencyContactName': _emergencyContactName,
                            'emergencyContactPhoneNumber': _emergencyContactPhoneNumber,
                            'emergencyContactRelationship': _emergencyContactRelationship,
                            'stayDurationInJapan': finalStayDurationInJapan,
                            'guarantorSupport': _guarantorSupport,
                            'initialPaymentMethod': _initialPaymentMethod,
                            'contractPeriod': _contractPeriod,
                            'screeningLanguageSupport': _screeningLanguageSupport,
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          _showMessage('ユーザー登録が完了しました！ (User registration complete!)');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserCondition(
                                name: '$_familyName $_givenName',
                                birthdate: formattedBirthdate,
                                email: _email,
                                nationality: _nationality,
                                phoneNumber: _phoneNumber,
                                residenceStatus: finalResidenceStatus,
                                residenceCardNumber: finalResidenceCardNumber,
                                emergencyContactName: _emergencyContactName,
                                emergencyContactPhoneNumber: _emergencyContactPhoneNumber,
                                emergencyContactRelationship: _emergencyContactRelationship!,
                                stayDurationInJapan: finalStayDurationInJapan,
                                userUid: uid, // ★生成されたUIDを UserCondition に渡す
                              ),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          String errorMessage =
                              '登録に失敗しました。もう一度お試しください。 (Registration failed. Please try again.)';
                          if (e.code == 'weak-password') {
                            errorMessage = 'パスワードが弱すぎます。 (The password provided is too weak.)';
                          } else if (e.code == 'email-already-in-use') {
                            errorMessage = 'このメールアドレスは既に使用されています。 (The account already exists for that email.)';
                          } else if (e.code == 'invalid-email') {
                            errorMessage = 'メールアドレスの形式が正しくありません。 (The email address is not valid.)';
                          }
                          _showMessage(errorMessage);
                        } catch (e) {
                          _showMessage('エラーが発生しました: ${e.toString()} (An error occurred: ${e.toString()})');
                        }
                      } else {
                        _showMessage(
                            '入力にエラーがあります。全ての項目を正しく入力し、利用規約に同意してください。 (There are errors in the input. Please fill in all fields correctly and agree to the terms of use.)');
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Next',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '次へ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildSectionTitle(
      String englishTitle, String japaneseTitle, Color mainColor, Color secondaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          englishTitle,
          style: TextStyle(fontSize: 18, color: secondaryColor, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          japaneseTitle,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: mainColor),
        ),
        const Divider(height: 20, thickness: 1, color: Colors.grey),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSubSectionTitle(String englishTitle, String japaneseTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          englishTitle,
          style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
        ),
        const SizedBox(height: 2),
        Text(
          japaneseTitle,
          style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDropdownFormField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String labelText,
    required IconData icon,
    required Color mainColor,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, color: mainColor),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
      ),
      value: value,
      items: items.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
      onChanged: onChanged,
    );
  }
}