import 'package:flutter/material.dart';
import 'areaselector.dart';

class UserCondition extends StatefulWidget {
  final String name;
  final String birthdate;
  final String email;
  final String password;
  final String nationality;
  // 追加された個人情報
  final String phoneNumber;
  final String residenceStatus;
  final String residenceCardNumber;
  final String emergencyContactName;
  final String emergencyContactPhoneNumber;
  final String emergencyContactRelationship;
  final String stayDurationInJapan;


  const UserCondition({
    super.key,
    required this.name,
    required this.birthdate,
    required this.email,
    required this.password,
    required this.nationality,
    // 追加された個人情報もrequiredにする
    required this.phoneNumber,
    required this.residenceStatus,
    required this.residenceCardNumber,
    required this.emergencyContactName,
    required this.emergencyContactPhoneNumber,
    required this.emergencyContactRelationship,
    required this.stayDurationInJapan,
  });

  @override
  State<UserCondition> createState() => _UserConditionState();
}

class _UserConditionState extends State<UserCondition> {
  final _formKey = GlobalKey<FormState>();

  String? _rentMax;
  List<String> _selectedLayout = [];
  List<String> _selectedFacilities = [];
  String? _moveInDate;

  // 新しい物件条件の変数
  String? _guarantorSupport; // 保証人/保証会社サポート
  String? _initialPaymentMethod; // 初期費用の支払い方法
  String? _contractPeriod; // 契約期間
  List<String> _selectedFurnitureAppliances = []; // 家具・家電の有無
  String? _screeningLanguageSupport; // 入居審査の言語サポート

  final List<String> layouts = ['1R', '1K', '1DK', '2DK', '2LDK', '3LDK以上'];
  final List<String> facilities = ['バス・トイレ別', 'エアコン', 'オートロック', 'ペット可'];
  final List<String> moveInOptions = [
    '1分以内 (Within 1 min)', '5分以内 (Within 5 min)', '10分以内 (Within 10 min)',
    '15分以内 (Within 15 min)', '20分以上 (More than 20 min)'
  ];

  // 新しい物件条件の選択肢（日本語 (英語) 形式）
  final List<String> guarantorOptions = [
    '不要 (Not required)', '保証会社利用可 (Guarantor company available)', '保証人必須 (Guarantor required)'
  ];
  final List<String> paymentMethodOptions = [
    '現金 (Cash)', 'クレジットカード (Credit Card)', '銀行振込 (Bank Transfer)', 'その他 (Other)'
  ];
  final List<String> contractPeriodOptions = [
    '1年未満 (Less than 1 year)', '1年 (1 year)', '2年 (2 years)', '2年以上 (More than 2 years)'
  ];
  final List<String> furnitureApplianceOptions = [
    '家具付き (Furnished)', '家電付き (Appliances included)', '家具・家電なし (Unfurnished/No appliances)'
  ];
  final List<String> screeningLanguageOptions = [
    '日本語のみ (Japanese only)', '英語対応 (English support)', 'その他言語対応 (Other languages support)'
  ];


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
              'Enter Desired Conditions',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 2),
            const Text(
              '希望条件を入力',
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
        child: Padding(
          padding: const EdgeInsets.all(24), // パディングを統一
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select desired areas (multiple allowed)',
                      style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '希望エリアを選んでください（いくつでもOK）',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: mainColor), // メインカラー
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const AreaSelector(),

                const SizedBox(height: 30), // スペーシングを統一
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Max monthly rent (JPY)',
                      style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 2),
                    const Text('家賃の上限（円）', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '例: 70000',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.currency_yen, color: mainColor), // アイコン色もメインカラーに
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  onChanged: (val) => _rentMax = val,
                ),

                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select desired layouts (multiple allowed)',
                      style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 2),
                    const Text('間取りを選んでください（いくつでもOK）', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8, // 行間のスペーシングも追加
                  children: layouts.map((layout) {
                    return FilterChip(
                      label: Text(layout),
                      selected: _selectedLayout.contains(layout),
                      onSelected: (selected) {
                        setState(() {
                          selected
                              ? _selectedLayout.add(layout)
                              : _selectedLayout.remove(layout);
                        });
                      },
                      selectedColor: secondaryColor.withOpacity(0.2), // 選択時の色をサブカラーの薄めに
                      checkmarkColor: mainColor, // チェックマークの色をメインカラーに
                      labelStyle: TextStyle(color: _selectedLayout.contains(layout) ? mainColor : Colors.black87), // 選択時のテキスト色
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select desired facilities (multiple allowed)',
                      style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 2),
                    const Text('設備を選んでください（いくつでもOK）', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: facilities.map((item) {
                    return FilterChip(
                      label: Text(item),
                      selected: _selectedFacilities.contains(item),
                      onSelected: (selected) {
                        setState(() {
                          selected
                              ? _selectedFacilities.add(item)
                              : _selectedFacilities.remove(item);
                        });
                      },
                      selectedColor: secondaryColor.withOpacity(0.2),
                      checkmarkColor: mainColor,
                      labelStyle: TextStyle(color: _selectedFacilities.contains(item) ? mainColor : Colors.black87),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distance from station',
                      style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 2),
                    const Text('駅からの距離', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: '選んでください',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.train, color: mainColor), // アイコン色もメインカラーに
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  value: _moveInDate,
                  items: moveInOptions
                      .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                      .toList(),
                  onChanged: (val) => setState(() => _moveInDate = val),
                ),
                Text(
                  'Please select',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),

                // --- ここから追加の物件条件 ---
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guarantor / Guarantor Company Support',
                      style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 2),
                    const Text('保証人 / 保証会社サポート', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: '選んでください',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.security, color: mainColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  value: _guarantorSupport,
                  items: guarantorOptions
                      .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                      .toList(),
                  onChanged: (val) => setState(() => _guarantorSupport = val),
                ),
                Text(
                  'Please select',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),

                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Initial Payment Method',
                      style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 2),
                    const Text('初期費用の支払い方法', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: '選んでください',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.payment, color: mainColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  value: _initialPaymentMethod,
                  items: paymentMethodOptions
                      .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                      .toList(),
                  onChanged: (val) => setState(() => _initialPaymentMethod = val),
                ),
                Text(
                  'Please select',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),

                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contract Period',
                      style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 2),
                    const Text('契約期間', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: '選んでください',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.calendar_today, color: mainColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  value: _contractPeriod,
                  items: contractPeriodOptions
                      .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                      .toList(),
                  onChanged: (val) => setState(() => _contractPeriod = val),
                ),
                Text(
                  'Please select',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),

                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Furniture / Appliances',
                      style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 2),
                    const Text('家具・家電の有無', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: furnitureApplianceOptions.map((item) {
                    return FilterChip(
                      label: Text(item),
                      selected: _selectedFurnitureAppliances.contains(item),
                      onSelected: (selected) {
                        setState(() {
                          selected
                              ? _selectedFurnitureAppliances.add(item)
                              : _selectedFurnitureAppliances.remove(item);
                        });
                      },
                      selectedColor: secondaryColor.withOpacity(0.2),
                      checkmarkColor: mainColor,
                      labelStyle: TextStyle(color: _selectedFurnitureAppliances.contains(item) ? mainColor : Colors.black87),
                    );
                  }).toList(),
                ),
                Text(
                  'Please select',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),

                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Screening Language Support',
                      style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 2),
                    const Text('入居審査の言語サポート', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: '選んでください',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.translate, color: mainColor),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  value: _screeningLanguageSupport,
                  items: screeningLanguageOptions
                      .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                      .toList(),
                  onChanged: (val) => setState(() => _screeningLanguageSupport = val),
                ),
                Text(
                  'Please select',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                // --- 追加の物件条件ここまで ---

                const SizedBox(height: 40),
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
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('登録が完了しました！ (Registration complete!)')),
                        );
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Register',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '登録する',
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