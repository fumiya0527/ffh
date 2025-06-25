import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '総合フォーム', // アプリのタイトルを「総合フォーム」に戻す
      theme: ThemeData(
        primarySwatch: Colors.blue, // テーマカラーを青色に戻す
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PersonalInfoFormScreen(), // アプリ開始画面を個人情報入力フォームにする
    );
  }
}

// --- 個人情報入力フォーム ---
class PersonalInfoFormScreen extends StatefulWidget {
  const PersonalInfoFormScreen({super.key});

  @override
  State<PersonalInfoFormScreen> createState() => _PersonalInfoFormScreenState();
}

class _PersonalInfoFormScreenState extends State<PersonalInfoFormScreen> {
  final _formKey = GlobalKey<FormState>();

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
      // 個人情報データをマップにまとめる（今回は次の画面に渡さないが、必要に応じて利用可）
      final Map<String, String> personalData = {
        '氏名': _nameController.text,
        'メールアドレス': _emailController.text,
        '電話番号': _phoneController.text,
        '性別': _selectedGender ?? '未選択',
        '生年月日': _selectedDateOfBirth?.toLocal().toString().split(' ')[0] ?? '未選択',
        '利用規約に同意': _agreedToTerms.toString(),
      };

      // 個人情報入力フォームから直接、物件情報登録フォームへ遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PropertyRegistrationScreen(), // データは渡さない
        ),
      );
    } else {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
              CheckboxListTile(
                title: const Text('利用規約に同意する'),
                value: _agreedToTerms,
                onChanged: (bool? newValue) {
                  setState(() {
                    _agreedToTerms = newValue ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (!_agreedToTerms && _formKey.currentState?.validate() == true)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    '利用規約への同意が必要です',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm, // ここで次のページに遷移する
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('次へ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 大家さん向け物件情報登録フォーム ---
class PropertyRegistrationScreen extends StatefulWidget {
  const PropertyRegistrationScreen({super.key});

  @override
  State<PropertyRegistrationScreen> createState() => _PropertyRegistrationScreenState();
}

class _PropertyRegistrationScreenState extends State<PropertyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // 物件の基本情報用コントローラー
  final TextEditingController _propertyNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();

  // 間取りの選択肢（今回はラジオボタンで単一選択）
  String? _selectedFloorPlan;
  final List<String> _floorPlans = ['1R', '1K', '1DK', '1LDK', '2K', '2DK', '2LDK', '3K以上'];

  // 駅からの距離の選択肢（今回はドロップダウンで単一選択）
  String? _selectedDistanceToStation;
  final List<String> _distances = ['1分以内', '5分以内', '10分以内', '15分以内', '20分以上', 'バス利用'];

  // 設備・条件のチェックリスト（複数選択）
  final List<Map<String, dynamic>> _amenities = [
    {'title': 'バス・トイレ別', 'checked': false},
    {'title': '独立洗面台', 'checked': false},
    {'title': '室内洗濯機置場', 'checked': false},
    {'title': 'エアコン付き', 'checked': false},
    {'title': 'オートロック', 'checked': false},
    {'title': '宅配ボックス', 'checked': false},
    {'title': 'ペット相談可', 'checked': false},
    {'title': '駐車場あり', 'checked': false},
    {'title': 'インターネット無料', 'checked': false},
    {'title': 'バルコニー', 'checked': false},
  ];

  @override
  void dispose() {
    _propertyNameController.dispose();
    _addressController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  void _registerProperty() {
    if (_formKey.currentState!.validate()) {
      // フォームの入力値が全て有効な場合
      final Map<String, dynamic> propertyData = {
        '物件名': _propertyNameController.text,
        '所在地': _addressController.text,
        '家賃': _rentController.text,
        '間取り': _selectedFloorPlan ?? '未選択',
        '駅からの距離': _selectedDistanceToStation ?? '未選択',
        '設備・条件': _amenities.where((item) => item['checked']).map((item) => item['title']).toList(),
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('物件情報を登録しました！')),
      );

      print('--- 登録された物件情報 ---');
      print(propertyData);

      // ここでデータベースへの保存やAPI送信などの処理を行う
      // 例: Firestoreに保存、バックエンドAPIへPOSTリクエストなど

      // フォームをクリアすることも可能
      // _propertyNameController.clear();
      // _addressController.clear();
      // _rentController.clear();
      // setState(() {
      //   _selectedFloorPlan = null;
      //   _selectedDistanceToStation = null;
      //   for (var item in _amenities) {
      //     item['checked'] = false;
      //   }
      // });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('入力エラーがあります。ご確認ください。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('物件情報登録'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 物件名
              TextFormField(
                controller: _propertyNameController,
                decoration: const InputDecoration(
                  labelText: '物件名',
                  hintText: '例: 〇〇ハイツ 101号室',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '物件名を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // 所在地
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: '所在地',
                  hintText: '例: 東京都渋谷区〇〇 1-2-3',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '所在地を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // 家賃
              TextFormField(
                controller: _rentController,
                decoration: const InputDecoration(
                  labelText: '家賃 (月額)',
                  hintText: '例: 80000',
                  suffixText: '円',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '家賃を入力してください';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return '有効な家賃を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),

              // 間取り (ラジオボタン)
              const Text('間取り', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Column(
                children: _floorPlans.map((plan) {
                  return RadioListTile<String>(
                    title: Text(plan),
                    value: plan,
                    groupValue: _selectedFloorPlan,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFloorPlan = newValue;
                      });
                    },
                  );
                }).toList(),
              ),
              if (_selectedFloorPlan == null && _formKey.currentState?.validate() == true)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: Text(
                    '間取りを選択してください',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16.0),

              // 駅からの距離 (ドロップダウン)
              InputDecorator(
                decoration: InputDecoration(
                  labelText: '駅からの距離',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  errorText: (_selectedDistanceToStation == null && _formKey.currentState?.validate() == true)
                      ? '駅からの距離を選択してください'
                      : null,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDistanceToStation,
                    hint: const Text('選択してください'),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDistanceToStation = newValue;
                      });
                    },
                    items: _distances.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // 設備・条件 (チェックリスト)
              const Text('設備・条件 (複数選択可)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _amenities.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(_amenities[index]['title']),
                    value: _amenities[index]['checked'],
                    onChanged: (bool? newValue) {
                      setState(() {
                        _amenities[index]['checked'] = newValue ?? false;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 24.0),

              // 登録ボタン
              Center(
                child: ElevatedButton(
                  onPressed: _registerProperty,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('物件情報を登録'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}