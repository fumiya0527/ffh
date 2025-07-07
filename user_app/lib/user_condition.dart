import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
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

  // 家賃の上限と下限をスライダーで管理
  RangeValues _currentRentRange = const RangeValues(30000, 200000);

  String? _numberOfResidents; // 居住予定人数
  String? _moveInDate; // 駅からの距離

  List<String> _selectedLayout = []; // LDK表記用
  String? _bedrooms; // ベッドルーム数
  String? _bathrooms; // バスルーム数

  // ★変更: _selectedFacilities に全ての設備・特徴を統合して管理
  List<String> _selectedFacilities = [];

  // 削除: _hasBalcony, _sunlight, _buildingAge, _selectedSurroundings, _selectedKitchenFacilities は不要

  String? _guarantorSupport; // 保証人/保証会社サポート
  String? _initialPaymentMethod; // 初期費用の支払い方法
  String? _contractPeriod; // 契約期間
  List<String> _selectedFurnitureAppliances = []; // 家具・家電の有無
  String? _screeningLanguageSupport; // 入居審査の言語サポート

  // ★更新: facilities リストに全ての設備・特徴の選択肢を統合
  final List<String> facilities = [
    // 既存の設備
    'バス・トイレ別 (Separate Bath/Toilet)',
    'エアコン (Air Conditioner)',
    'オートロック (Auto-lock)',
    'ペット可 (Pet-friendly)',
    'Wi-Fiあり (Wi-Fi available)',
    '駐車場あり (Parking available)',
    '畳なし (No Tatami rooms)',
    // 周辺環境 (旧 surroundingsOptions)
    'スーパーが近い (Supermarket nearby)',
    'コンビニが近い (Convenience store nearby)',
    '病院が近い (Hospital nearby)',
    '公園が近い (Park nearby)',
    '学校が近い (School nearby)',
    // キッチン設備 (旧 kitchenFacilitiesOptions)
    'ガスコンロ (Gas Stove)',
    'IHコンロ (IH Cooktop)',
    'システムキッチン (System Kitchen)',
    '食洗機 (Dishwasher)',
    '広いキッチン (Spacious Kitchen)',
    // バルコニーの有無 (旧 yesNoOptionsの一部)
    'バルコニーあり (Balcony available)',
    'バルコニーなし (No Balcony)',
    // 日当たり (旧 sunlightOptions)
    '日当たりが良い (Good sunlight)',
    '日当たり普通 (Normal sunlight)',
    '日当たり悪い (Bad sunlight)',
    // 築年数 (旧 buildingAgeOptions)
    '築年数：新築 (New construction)',
    '築年数：5年以内 (Building age: Within 5 years)',
    '築年数：10年以内 (Building age: Within 10 years)',
    '築年数：20年以内 (Building age: Within 20 years)',
    '築年数：20年以上 (Building age: More than 20 years)',
  ];

  final List<String> layouts = ['1R', '1K', '1DK', '2DK', '2LDK', '3LDK以上'];
  final List<String> moveInOptions = [
    '1分以内 (Within 1 min)', '5分以内 (Within 5 min)', '10分以内 (Within 10 min)',
    '15分以内 (Within 15 min)', '20分以上 (More than 20 min)'
  ];

  final List<String> numberOfResidentsOptions = [
    '1人 (1 person)', '2人 (2 people)', '3人 (3 people)', '4人 (4 people)', '5人以上 (5+ people)'
  ];
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

  // 削除: surroundingsOptions, kitchenFacilitiesOptions, yesNoOptions, sunlightOptions, buildingAgeOptions

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
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: Container(
        color: mainBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // --- 1. 基本的な希望条件 ---
                _buildSectionTitle('Basic Preferences', '基本的な希望条件', mainColor, secondaryColor),
                const SizedBox(height: 15),

                // 家賃
                _buildSubSectionTitle('Monthly Rent Range (JPY)', '家賃範囲（円）'),
                const SizedBox(height: 8),
                RangeSlider(
                  values: _currentRentRange,
                  min: 30000,
                  max: 500000,
                  divisions: 47,
                  labels: RangeLabels(
                    _currentRentRange.start.round().toString(),
                    _currentRentRange.end.round().toString(),
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _currentRentRange = values;
                    });
                  },
                  activeColor: mainColor,
                  inactiveColor: mainColor.withOpacity(0.3),
                ),
                Center(
                  child: Text(
                    '${_currentRentRange.start.round()}円 ～ ${_currentRentRange.end.round()}円',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainColor),
                  ),
                ),
                const SizedBox(height: 20),

                // 希望エリア
                _buildSubSectionTitle('Desired Areas (multiple allowed)', '希望エリア（いくつでもOK）'),
                const SizedBox(height: 15),
                const AreaSelector(),
                const SizedBox(height: 20),

                // 居住予定人数
                _buildSubSectionTitle('Number of Residents', '居住予定人数'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _numberOfResidents,
                  items: numberOfResidentsOptions,
                  onChanged: (val) => setState(() => _numberOfResidents = val!),
                  labelText: '選んでください',
                  icon: Icons.people,
                  mainColor: mainColor,
                ),
                const SizedBox(height: 20),

                // 駅からの距離
                _buildSubSectionTitle('Distance from station', '駅からの距離'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _moveInDate,
                  items: moveInOptions,
                  onChanged: (val) => setState(() => _moveInDate = val!),
                  labelText: '選んでください',
                  icon: Icons.train,
                  mainColor: mainColor,
                ),
                const SizedBox(height: 20),

                // --- 2. 物件の間取り・タイプ ---
                const SizedBox(height: 30),
                _buildSectionTitle('Layout & Room Types', '間取り・部屋のタイプ', mainColor, secondaryColor),
                const SizedBox(height: 15),

                // 間取り (LDK表記)
                _buildSubSectionTitle('Select desired layouts (multiple allowed)', '間取りを選んでください（いくつでもOK）'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                      selectedColor: secondaryColor.withOpacity(0.2),
                      checkmarkColor: mainColor,
                      labelStyle: TextStyle(color: _selectedLayout.contains(layout) ? mainColor : Colors.black87),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // ベッドルームとバスルームの数 (LDK表記では伝わりにくい外国人向け)
                _buildSubSectionTitle('Alternatively, specify number of rooms', 'または、部屋数を指定'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'ベッドルーム数 (Bedrooms)',
                          hintText: '例: 2',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                        ),
                        onChanged: (val) => _bedrooms = val,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'バスルーム数 (Bathrooms)',
                          hintText: '例: 1',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                        ),
                        onChanged: (val) => _bathrooms = val,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),


                // --- 3. 物件の設備・特徴（旧「詳細な物件特性」もここに統合） ---
                const SizedBox(height: 30),
                _buildSectionTitle('Facilities & Features', '設備・特徴', mainColor, secondaryColor),
                const SizedBox(height: 15),

                // 設備（Wi-Fi, 駐車場, 畳の有無を含む）と、周辺環境、キッチン設備、バルコニー、日当たり、築年数
                _buildSubSectionTitle('Select desired facilities and characteristics (multiple allowed)', '希望の設備と特徴を選んでください（複数選択可）'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: facilities.map((item) { // facilities リストがすべての選択肢を含む
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
                Text(
                  'Please select (multiple allowed)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // 家具・家電の有無
                _buildSubSectionTitle('Furniture / Appliances', '家具・家電の有無'),
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
                const SizedBox(height: 20),

                // --- 4. 契約・入居に関する条件 ---
                const SizedBox(height: 30),
                _buildSectionTitle('Contract & Move-in Conditions', '契約・入居に関する条件', mainColor, secondaryColor),
                const SizedBox(height: 15),

                // 保証人 / 保証会社サポート
                _buildSubSectionTitle('Guarantor / Guarantor Company Support', '保証人 / 保証会社サポート'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _guarantorSupport,
                  items: guarantorOptions,
                  onChanged: (val) => setState(() => _guarantorSupport = val!),
                  labelText: '選んでください',
                  icon: Icons.security,
                  mainColor: mainColor,
                ),
                const SizedBox(height: 20),

                // 初期費用の支払い方法
                _buildSubSectionTitle('Initial Payment Method', '初期費用の支払い方法'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _initialPaymentMethod,
                  items: paymentMethodOptions,
                  onChanged: (val) => setState(() => _initialPaymentMethod = val!),
                  labelText: '選んでください',
                  icon: Icons.payment,
                  mainColor: mainColor,
                ),
                const SizedBox(height: 20),

                // 契約期間
                _buildSubSectionTitle('Contract Period', '契約期間'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _contractPeriod,
                  items: contractPeriodOptions,
                  onChanged: (val) => setState(() => _contractPeriod = val!),
                  labelText: '選んでください',
                  icon: Icons.calendar_today,
                  mainColor: mainColor,
                ),
                const SizedBox(height: 20),

                // 入居審査の言語サポート
                _buildSubSectionTitle('Screening Language Support', '入居審査の言語サポート'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _screeningLanguageSupport,
                  items: screeningLanguageOptions,
                  onChanged: (val) => setState(() => _screeningLanguageSupport = val!),
                  labelText: '選んでください',
                  icon: Icons.translate,
                  mainColor: mainColor,
                ),
                const SizedBox(height: 40),

                // 登録ボタン
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('登録が完了しました！ (Registration complete!)')),
                        );
                        // 実際にはここで入力された条件を次の画面に渡すか、APIに送信する
                        // 例: print('Rent Range: ${_currentRentRange.start}-${_currentRentRange.end}');
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

  // ヘルパーメソッドは変更なし
  Widget _buildSectionTitle(String englishTitle, String japaneseTitle, Color mainColor, Color secondaryColor) {
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
        hintText: labelText, // '選んでください' の代わりに labelText を使う
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, color: mainColor),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
      ),
      value: value,
      items: items
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: onChanged,
    );
  }
}