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

  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _nationality = '日本';
  DateTime? _birthDate;
  List<String> _selectedLanguages = [];
  String _currentAddress = '';
  String _desiredAreaDetail = '';
  List<String> _desiredAreaCategory = [];
  List<String> _desiredConditions = [];
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> nationalities = [
    '日本', 'アメリカ', 'イギリス', 'カナダ', 'オーストラリア', '中国', '韓国',
    'ベトナム', 'フィリピン', 'インドネシア', 'フランス', 'ドイツ', 'スペイン',
    'ブラジル', 'インド', 'タイ', 'ネパール', 'バングラデシュ', 'マレーシア', 'その他'
  ];

  final List<String> languages = [
    '日本語', '英語', '中国語', '韓国語', 'スペイン語', 'フランス語', 'ベトナム語', 'その他'
  ];

  final List<String> areaCategories = [
    '北海道・東北', '関東', '中部', '関西', '中国・四国', '九州・沖縄'
  ];

  final List<String> conditions = [
    'ペット可', '家具付き', '駅近', '外国語対応可', '日本語不要', '光熱費込み'
  ];
  
    // 年・月・日を保持
  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedDay;

  // 年リスト（1900年〜2025年）
  final List<int> _years = List.generate(126, (index) => 1900 + index);

  // 月リスト（1〜12）
  final List<int> _months = List.generate(12, (index) => index + 1);

  // 日リスト（1〜31）
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
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ユーザー登録')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                decoration: InputDecoration(labelText: '名前'),
                onChanged: (val) => _name = val,
                validator: (val) => val!.isEmpty ? '名前を入力してください' : null,
              ),

              // 生年月日選択
              // ListTile(
              //   title: Text('生年月日: ${_birthDate != null ? DateFormat('yyyy年MM月dd日').format(_birthDate!) : '未選択'}'),
              //   trailing: Icon(Icons.calendar_today),
              //   onTap: () => _selectBirthDate(context),
              // ),
              const Text('生年月日'),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: '年'),
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
                        validator: (val) => val == null ? '年を選択してください' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: '月'),
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
                        validator: (val) => val == null ? '月を選択' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: '日'),
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
                        validator: (val) => val == null ? '日を選択' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),


              // 国籍選択
              DropdownButtonFormField<String>(
                value: _nationality,
                items: nationalities
                    .map((nation) => DropdownMenuItem(value: nation, child: Text(nation)))
                    .toList(),
                onChanged: (val) => setState(() => _nationality = val!),
                decoration: InputDecoration(labelText: '国籍'),
              ),

              // 言語選択
              MultiSelectDialogField<String>(
                items: languages.map((lang) => MultiSelectItem(lang, lang)).toList(),
                title: Text("話せる言語"),
                buttonText: Text("話せる言語を選択"),
                onConfirm: (values) => _selectedLanguages = values,
              ),
              SizedBox(height: 16),

              // メールとパスワード
              TextFormField(
                decoration: InputDecoration(labelText: 'メールアドレス'),
                onChanged: (val) => _email = val,
                validator: (val) => !val!.contains('@') ? '正しいメール形式で' : null,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'パスワード',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                onChanged: (val) => _password = val,
                validator: (val) => val!.length < 6 ? '6文字以上必要です' : null,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'パスワード（確認）',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                onChanged: (val) => _confirmPassword = val,
                validator: (val) =>
                    val != _password ? 'パスワードが一致しません' : null,
              ),

              // 現在住所（具体的）
              TextFormField(
                decoration: InputDecoration(labelText: '現在の住所（例：東京都新宿区〇〇）'),
                onChanged: (val) => _currentAddress = val,
                validator: (val) => val!.isEmpty ? '現在住所を入力してください' : null,
              ),

              // 利用規約
              CheckboxListTile(
                title: Text("利用規約に同意する"),
                value: _agreeToTerms,
                onChanged: (val) => setState(() => _agreeToTerms = val ?? false),
              ),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _agreeToTerms) {
                    final String formattedBirthdate = DateFormat('yyyy/MM/dd').format(_birthDate!);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserCondition(
                          name: _name!,
                          birthdate: formattedBirthdate,
                          email: _email!,
                          password: _password!,
                          nationality: _nationality!,
                        ),
                      ),
                    );
                  } else {
                    print('エラーがあります');
                  }
                },
                child: Text('次へ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

