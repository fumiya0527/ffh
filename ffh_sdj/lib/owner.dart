import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '個人情報入力フォーム',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PersonalInfoFormScreen(),
    );
  }
}

class PersonalInfoFormScreen extends StatefulWidget {
  const PersonalInfoFormScreen({super.key});

  @override
  State<PersonalInfoFormScreen> createState() => _PersonalInfoFormScreenState();
}

class _PersonalInfoFormScreenState extends State<PersonalInfoFormScreen> {
  final _formKey = GlobalKey<FormState>(); // フォームのキー

  // 各入力フィールドのコントローラーと値
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // フォームの入力値が全て有効な場合
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('フォームを送信しました')),
      );
      // ここで入力されたデータを処理します（例: サーバーに送信、データベースに保存など）
      print('氏名: ${_nameController.text}');
      print('メールアドレス: ${_emailController.text}');
      print('電話番号: ${_phoneController.text}');
      print('性別: $_selectedGender');
      print('生年月日: ${_selectedDateOfBirth?.toLocal().toString().split(' ')[0]}');
      print('利用規約に同意: $_agreedToTerms');

      // フォームをクリアすることも可能です
      // _nameController.clear();
      // _emailController.clear();
      // _phoneController.clear();
      // setState(() {
      //   _selectedGender = null;
      //   _selectedDateOfBirth = null;
      //   _agreedToTerms = false;
      // });
    } else {
      // バリデーションエラーがある場合
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('入力エラーがあります。ご確認ください。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('個人情報入力フォーム'),
      ),
      body: SingleChildScrollView( // キーボードが表示された際に画面がはみ出さないように
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 氏名入力
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '氏名',
                  hintText: '例: 山田 太郎',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '氏名を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // メールアドレス入力
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'メールアドレス',
                  hintText: '例: your_email@example.com',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'メールアドレスを入力してください';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return '有効なメールアドレスを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // 電話番号入力
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '電話番号',
                  hintText: '例: 09012345678 (ハイフンなし)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '電話番号を入力してください';
                  }
                  if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                    return '有効な電話番号を入力してください (10桁または11桁の数字)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // 性別選択 (DropdownButton)
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: '性別',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    hint: const Text('選択してください'),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                    items: <String>['男性', '女性', 'その他', '回答しない']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // 生年月日選択
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: '生年月日',
                      hintText: _selectedDateOfBirth == null
                          ? '選択してください'
                          : _selectedDateOfBirth!.toLocal().toString().split(' ')[0],
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (_selectedDateOfBirth == null) {
                        return '生年月日を選択してください';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // 利用規約への同意 (CheckboxListTile)
              CheckboxListTile(
                title: const Text('利用規約に同意する'),
                value: _agreedToTerms,
                onChanged: (bool? newValue) {
                  setState(() {
                    _agreedToTerms = newValue ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading, // チェックボックスを左に配置
              ),
              // 同意が必須の場合のバリデーション
              if (!_agreedToTerms && _formKey.currentState?.validate() == true) // 仮の表示
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    '利用規約への同意が必要です',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24.0),

              // 送信ボタン
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('送信'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}