import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ffh_sdj/areaselector.dart';


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

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: '生年月日を選択',
    );
    if (picked != null) setState(() => _birthDate = picked);
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
              ListTile(
                title: Text('生年月日: ${_birthDate != null ? DateFormat('yyyy年MM月dd日').format(_birthDate!) : '未選択'}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectBirthDate(context),
              ),

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
                obscureText: true,
                decoration: InputDecoration(labelText: 'パスワード'),
                onChanged: (val) => _password = val,
                validator: (val) => val!.length < 6 ? '6文字以上必要です' : null,
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'パスワード（確認）'),
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

              // // 希望エリアカテゴリ
              // MultiSelectDialogField<String>(
              //   items: areaCategories.map((e) => MultiSelectItem(e, e)).toList(),
              //   title: Text("希望エリア（大分類）"),
              //   buttonText: Text("希望エリアカテゴリを選択"),
              //   onConfirm: (values) => _desiredAreaCategory = values,
              // ),

              // // 希望エリア詳細
              // TextFormField(
              //   decoration: InputDecoration(labelText: '希望エリア詳細（例：大阪市梅田など）'),
              //   onChanged: (val) => _desiredAreaDetail = val,
              // ),

              //希望エリアの選択
              AreaSelector(),

              // 希望条件
              MultiSelectDialogField<String>(
                items: conditions.map((cond) => MultiSelectItem(cond, cond)).toList(),
                title: Text("希望条件"),
                buttonText: Text("希望条件を選択"),
                onConfirm: (values) => _desiredConditions = values,
              ),
              SizedBox(height: 16),

              // 利用規約
              CheckboxListTile(
                title: Text("利用規約に同意する"),
                value: _agreeToTerms,
                onChanged: (val) => setState(() => _agreeToTerms = val ?? false),
              ),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _agreeToTerms) {
                    // 登録処理
                    print('登録成功');
                  } else {
                    print('エラーがあります');
                  }
                },
                child: Text('登録'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
