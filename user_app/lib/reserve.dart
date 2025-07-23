import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'house_select.dart';
import 'areaselector.dart';
import 'user_condition.dart';
import 'user_regist.dart';

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
  bool _isLoading = false;

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

  // ▼▼▼ この関数を修正しました ▼▼▼
  Future<void> _submitScheduleRequest() async {
    if (_selectedSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('希望日時を1つ以上選択してください。')));
      return;
    }
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ログインが必要です。')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = FirebaseFirestore.instance;
      final userDocRef = db.collection('user_ID').doc(currentUser.uid);

      // --- 1. ユーザーの現在のカレンダー情報を取得 ---
      final userDoc = await userDocRef.get();
      final List<dynamic> userCalendar = (userDoc.data()?['UserCalendar'] as List<dynamic>?) ?? [];
      
      // --- 2. この物件の予定が既に存在するか探す ---
      int scheduleIndex = userCalendar.indexWhere((s) => s['propertyId'] == widget.propertyId);

      // --- 3. 新しい申請情報を作成 ---
      final newScheduleData = {
        'propertyId': widget.propertyId,
        'ownerId': widget.ownerId,
        'desiredTimes': _selectedSlots.map((dt) => Timestamp.fromDate(dt)).toList(),
        'status': 'requested',
        'confirmedTime': null,
        'zoomLink': '',
      };

      // --- 4. 既存の予定を更新するか、新規で追加するかを判断 ---
      if (scheduleIndex != -1) {
        // 存在する場合 (再調整) は、その予定を更新
        userCalendar[scheduleIndex] = newScheduleData;
      } else {
        // 存在しない場合 (新規) は、リストに新しい予定を追加
        userCalendar.add(newScheduleData);
      }

      // --- 5. データベースを更新 ---
      final batch = db.batch();

      // 操作①: 更新されたカレンダーリストでユーザー情報を更新
      batch.update(userDocRef, {'UserCalendar': userCalendar});
      
      // 操作②: 新規の場合のみ、承認リストからIDを削除
      if (scheduleIndex == -1) {
        final propertyDocRef = db.collection('properties').doc(widget.propertyId);
        batch.update(propertyDocRef, {
          'user_license': FieldValue.arrayRemove([currentUser.uid])
        });
      }

      await batch.commit();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  // ▲▲▲ ここまで修正 ▲▲▲

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('面談の希望日時を選択 (Select Interview Times)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _selectedSlots.isEmpty
                  ? const Center(child: Text('下のボタンから希望日時を追加してください。\n(最大3つまで)\n\nPlease add desired times from the button below.\n(Up to 3 slots available)'))
                  : ListView.builder(
                      itemCount: _selectedSlots.length,
                      itemBuilder: (context, index) {
                        final slot = _selectedSlots[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
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
                label: const Text('希望日時を追加 (Add a time slot)'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: _selectedSlots.length < 3 && !_isLoading ? _pickDateTime : null,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitScheduleRequest,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('この内容で希望を送信 (Send Request)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}