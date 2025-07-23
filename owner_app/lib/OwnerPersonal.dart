import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart'; // クリップボード機能のために追加
import 'package:url_launcher/url_launcher.dart'; // 電話をかける機能のために追加

class OwnerPersonalInfoScreen extends StatefulWidget {
  final String ownerId;
  const OwnerPersonalInfoScreen({super.key, required this.ownerId});

  @override
  State<OwnerPersonalInfoScreen> createState() => _OwnerPersonalInfoScreenState();
}

class _OwnerPersonalInfoScreenState extends State<OwnerPersonalInfoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ja_JP');
  }

  /// Zoomリンク入力用のダイアログを表示する関数
  Future<String?> _showSendUrlDialog() async {
    final urlController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('オンライン面談URLを送信'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(labelText: '面談用のURLを入力', hintText: 'https://zoom.us/...', border: OutlineInputBorder()),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('キャンセル')),
            ElevatedButton(
              onPressed: () {
                if (urlController.text.trim().isEmpty) return;
                Navigator.of(context).pop(urlController.text.trim());
              },
              child: const Text('送信'),
            ),
          ],
        );
      },
    );
  }

  /// スケジュールのステータスを更新するメソッド
  Future<void> _updateScheduleStatus({
    required String userId,
    required Map<String, dynamic> scheduleToUpdate,
    required String newStatus,
    Timestamp? confirmedTime,
  }) async {
    String? zoomLink;
    if (newStatus == 'confirmed') {
      zoomLink = await _showSendUrlDialog();
      if (zoomLink == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('URL送信がキャンセルされました。')));
        return;
      }
    }

    try {
      final userRef = _firestore.collection('user_ID').doc(userId);
      final userDoc = await userRef.get();
      if (!userDoc.exists) throw Exception("ユーザーが見つかりません");

      final List<dynamic> currentCalendar = userDoc.data()?['UserCalendar'] ?? [];
      final List<Map<String, dynamic>> newCalendar = [];
      bool found = false;

      for (var item in currentCalendar) {
        final scheduleMap = Map<String, dynamic>.from(item);
        if (!found && scheduleMap['propertyId'] == scheduleToUpdate['propertyId']) {
          scheduleMap['status'] = newStatus;
          if (confirmedTime != null) scheduleMap['confirmedTime'] = confirmedTime;
          if (zoomLink != null) scheduleMap['zoomLink'] = zoomLink;
          found = true;
        }
        newCalendar.add(scheduleMap);
      }

      if (found) {
        await userRef.update({'UserCalendar': newCalendar});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(newStatus == 'confirmed' ? '日程を確定し、URLを送信しました。' : '再調整を依頼しました。')),
          );
        }
      } else {
         throw Exception("更新対象のスケジュールが見つかりません");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('user_ID').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('エラー: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('ユーザーが存在しません。'));

          final List<Map<String, dynamic>> pendingRequests = [];
          final List<Map<String, dynamic>> confirmedSchedules = [];

          for (var userDoc in snapshot.data!.docs) {
            final userData = userDoc.data() as Map<String, dynamic>;
            final userCalendar = userData['UserCalendar'] as List<dynamic>? ?? [];
            
            for (var scheduleItem in userCalendar) {
              final scheduleMap = scheduleItem as Map<String, dynamic>;
              if (scheduleMap['ownerId'] == widget.ownerId) {
                final requestData = {
                  'userId': userDoc.id,
                  'userName': "${userData['familyName'] ?? ''} ${userData['givenName'] ?? ''}",
                  'scheduleData': scheduleMap,
                };
                if (scheduleMap['status'] == 'requested') {
                  pendingRequests.add(requestData);
                } else if (scheduleMap['status'] == 'confirmed') {
                  confirmedSchedules.add(requestData);
                }
              }
            }
          }

          if (pendingRequests.isEmpty && confirmedSchedules.isEmpty) {
            return const Center(child: Text('日程調整リクエストはまだありません。'));
          }
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pendingRequests.isNotEmpty) ...[
                _buildSectionHeader('対応が必要なリクエスト', pendingRequests.length, Colors.orange),
                ...pendingRequests.map((request) => _buildRequestedCard(request)).toList(),
                const SizedBox(height: 24),
              ],
              if (confirmedSchedules.isNotEmpty) ...[
                _buildSectionHeader('確定済みの予定', confirmedSchedules.length, Colors.green),
                ...confirmedSchedules.map((request) => _buildConfirmedCard(request)).toList(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: Text(count.toString(), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _buildRequestedCard(Map<String, dynamic> request) {
    final String userId = request['userId'];
    final String userName = request['userName'];
    final Map<String, dynamic> scheduleData = request['scheduleData'];
    final String propertyId = scheduleData['propertyId'];
    final List<Timestamp> desiredTimes = (scheduleData['desiredTimes'] as List<dynamic>).map((t) => t as Timestamp).toList();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('properties').doc(propertyId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('物件...');
            final propertyName = (snapshot.data!.data() as Map<String, dynamic>)['propertyName'] ?? '不明';
            return Text('物件: $propertyName', style: const TextStyle(color: Colors.grey));
          },
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('希望日時:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...desiredTimes.map((ts) {
                  final dt = ts.toDate();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("・ ${DateFormat('yyyy/MM/dd (E) HH:mm', 'ja_JP').format(dt)}"),
                        ElevatedButton(
                          child: const Text('確定'),
                          onPressed: () => _updateScheduleStatus(
                            userId: userId, scheduleToUpdate: scheduleData,
                            newStatus: 'confirmed', confirmedTime: ts,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    icon: const Icon(Icons.sync_problem),
                    label: const Text('再調整を依頼する'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => _updateScheduleStatus(
                      userId: userId, scheduleToUpdate: scheduleData, newStatus: 'rejected',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedCard(Map<String, dynamic> request) {
    final String userId = request['userId'];
    final String userName = request['userName'];
    final Map<String, dynamic> scheduleData = request['scheduleData'];
    final DateTime confirmedTime = (scheduleData['confirmedTime'] as Timestamp).toDate();
    final String zoomLink = scheduleData['zoomLink'];

    return Card(
      elevation: 1,
      color: Colors.green[50],
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ]),
            const Divider(height: 20),
            _buildInfoRow(Icons.calendar_today, '確定日時', DateFormat('yyyy/MM/dd (E) HH:mm', 'ja_JP').format(confirmedTime)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.link, 'Zoom URL', zoomLink, isLink: true),
            const Divider(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.person_search),
                label: const Text('ユーザーの詳細を見る'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  side: BorderSide(color: Theme.of(context).primaryColor)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailsScreen(userId: userId),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 2),
              if (isLink)
                SelectableText(value, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline))
              else
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        if (isLink)
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('URLをコピーしました')));
            },
          ),
      ],
    );
  }
}

// ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
// ★ 追加: ユーザーの詳細情報を表示するための新しい画面 (このファイル内に直接記述) ★
// ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
class UserDetailsScreen extends StatelessWidget {
  final String userId;

  const UserDetailsScreen({super.key, required this.userId});

  // 電話をかける、またはSMSを送信する関数
  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー詳細情報'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('user_ID').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('エラー: ${snapshot.error}'));
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text('ユーザー情報が見つかりません。'));

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String fullName = "${userData['familyName'] ?? ''} ${userData['givenName'] ?? ''}";

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionHeader(context, fullName),
              _buildDetailCard([
                _buildDetailRow('メールアドレス', userData['email'] ?? '未登録'),
                _buildDetailRow('電話番号', userData['phoneNumber'] ?? '未登録', isPhone: true, onPhoneTap: () => _launchPhone(userData['phoneNumber'] ?? '')),
                _buildDetailRow('国籍', userData['nationality'] ?? '未登録'),
                _buildDetailRow('生年月日', userData['birthdate'] ?? '未登録'),
                _buildDetailRow('現在の住所', userData['currentAddress'] ?? '未登録'),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader(context, '在留資格情報'),
              _buildDetailCard([
                _buildDetailRow('在留資格', userData['residenceStatus'] ?? '未登録'),
                _buildDetailRow('在留カード番号', userData['residenceCardNumber'] ?? '未登録'),
                _buildDetailRow('日本での滞在期間', userData['stayDurationInJapan'] ?? '未登録'),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader(context, '緊急連絡先'),
              _buildDetailCard([
                _buildDetailRow('氏名', userData['emergencyContactName'] ?? '未登録'),
                _buildDetailRow('続柄', userData['emergencyContactRelationship'] ?? '未登録'),
                _buildDetailRow('電話番号', userData['emergencyContactPhoneNumber'] ?? '未登録', isPhone: true, onPhoneTap: () => _launchPhone(userData['emergencyContactPhoneNumber'] ?? '')),
              ]),
            ],
          );
        },
      ),
    );
  }

  // --- UI表示用のヘルパーウィジェット ---
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPhone = false, VoidCallback? onPhoneTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: Colors.grey[700]))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
          if (isPhone && value != '未登録')
            IconButton(icon: const Icon(Icons.phone, color: Colors.blue), onPressed: onPhoneTap),
        ],
      ),
    );
  }
}
