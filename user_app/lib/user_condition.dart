import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart'; // このimportは現在のコードでは直接使用されていませんが、念のため残しておきます
import 'package:intl/intl.dart'; // 通貨フォーマット用
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthを追加

import 'areaselector.dart'; // AreaSelector をインポート (パスは実際のプロジェクトに合わせてください)
import 'manner.dart'; // MannerScreen をインポート (パスは実際のプロジェクトに合わせてください)

class UserCondition extends StatefulWidget {
  // 前の画面から受け取るデータ
  final String name;
  final String birthdate;
  final String email;
  final String nationality;
  final String phoneNumber;
  final String residenceStatus;
  final String residenceCardNumber;
  final String emergencyContactName;
  final String emergencyContactPhoneNumber;
  final String emergencyContactRelationship;
  final String stayDurationInJapan;
  final String userUid; // UserRegistrationScreenから受け取るユーザーのUID

  const UserCondition({
    super.key,
    required this.name,
    required this.birthdate,
    required this.email,
    required this.nationality,
    required this.phoneNumber,
    required this.residenceStatus,
    required this.residenceCardNumber,
    required this.emergencyContactName,
    required this.emergencyContactPhoneNumber,
    required this.emergencyContactRelationship,
    required this.stayDurationInJapan,
    required this.userUid, // UIDを必須にする
  });

  @override
  State<UserCondition> createState() => _UserConditionState();
}

class _UserConditionState extends State<UserCondition> {
  final _formKey = GlobalKey<FormState>();

  // Firebaseのインスタンス
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 物件の希望条件
  RangeValues _currentRentRange = const RangeValues(30000, 200000);
  String? _numberOfResidents; // 居住予定人数
  String? _distanceToStation; // 駅からの距離
  String? _selectedLayout; // LDK表記用 (単一選択)

  // ベッドルームとバスルームは削除済み

  List<String> _amenities = []; // 設備・特徴

  // 家具・家電の有無は削除済み

  // 希望エリア（単一のcityとtownとして保存）
  String? _desiredCity;
  String? _desiredTown;

  // 築年数に関する変数
  String? _selectedBuildingAge; // 築年数 (単一選択)

  // 契約・入居に関する条件 (UIから削除済みだが、変数自体は存在する場合)
  String? _guarantorSupport;
  String? _initialPaymentMethod;
  String? _contractPeriod;
  String? _screeningLanguageSupport;

  // 全ての設備・特徴の選択肢を統合
  final List<String> allAmenities = [
    'バス・トイレ別 (Separate Bath/Toilet)',
    'エアコン付き', // ★修正点: "エアコン (Air Conditioner)" から変更
    'オートロック (Auto-lock)',
    'ペット可 (Pet-friendly)',
    'インターネット無料', // ★修正点: "Wi-Fiあり (Wi-Fi available)" から変更
    '駐車場あり (Parking available)',
    '畳なし (No Tatami rooms)',
    'IHコンロ (IH Cooktop)',
    'バルコニーあり (Balcony available)',
    'バルコニーなし (No Balcony)',
  ];

  // 築年数の選択肢
  final List<String> _buildingAgeOptions = [
    '5年以内 (Within 5 years)',
    '10年以内 (Within 10 years)',
    '20年以内 (Within 20 years)',
    '20年以上 (More than 20 years)',
  ];

  final List<String> layouts = ['1R', '1K', '1DK', '1LDK', '2K', '2DK', '2LDK', '3LDK以上'];
  
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
  
  final List<String> screeningLanguageOptions = [
    '日本語のみ (Japanese only)', '英語対応 (English support)', 'その他言語対応 (Other languages support)'
  ];

  // 英語表記を取り除くヘルパー関数
  String _extractJapanese(String text) {
    RegExp regex = RegExp(r'^(.*?)\s*\(.*?\)$'); // "日本語 (English)" のパターン
    Match? match = regex.firstMatch(text);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!.trim(); // 括弧の前の日本語部分を抽出
    }
    return text.trim(); // パターンに合わない場合はそのまま返す
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // --- Firestoreにデータを保存する関数 ---
  Future<void> _saveUserConditions() async {
    // フォーム全体のバリデーション
    if (_formKey.currentState!.validate()) {
      // ドロップダウンやチップ選択の必須チェック
      if (_numberOfResidents == null ||
          _distanceToStation == null ||
          _selectedBuildingAge == null ||
          _selectedLayout == null ||
          _amenities.isEmpty ||
          _desiredCity == null ||
          _desiredTown == null) {
        _showMessage('全ての必須項目を入力・選択してください (Please fill in/select all required fields).');
        return;
      }

      try {
        String uid = widget.userUid;

        // 保存時に日本語部分のみを抽出して格納
        Map<String, dynamic> conditionsData = {
          'desiredConditions': {
            'rentRangeMin': _currentRentRange.start.round(),
            'rentRangeMax': _currentRentRange.end.round(),
            'numberOfResidents': _extractJapanese(_numberOfResidents!), // 日本語抽出
            'distanceToStation': _extractJapanese(_distanceToStation!), // 日本語抽出
            'buildingAge': _extractJapanese(_selectedBuildingAge!), // 日本語抽出
            'selectedLayout': _selectedLayout!, // これは日本語のみなのでそのまま
            'amenities': _amenities.map((e) => _extractJapanese(e)).toList(), // 各要素から日本語抽出
            'city': _desiredCity!, // AreaSelectorで既に日本語のみになっているはず
            'town': _desiredTown!, // AreaSelectorで既に日本語のみになっているはず
          },
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('user_ID').doc(uid).update(conditionsData);

        _showMessage('希望条件が保存されました！ (Desired conditions saved successfully!)');
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MannerScreen()));
      } catch (e) {
        _showMessage('条件の保存に失敗しました: ${e.toString()} (Failed to save conditions: ${e.toString()})');
      }
    } else {
      _showMessage('入力にエラーがあります。全ての項目を正しく入力してください。 (There are errors in the input. Please fill in all fields correctly.)');
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
                  min: 0,
                  max: 200000,
                  divisions: 20,
                  labels: RangeLabels(
                    NumberFormat('#,###').format(_currentRentRange.start.round()),
                    NumberFormat('#,###').format(_currentRentRange.end.round()),
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
                    '${NumberFormat('#,###').format(_currentRentRange.start.round())}円 ～ ${NumberFormat('#,###').format(_currentRentRange.end.round())}円',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainColor),
                  ),
                ),
                const SizedBox(height: 20),

                // 希望エリア
                _buildSubSectionTitle('Desired Area', '希望エリア（単一）'),
                const SizedBox(height: 15),
                AreaSelector(
                  onAreasChanged: (areas) {
                    setState(() {
                      if (areas.isNotEmpty) {
                        _desiredCity = areas.first['city'];
                        _desiredTown = areas.first['town'];
                      } else {
                        _desiredCity = null;
                        _desiredTown = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                if (_desiredCity != null && _desiredTown != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      '選択中の希望エリア: ${_desiredCity} > ${_desiredTown}',
                      style: TextStyle(fontSize: 16, color: mainColor, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      '希望エリアを選択してください',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
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
                  value: _distanceToStation,
                  items: moveInOptions,
                  onChanged: (val) => setState(() => _distanceToStation = val!),
                  labelText: '選んでください',
                  icon: Icons.train,
                  mainColor: mainColor,
                ),
                const SizedBox(height: 20),

                // 築年数のドロップダウンメニュー
                _buildSubSectionTitle('Building Age', '築年数'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _selectedBuildingAge,
                  items: _buildingAgeOptions,
                  onChanged: (val) => setState(() => _selectedBuildingAge = val!),
                  labelText: '選んでください',
                  icon: Icons.business, // 建物に関連するアイコン
                  mainColor: mainColor,
                ),
                const SizedBox(height: 20),

                // --- 2. 物件の間取り・タイプ ---
                const SizedBox(height: 30),
                _buildSectionTitle('Layout & Room Types', '間取り・部屋のタイプ', mainColor, secondaryColor),
                const SizedBox(height: 15),

                // 間取り (LDK表記)
                _buildSubSectionTitle('Select desired layout (single allowed)', '間取りを選んでください（単一選択）'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: layouts.map((layout) {
                    final isSelected = (_selectedLayout == layout); // 単一選択のチェック
                    return FilterChip(
                      label: Text(layout),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedLayout = selected ? layout : null; // 選択されたら設定、解除されたらnull
                        });
                      },
                      selectedColor: secondaryColor.withOpacity(0.2),
                      checkmarkColor: mainColor,
                      labelStyle: TextStyle(color: isSelected ? mainColor : Colors.black87),
                    );
                  }).toList(),
                ),
                if (_selectedLayout == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '間取りを1つ選択してください',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 20),

                // ベッドルームとバスルームは削除済み

                // --- 3. 物件の設備・特徴 ---
                const SizedBox(height: 30),
                _buildSectionTitle('Facilities & Features', '設備・特徴', mainColor, secondaryColor),
                const SizedBox(height: 15),

                // 設備（複数選択）
                _buildSubSectionTitle('Select desired facilities and characteristics (multiple allowed)', '希望の設備と特徴を選んでください（複数選択可）'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allAmenities.map((item) {
                    final isSelected = _amenities.contains(item);
                    return FilterChip(
                      label: Text(item),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _amenities.add(item);
                          } else {
                            _amenities.remove(item);
                          }
                        });
                      },
                      selectedColor: secondaryColor.withOpacity(0.2),
                      checkmarkColor: mainColor,
                      labelStyle: TextStyle(color: _amenities.contains(item) ? mainColor : Colors.black87),
                    );
                  }).toList(),
                ),
                if (_amenities.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '希望設備を1つ以上選択してください',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                Text(
                  'Please select (multiple allowed)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // 家具・家電の有無は削除済み
                
                // 契約・入居に関する条件のセクションはコメントアウト（または削除）されたため、以下は再掲しません。
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
                    onPressed: _saveUserConditions,
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ヘルパーメソッド（共通のUI部品を生成）
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