

import 'package:flutter/material.dart';
import 'package:ffh/areaselector.dart';

class UserCondition extends StatefulWidget {
  final String name;
  final String birthdate;
  final String email;
  final String password;
  final String nationality;

  const UserCondition({
    super.key,
    required this.name,
    required this.birthdate,
    required this.email,
    required this.password,
    required this.nationality,
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

  final List<String> layouts = ['1R', '1K', '1DK', '2DK', '2LDK', '3LDK以上'];
  final List<String> facilities = ['バス・トイレ別', 'エアコン', 'オートロック', 'ペット可'];
  final List<String> moveInOptions = ['1分以内', '5分以内', '10分以内','15分以内','20分以上'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('希望条件の入力')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('希望エリア（複数可）', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const AreaSelector(),

              const SizedBox(height: 24),
              const Text('希望家賃上限（円）'),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '例: 70000'),
                onChanged: (val) => _rentMax = val,
              ),

              const SizedBox(height: 24),
              const Text('希望の間取り（複数可）'),
              Wrap(
                spacing: 8,
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
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              const Text('希望の設備（複数可）'),
              Wrap(
                spacing: 8,
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
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              const Text('駅からの距離'),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(hintText: '選択してください'),
                value: _moveInDate,
                items: moveInOptions
                    .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                    .toList(),
                onChanged: (val) => setState(() => _moveInDate = val),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('条件登録完了！')),
                    );
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
                child: const Text('登録完了'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
