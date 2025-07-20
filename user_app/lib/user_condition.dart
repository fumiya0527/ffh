import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  List<String> _amenities = []; // 設備・特徴
  String? _desiredCity; // 希望エリア（単一のcityとして保存）
  String? _desiredTown; // 希望エリア（単一のtownとして保存）
  String? _selectedBuildingAge; // 築年数 (単一選択)
  
  // 全ての設備・特徴の選択肢を統合
  final List<String> allAmenities = [
    'バス・トイレ別 (Separate Bath/Toilet)', 'エアコン付き', 'オートロック (Auto-lock)',
    'ペット可 (Pet-friendly)', 'インターネット無料', '駐車場あり (Parking available)',
    '畳なし (No Tatami rooms)', 'IHコンロ (IH Cooktop)', 'バルコニーあり (Balcony available)',
    'バルコニーなし (No Balcony)',
  ];

  // 築年数の選択肢
  final List<String> _buildingAgeOptions = [
    '5年以内 (Within 5 years)', '10年以内 (Within 10 years)', '20年以内 (Within 20 years)', '20年以上 (More than 20 years)',
  ];

  final List<String> layouts = ['1R', '1K', '1DK', '1LDK', '2K', '2DK', '2LDK', '3LDK以上'];
  
  final List<String> moveInOptions = [
    '1分以内 (Within 1 min)', '5分以内 (Within 5 min)', '10分以内 (Within 10 min)',
    '15分以内 (Within 15 min)', '20分以上 (More than 20 min)'
  ];

  final List<String> numberOfResidentsOptions = [
    '1人 (1 person)', '2人 (2 people)', '3人 (3 people)', '4人 (4 people)', '5人以上 (5+ people)'
  ];

  // 英語表記を取り除くヘルパー関数
  String _extractJapanese(String text) {
    RegExp regex = RegExp(r'^(.*?)\s*\(.*?\)$');
    Match? match = regex.firstMatch(text);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!.trim();
    }
    return text.trim();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // --- Firestoreにデータを保存する関数 ---
  Future<void> _saveUserConditions() async {
    if (_formKey.currentState!.validate()) {
      if (_numberOfResidents == null || _distanceToStation == null || _selectedBuildingAge == null || _selectedLayout == null || _amenities.isEmpty || _desiredCity == null || _desiredTown == null) {
        _showMessage('全ての必須項目を入力・選択してください。');
        return;
      }

      try {
        Map<String, dynamic> conditionsData = {
          'desiredConditions': {
            'rentRangeMin': _currentRentRange.start.round(),
            'rentRangeMax': _currentRentRange.end.round(),
            'numberOfResidents': _extractJapanese(_numberOfResidents!),
            'distanceToStation': _extractJapanese(_distanceToStation!),
            'buildingAge': _extractJapanese(_selectedBuildingAge!),
            'selectedLayout': _selectedLayout!,
            'amenities': _amenities.map((e) => _extractJapanese(e)).toList(),
            'city': _desiredCity!,
            'town': _desiredTown!,
          },
          'updatedAt': FieldValue.serverTimestamp(),
          'UserCalendar': [],
          'UserRecognition': '',
          'ZoomURL': '',
        };

        await _firestore.collection('user_ID').doc(widget.userUid).update(conditionsData);

        _showMessage('希望条件が保存されました！');
        if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MannerScreen()));
        }
      } catch (e) {
        _showMessage('条件の保存に失敗しました: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = Colors.teal[800]!;
    final Color secondaryColor = Colors.teal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('希望条件を入力'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionTitle('Basic Preferences', '基本的な希望条件', mainColor, secondaryColor),
              
              _buildSubSectionTitle('Monthly Rent Range (JPY)', '家賃範囲（円）'),
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
                  setState(() => _currentRentRange = values);
                },
              ),
              Center(child: Text('${NumberFormat('#,###').format(_currentRentRange.start.round())}円 ～ ${NumberFormat('#,###').format(_currentRentRange.end.round())}円')),
              const SizedBox(height: 20),

              _buildSubSectionTitle('Desired Area', '希望エリア（単一）'),
              const SizedBox(height: 8),
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
              
              if (_desiredCity != null && _desiredTown != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '選択中の希望エリア: $_desiredCity > $_desiredTown',
                    style: TextStyle(fontSize: 16, color: mainColor, fontWeight: FontWeight.bold),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '希望エリアを選択してください',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 20),

              _buildDropdownFormField(value: _numberOfResidents, items: numberOfResidentsOptions, onChanged: (val) => setState(() => _numberOfResidents = val), labelText: '居住予定人数', icon: Icons.people, mainColor: mainColor),
              const SizedBox(height: 20),
              _buildDropdownFormField(value: _distanceToStation, items: moveInOptions, onChanged: (val) => setState(() => _distanceToStation = val), labelText: '駅からの距離', icon: Icons.train, mainColor: mainColor),
              const SizedBox(height: 20),
              _buildDropdownFormField(value: _selectedBuildingAge, items: _buildingAgeOptions, onChanged: (val) => setState(() => _selectedBuildingAge = val), labelText: '築年数', icon: Icons.business, mainColor: mainColor),
              const SizedBox(height: 30),

              _buildSectionTitle('Layout & Room Types', '間取り・部屋のタイプ', mainColor, secondaryColor),
              _buildSubSectionTitle('Select desired layout', '間取りを選んでください（単一選択）'),
              Wrap(
                spacing: 8,
                children: layouts.map((layout) => ChoiceChip(
                  label: Text(layout),
                  selected: _selectedLayout == layout,
                  onSelected: (selected) => setState(() => _selectedLayout = selected ? layout : null),
                )).toList(),
              ),
              const SizedBox(height: 30),

              _buildSectionTitle('Facilities & Features', '設備・特徴', mainColor, secondaryColor),
              _buildSubSectionTitle('Select desired facilities', '希望の設備を選んでください（複数選択可）'),
              Wrap(
                spacing: 8,
                children: allAmenities.map((item) => FilterChip(
                  label: Text(item),
                  selected: _amenities.contains(item),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) _amenities.add(item); else _amenities.remove(item);
                    });
                  },
                )).toList(),
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                ),
                onPressed: _saveUserConditions,
                child: const Text('登録する', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String englishTitle, String japaneseTitle, Color mainColor, Color secondaryColor) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(englishTitle, style: TextStyle(fontSize: 18, color: secondaryColor, fontWeight: FontWeight.w600)),
      Text(japaneseTitle, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: mainColor)),
      const Divider(height: 20, thickness: 1),
    ]);
  }

  Widget _buildSubSectionTitle(String englishTitle, String japaneseTitle) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(englishTitle, style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8))),
      Text(japaneseTitle, style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildDropdownFormField({ required String? value, required List<String> items, required ValueChanged<String?> onChanged, required String labelText, required IconData icon, required Color mainColor}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, color: mainColor),
      ),
      value: value,
      items: items.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
      onChanged: onChanged,
    );
  }
}