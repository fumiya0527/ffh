import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; 
import 'firebase_options.dart';
import 'Auth.dart';
import 'OwnerHomeScreen.dart';

//オーナー物件追加クラス
class AddPropertyScreen extends StatelessWidget {
  const AddPropertyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PropertyRegistrationScreen()),
          );
        },
        icon: const Icon(Icons.add_home),
        label: const Text('新しい物件を登録する'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}

class PropertyRegistrationScreen extends StatefulWidget {
  const PropertyRegistrationScreen({super.key});

  @override
  State<PropertyRegistrationScreen> createState() => _PropertyRegistrationScreenState();
}

class _PropertyRegistrationScreenState extends State<PropertyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _autovalidateForm = false; 

  final TextEditingController _propertyNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();

  String? _selectedFloorPlan;
  final List<String> _floorPlans = ['1R', '1K', '1DK', '1LDK', '2K', '2DK', '2LDK', '3K以上'];

  String? _selectedDistanceToStation;
  final List<String> _distances = ['1分以内', '5分以内', '10分以内', '15分以内', '20分以上', 'バス利用'];

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

  void _registerProperty() async {
    print('--- _registerProperty が呼び出されました ---');
    setState(() {
      _autovalidateForm = true; 
    });

    if (_formKey.currentState!.validate() &&
        _selectedFloorPlan != null &&
        _selectedDistanceToStation != null) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('エラー: ユーザーがログインしていません。');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('物件を登録するにはログインが必要です。')),
        );
        return;
      }
      print('ログイン中のユーザーUID: ${user.uid}');

      final Map<String, dynamic> propertyData = {
        'ownerId': user.uid,
        'propertyName': _propertyNameController.text,
        'address': _addressController.text,
        'rent': int.tryParse(_rentController.text) ?? 0,
        'floorPlan': _selectedFloorPlan!,
        'distanceToStation': _selectedDistanceToStation!,
        'amenities': _amenities.where((item) => item['checked']).map((item) => item['title']).toList(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      try {
        await FirebaseFirestore.instance.collection('properties').add(propertyData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('物件情報を登録しました！')),
        );


        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => OwnerHomeScreen(currentOwnerId: user.uid)),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('物件情報の登録に失敗しました: ${e.toString()}')),
        );
      }
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
          autovalidateMode: _autovalidateForm ? AutovalidateMode.always : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: '所在地',
                  hintText: '例: 渋谷区〇〇 1-2-3',
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
              if (_autovalidateForm && _selectedFloorPlan == null)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: Text(
                    '間取りを選択してください',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16.0),

              InputDecorator(
                decoration: InputDecoration(
                  labelText: '駅からの距離',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  errorText: _autovalidateForm && _selectedDistanceToStation == null
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