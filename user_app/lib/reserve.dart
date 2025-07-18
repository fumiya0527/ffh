import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ScheduleRequestScreen extends StatefulWidget {
  final String propertyId;
  final String ownerId;

  const ScheduleRequestScreen({
    super.key,
    required this.propertyId,
    required this.ownerId,
  });

  @override
  State<ScheduleRequestScreen> createState() => _ScheduleRequestScreenState();
}

class _ScheduleRequestScreenState extends State<ScheduleRequestScreen> {
  final List<DateTime> _selectedSlots = [];

  Future<void> _pickDateTime() async {
    if (_selectedSlots.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('希望日時は3つまで選択できます。')));
      return;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime == null) return;

    setState(() {
      final selectedDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
      _selectedSlots.add(selectedDateTime);
    });
  }

  Future<void> _submitScheduleRequest() async {
    if (_selectedSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('希望日時を1つ以上選択してください。')));
      return;
    }
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance.collection('schedules').add({
        'propertyId': widget.propertyId,
        'ownerId': widget.ownerId,
        'userId': currentUser.uid,
        'desiredTimes': _selectedSlots.map((dt) => Timestamp.fromDate(dt)).toList(),
        'status': 'requested', // ステータスを「申請済み」に
        'zoomLink': null,
        'confirmedTime': null, // 確定日時はまだnull
        'createdAt': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('日程調整の希望を送信しました'),
            content: const Text('オーナーからの連絡をお待ちください。'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('面談の希望日時を選択')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _selectedSlots.isEmpty
                  ? const Center(child: Text('下のボタンから希望日時を追加してください。\n(最大3つまで)'))
                  : ListView.builder(
                      itemCount: _selectedSlots.length,
                      itemBuilder: (context, index) {
                        final slot = _selectedSlots[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text(DateFormat('yyyy年MM月dd日 (E)', 'ja_JP').format(slot)),
                            subtitle: Text(DateFormat('HH:mm').format(slot)),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => setState(() => _selectedSlots.removeAt(index)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('希望日時を追加'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: _selectedSlots.length < 3 ? _pickDateTime : null,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitScheduleRequest,
                child: const Text('この内容で希望を送信'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}