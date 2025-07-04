import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:intl/intl.dart';
import 'user_condition.dart';

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

  final List<String> nationalities = [
    '日本 (Japan)', 'アメリカ (USA)', 'イギリス (UK)', 'カナダ (Canada)', 'オーストラリア (Australia)',
    '中国 (China)', '韓国 (South Korea)', 'ベトナム (Vietnam)', 'フィリピン (Philippines)',
    'インドネシア (Indonesia)', 'フランス (France)', 'ドイツ (Germany)', 'スペイン (Spain)',
    'ブラジル (Brazil)', 'インド (India)', 'タイ (Thailand)', 'ネパール (Nepal)',
    'バングラデシュ (Bangladesh)', 'マレーシア (Malaysia)', 'その他 (Other)'
  ];

  final List<String> languages = [
    '日本語 (Japanese)', '英語 (English)', '中国語 (Chinese)', '韓国語 (Korean)',
    'スペイン語 (Spanish)', 'フランス語 (French)', 'ベトナム語 (Vietnamese)', 'その他 (Other)'
  ];

  // 在留資格の選択肢 (日本語 (English) 形式)
  final List<String> residenceStatuses = [
    '永住者 (Permanent Resident)', '日本人の配偶者等 (Spouse or Child of Japanese National)',
    '定住者 (Long-Term Resident)', '技術・人文知識・国際業務 (Engineer/Specialist in Humanities/International Services)',
    '留学 (Student)', '技能実習 (Technical Intern Training)', '特定技能 (Specified Skilled Worker)',
    '家族滞在 (Dependent)', 'その他 (Other)'
  ];

  // 続柄の選択肢 (日本語 (English) 形式)
  final List<String> relationships = [
    '親 (Parent)', '兄弟 (Sibling)', '友人 (Friend)', 'その他 (Other)'
  ];

  // 日本での滞在期間の選択肢 (日本語 (English) 形式)
  final List<String> stayDurations = [
    '1年未満 (Less than 1 year)', '1〜3年 (1-3 years)', '3〜5年 (3-5 years)',
    '5年以上 (More than 5 years)', '永住 (Permanent)'
  ];


  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedDay;

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
    if (_selectedYear != null &&
        _selectedMonth != null &&
        _selectedDay != null) {
      _birthDate = DateTime(_selectedYear!, _selectedMonth!, _selectedDay!);
    }
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
        backgroundColor: mainColor, // AppBarの色を統一
        foregroundColor: Colors.white, // タイトル色
        centerTitle: false,
      ),
      body: Container(
        color: mainBackgroundColor, // 単色背景に統一
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // 子要素を横幅いっぱいに広げる
              children: [
                Column(
                  children: [
                    Text(
                      'Create your account',
                      style: TextStyle(fontSize: 16, color: secondaryColor), // サブカラー
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'アカウントを作成',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: mainColor, // メインカラー
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // 苗字
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '姓', // 日本語のみに短縮
                    hintText: '例: 山田 (Yamada)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.person, color: mainColor), // アイコン色もメインカラーに
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  onChanged: (val) => _familyName = val,
                  validator: (val) => val!.isEmpty ? '苗字を入力してください (Please enter your First Name)' : null,
                ),
                Text(
                  'First Name', // 英語を別のTextウィジェットで表示
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // 名前
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '名', // 日本語のみに短縮
                    hintText: '例: 太郎 (Taro)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.person_outline, color: mainColor), // アイコン色もメインカラーに
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  onChanged: (val) => _givenName = val,
                  validator: (val) => val!.isEmpty ? '名前を入力してください (Please enter your Last Name)' : null,
                ),
                Text(
                  'Last Name', // 英語を別のTextウィジェットで表示
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
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '生年月日',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
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
                          labelText: '年', // 日本語のみに短縮
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
                        validator: (val) => val == null ? '年を選んでください (Please select a year)' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: '月', // 日本語のみに短縮
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
                        validator: (val) => val == null ? '月を選んでください (Please select a month)' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: '日', // 日本語のみに短縮
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
                        validator: (val) => val == null ? '日を選んでください (Please select a day)' : null,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Year / Month / Day', // 英語を別のTextウィジェットで表示
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
                      // 「日本 (Japan)」が選択された場合に_isJapaneseをtrueにする
                      _isJapanese = (val == '日本 (Japan)');
                      // 国籍が日本以外になった場合、外国人向け情報をリセット
                      if (!_isJapanese) {
                        _residenceStatus = null;
                        _residenceCardNumber = '';
                        _stayDurationInJapan = null;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    labelText: '国籍', // 日本語のみに短縮
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.public, color: mainColor), // アイコン色もメインカラーに
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  'Nationality', // 英語を別のTextウィジェットで表示
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // 話せる言語選択
                MultiSelectDialogField<String>(
                  items: languages.map((lang) => MultiSelectItem(lang, lang)).toList(),
                  title: const Text("話せる言語を選んでください (Select languages you speak)"), // ダイアログのタイトルは併記
                  buttonText: const Text("言語"), // ボタンのテキストは短く (Overflow対策)
                  decoration: BoxDecoration( // TextFieldのInputDecorationに似せる
                    border: Border.all(color: Colors.grey.shade400), // 枠線の色を調整
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.9),
                  ),
                  buttonIcon: Icon(Icons.language, color: mainColor), // アイコン色もメインカラーに
                  onConfirm: (values) => _selectedLanguages = values,
                  validator: (values) => values == null || values.isEmpty ? '言語を選択してください (Select language)' : null, // 短縮
                ),
                Text(
                  'Languages you speak', // 英語を別のTextウィジェットで表示
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // メールアドレス
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'メールアドレス', // 日本語のみに短縮
                    hintText: '例: your.email@example.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.email, color: mainColor), // アイコン色もメインカラーに
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) => _email = val,
                  validator: (val) => !val!.contains('@') ? '正しいメール形式で入力してください (Please enter a valid email format)' : null,
                ),
                Text(
                  'Email address', // 英語を別のTextウィジェットで表示
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // パスワード
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'パスワード', // 日本語のみに短縮
                    hintText: '6文字以上で入力してください',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  obscureText: _obscurePassword,
                  onChanged: (val) => _password = val,
                  validator: (val) => val!.length < 6 ? '6文字以上必要です (Needs 6 or more characters)' : null,
                ),
                Text(
                  'Password', // 英語を別のTextウィジェットで表示
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // パスワード（確認）
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'パスワード（確認）', // 日本語のみに短縮
                    hintText: 'もう一度入力してください',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.lock_reset, color: mainColor), // アイコン色もメインカラーに
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
                  'Confirm password', // 英語を別のTextウィジェットで表示
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // 電話番号 (日本人でも必要なので常に表示)
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '電話番号', // 日本語のみに短縮
                    hintText: '例: 090-1234-5678',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.phone, color: mainColor), // アイコン色もメインカラーに
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (val) => _phoneNumber = val,
                  validator: (val) => val!.isEmpty ? '電話番号を入力してください (Please enter your phone number)' : null,
                ),
                Text(
                  'Phone Number', // 英語を別のTextウィジェットで表示
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
                      labelText: '在留資格', // 日本語のみに短縮
                      hintText: '選んでください',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.badge, color: mainColor), // アイコン色もメインカラーに
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                    validator: (val) => val == null || val.isEmpty ? '在留資格を選んでください (Please select your residence status)' : null,
                  ),
                  Text(
                    'Residence Status', // 英語を別のTextウィジェットで表示
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
                      prefixIcon: Icon(Icons.credit_card, color: mainColor), // アイコン色もメインカラーに
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                    onChanged: (val) => _residenceCardNumber = val,
                    validator: (val) => val!.isEmpty ? '在留カード番号を入力してください (Please enter your residence card number)' : null,
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
                      prefixIcon: Icon(Icons.calendar_month, color: mainColor), // アイコン色もメインカラーに
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                    validator: (val) => val == null || val.isEmpty ? '日本での滞在期間を選んでください (Please select your duration of stay in Japan)' : null,
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
                    prefixIcon: Icon(Icons.location_on, color: mainColor), // アイコン色もメインカラーに
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  onChanged: (val) => _currentAddress = val,
                  validator: (val) => val!.isEmpty ? '今の住所を入力してください (Please enter your current address)' : null,
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
                    color: mainColor, // メインカラー
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
                    prefixIcon: Icon(Icons.person_outline, color: mainColor), // アイコン色もメインカラーに
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  onChanged: (val) => _emergencyContactName = val,
                  validator: (val) => val!.isEmpty ? '緊急連絡先の氏名を入力してください (Please enter emergency contact name)' : null,
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
                    prefixIcon: Icon(Icons.phone_android, color: mainColor), // アイコン色もメインカラーに
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (val) => _emergencyContactPhoneNumber = val,
                  validator: (val) => val!.isEmpty ? '緊急連絡先の電話番号を入力してください (Please enter emergency contact phone number)' : null,
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
                    labelText: '連絡先の方との関係', // 日本語のみに短縮
                    hintText: '選んでください',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.family_restroom, color: mainColor), // アイコン色もメインカラーに
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  validator: (val) => val == null || val.isEmpty ? '緊急連絡先の方との関係を選んでください (Please select emergency contact relationship)' : null,
                ),
                Text(
                  'Relationship with contact person', // 英語を別のTextウィジェットで表示
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 30),

                // 利用規約
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
                  activeColor: mainColor, // チェックボックスの色をメインカラーに
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
                      backgroundColor: mainColor, // メインカラー
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _agreeToTerms) {
                        final String formattedBirthdate = DateFormat('yyyy/MM/dd').format(_birthDate!);
                        // 日本国籍の場合は外国人向け情報を空にする
                        final String finalResidenceStatus = _isJapanese ? '' : (_residenceStatus ?? '');
                        final String finalResidenceCardNumber = _isJapanese ? '' : _residenceCardNumber;
                        final String finalStayDurationInJapan = _isJapanese ? '' : (_stayDurationInJapan ?? '');

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserCondition(
                              name: '$_familyName $_givenName', // 苗字と名前を結合して渡す
                              birthdate: formattedBirthdate,
                              email: _email,
                              password: _password,
                              nationality: _nationality,
                              phoneNumber: _phoneNumber,
                              residenceStatus: finalResidenceStatus, // 条件付きで値を渡す
                              residenceCardNumber: finalResidenceCardNumber, // 条件付きで値を渡す
                              emergencyContactName: _emergencyContactName,
                              emergencyContactPhoneNumber: _emergencyContactPhoneNumber,
                              emergencyContactRelationship: _emergencyContactRelationship!,
                              stayDurationInJapan: finalStayDurationInJapan, // 条件付きで値を渡す
                            ),
                          ),
                        );
                      } else {
                        _showMessage('入力にエラーがあります。すべての項目を正しく入力し、利用規約に同意してください。 (There are errors in the input. Please fill in all fields correctly and agree to the terms of use.)');
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
}
