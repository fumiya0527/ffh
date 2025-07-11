// user_condition.dart

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'manner.dart';
import 'areaselector.dart';

class UserCondition extends StatefulWidget {
  // UserRegistrationScreenから渡される個人情報
  final String familyName; // ★追加
  final String givenName;  // ★追加
  final String email;
  final String password;
  final String birthdate;
  final String nationality;
  final String phoneNumber;
  final String residenceStatus;
  final String residenceCardNumber;
  final String emergencyContactName;
  final String emergencyContactPhoneNumber;
  final String emergencyContactRelationship;
  final String stayDurationInJapan;
  final List<String> selectedLanguages; // ★追加
  final String currentAddress; // ★追加


  const UserCondition({
    super.key,
    required this.familyName, // ★required
    required this.givenName,  // ★required
    required this.email,
    required this.password,
    required this.birthdate,
    required this.nationality,
    required this.phoneNumber,
    required this.residenceStatus,
    required this.residenceCardNumber,
    required this.emergencyContactName,
    required this.emergencyContactPhoneNumber,
    required this.emergencyContactRelationship,
    required this.stayDurationInJapan,
    required this.selectedLanguages, // ★required
    required this.currentAddress,    // ★required
  });

  @override
  State<UserCondition> createState() => _UserConditionState();
}

class _UserConditionState extends State<UserCondition> {
  final _formKey = GlobalKey<FormState>();
  bool _autovalidateForm = false;

  RangeValues _currentRentRange = const RangeValues(30000, 200000);
  List<String> _selectedAreas = [];
  String? _numberOfResidents;
  String? _moveInDate;
  List<String> _selectedLayout = [];
  String? _bedrooms;
  String? _bathrooms;
  List<String> _selectedFacilities = [];
  List<String> _selectedFurnitureAppliances = [];

  // 契約・入居に関する条件の変数（UserConditionで入力させる）
  String? _guarantorSupport;
  String? _initialPaymentMethod;
  String? _contractPeriod;
  String? _screeningLanguageSupport;

  final List<String> facilities = [
    'バス・トイレ別 (Separate Bath/Toilet)',
    'エアコン (Air Conditioner)',
    'オートロック (Auto-lock)',
    'ペット可 (Pet-friendly)',
    'Wi-Fiあり (Wi-Fi available)',
    '駐車場あり (Parking available)',
    '畳なし (No Tatami rooms)',
    'IHコンロ (IH Cooktop)',
    'バルコニーあり (Balcony available)',
    'バルコニーなし (No Balcony)',
    '築年数：新築 (New construction)',
    '築年数：5年以内 (Building age: Within 5 years)',
    '築年数：10年以内 (Building age: Within 10 years)',
    '築年数：20年以内 (Building age: Within 20 years)',
    '築年数：20年以上 (Building age: More than 20 years)',
  ];

  final List<String> layouts = ['1R', '1K', '1DK','1LDK','2K', '2DK', '2LDK', '3K以上'];
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

  String? _validateDropdown(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldNameを選んでください (Please select $fieldName)';
    }
    return null;
  }

  // ★変更: _saveUserConditions メソッドで、ユーザー作成と希望条件の保存をまとめて行う
  Future<void> _saveUserConditions() async {
    setState(() {
      _autovalidateForm = true;
    });

    if (!_formKey.currentState!.validate() ||
        _selectedAreas.isEmpty || // 希望エリアが選択されているか
        _numberOfResidents == null ||
        _moveInDate == null ||
        _selectedLayout.isEmpty ||
        _selectedFacilities.isEmpty ||
        _selectedFurnitureAppliances.isEmpty ||
        _guarantorSupport == null || // 新しく必須になった項目
        _initialPaymentMethod == null || // 新しく必須になった項目
        _contractPeriod == null ||     // 新しく必須になった項目
        _screeningLanguageSupport == null // 新しく必須になった項目
    ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('すべての必須項目を入力・選択してください。 (Please fill in/select all required fields.)')),
      );
      return;
    }

    try {
      // 1. Firebase Authentication でユーザーを作成
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      // ユーザー作成が成功したら、続けてFirestoreに詳細情報を保存
      if (userCredential.user != null) {
        // 全てのユーザー情報と希望条件を結合してFirestoreに保存
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          // UserRegistrationScreenからの情報
          'uid': userCredential.user!.uid,
          'familyName': widget.familyName,
          'givenName': widget.givenName,
          'email': widget.email,
          'birthdate': widget.birthdate,
          'nationality': widget.nationality,
          'phoneNumber': widget.phoneNumber,
          'residenceStatus': widget.residenceStatus,
          'residenceCardNumber': widget.residenceCardNumber,
          'emergencyContactName': widget.emergencyContactName,
          'emergencyContactPhoneNumber': widget.emergencyContactPhoneNumber,
          'emergencyContactRelationship': widget.emergencyContactRelationship,
          'stayDurationInJapan': widget.stayDurationInJapan,
          'selectedLanguages': widget.selectedLanguages,
          'currentAddress': widget.currentAddress,
          'isOwner': false, // このユーザーはオーナーではない

          // UserConditionからの希望条件
          'desiredRentMin': _currentRentRange.start.round(),
          'desiredRentMax': _currentRentRange.end.round(),
          'desiredAreas': _selectedAreas,
          'numberOfResidents': _numberOfResidents,
          'distanceToStation': _moveInDate,
          'desiredLayout': _selectedLayout,
          'bedrooms': _bedrooms,
          'bathrooms': _bathrooms,
          'desiredFacilities': _selectedFacilities,
          'desiredFurnitureAppliances': _selectedFurnitureAppliances,
          'guarantorSupport': _guarantorSupport,
          'initialPaymentMethod': _initialPaymentMethod,
          'contractPeriod': _contractPeriod,
          'screeningLanguageSupport': _screeningLanguageSupport,
          'hasCompletedConditions': true, // ★希望条件登録完了フラグをtrueに
          'registrationTimestamp': FieldValue.serverTimestamp(), // 登録日時
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登録が完了しました！マナー動画を視聴してください。 (Registration complete! Please watch the manners video.)')),
        );

        // 登録成功後、MannerScreenへ遷移
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MannerScreen()), // MannerScreenへ遷移
            (Route<dynamic> route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = '登録に失敗しました (Registration failed)';
      if (e.code == 'weak-password') {
        message = 'パスワードが弱すぎます。6文字以上にしてください。 (The password provided is too weak. Please use 6 or more characters.)';
      } else if (e.code == 'email-already-in-use') {
        message = 'このメールアドレスは既に使用されています。 (The email address is already in use by another account.)';
      } else if (e.code == 'invalid-email') {
        message = 'メールアドレスの形式が正しくありません。 (The email address is not valid.)';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: ${e.toString()} (An error occurred: ${e.toString()})')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final Color mainBackgroundColor = const Color(0xFFEFF7F6);
    final Color mainColor = Colors.teal[800]!;
    final Color secondaryColor = Colors.teal;

    // これらの変数は build メソッド内で使用されるため、このスコープで定義します。
    // onConfirm/onChanged で setState する際に値が更新されます。
    _guarantorSupport; // 明示的な初期化がないが、DropdownButtonFormFieldのvalueにセットされる
    _initialPaymentMethod;
    _contractPeriod;
    _screeningLanguageSupport;

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
            autovalidateMode: _autovalidateForm ? AutovalidateMode.always : AutovalidateMode.disabled,
            child: ListView(
              children: [
                _buildSectionTitle('Basic Preferences', '基本的な希望条件', mainColor, secondaryColor),
                const SizedBox(height: 15),

                _buildSubSectionTitle('Monthly Rent Range (JPY)', '家賃範囲（円）'),
                const SizedBox(height: 8),
                RangeSlider(
                  values: _currentRentRange,
                  min: 0,
                  max: 200000,
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

                _buildSubSectionTitle('Desired Areas (multiple allowed)', '希望エリア（いくつでもOK）'),
                const SizedBox(height: 15),
                AreaSelector(
                  onAreasChanged: (newAreas) {
                    setState(() {
                      _selectedAreas = newAreas;
                    });
                  },
                  initialSelectedAreas: _selectedAreas,
                ),
                if (_autovalidateForm && _selectedAreas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Text(
                      '希望エリアを1つ以上選択してください (Please select at least one desired area)',
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 20),

                _buildSubSectionTitle('Number of Residents', '居住予定人数'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _numberOfResidents,
                  items: numberOfResidentsOptions,
                  onChanged: (val) => setState(() => _numberOfResidents = val!),
                  labelText: '選んでください',
                  icon: Icons.people,
                  mainColor: mainColor,
                  validator: (val) => _validateDropdown(val, '居住予定人数'),
                ),
                const SizedBox(height: 20),

                _buildSubSectionTitle('Distance from station', '駅からの距離'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _moveInDate,
                  items: moveInOptions,
                  onChanged: (val) => setState(() => _moveInDate = val!),
                  labelText: '選んでください',
                  icon: Icons.train,
                  mainColor: mainColor,
                  validator: (val) => _validateDropdown(val, '駅からの距離'),
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Layout & Room Types', '間取り・部屋のタイプ', mainColor, secondaryColor),
                const SizedBox(height: 15),

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
                if (_autovalidateForm && _selectedLayout.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Text(
                      '間取りを1つ以上選択してください (Please select at least one layout)',
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 20),

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

                _buildSectionTitle('Facilities & Features', '設備・特徴', mainColor, secondaryColor),
                const SizedBox(height: 15),

                _buildSubSectionTitle('Select desired facilities and characteristics (multiple allowed)', '希望の設備と特徴を選んでください（複数選択可）'),
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
                if (_autovalidateForm && _selectedFacilities.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Text(
                      '設備・特徴を1つ以上選択してください (Please select at least one facility/feature)',
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                    ),
                  ),
                Text(
                  'Please select (multiple allowed)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

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
                if (_autovalidateForm && _selectedFurnitureAppliances.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Text(
                      '家具・家電の有無を選択してください (Please select furniture/appliances option)',
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                    ),
                  ),
                Text(
                  'Please select',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Contract & Move-in Conditions', '契約・入居に関する条件', mainColor, secondaryColor),
                const SizedBox(height: 15),
                _buildSubSectionTitle('Guarantor / Guarantor Company Support', '保証人 / 保証会社サポート'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _guarantorSupport,
                  items: guarantorOptions,
                  onChanged: (val) => setState(() => _guarantorSupport = val!),
                  labelText: '選んでください',
                  icon: Icons.security,
                  mainColor: mainColor,
                  validator: (val) => _validateDropdown(val, '保証人/保証会社サポート'),
                ),
                const SizedBox(height: 20),

                _buildSubSectionTitle('Initial Payment Method', '初期費用の支払い方法'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _initialPaymentMethod,
                  items: paymentMethodOptions,
                  onChanged: (val) => setState(() => _initialPaymentMethod = val!),
                  labelText: '選んでください',
                  icon: Icons.payment,
                  mainColor: mainColor,
                  validator: (val) => _validateDropdown(val, '初期費用の支払い方法'),
                ),
                const SizedBox(height: 20),

                _buildSubSectionTitle('Contract Period', '契約期間'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _contractPeriod,
                  items: contractPeriodOptions,
                  onChanged: (val) => setState(() => _contractPeriod = val!),
                  labelText: '選んでください',
                  icon: Icons.calendar_today,
                  mainColor: mainColor,
                  validator: (val) => _validateDropdown(val, '契約期間'),
                ),
                const SizedBox(height: 20),

                _buildSubSectionTitle('Screening Language Support', '入居審査の言語サポート'),
                const SizedBox(height: 8),
                _buildDropdownFormField(
                  value: _screeningLanguageSupport,
                  items: screeningLanguageOptions,
                  onChanged: (val) => setState(() => _screeningLanguageSupport = val!),
                  labelText: '選んでください',
                  icon: Icons.translate,
                  mainColor: mainColor,
                  validator: (val) => _validateDropdown(val, '入居審査の言語サポート'),
                ),
                const SizedBox(height: 40),

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
                    onPressed: _saveUserConditions, // ★変更なし: 希望条件保存メソッドを呼び出す
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
    String? Function(String?)? validator,
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
      items: items
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}

