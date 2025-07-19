import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 依存する他のファイルをインポートします
import 'AddProperty.dart';
import 'OwnedProperties.dart';
// import 'OwnerPersonal.dart'; // ← OwnerPersonalInfoScreenをこのファイルに持ってきたので、この行は不要になります。コメントアウトしてください。


//オーナーホーム画面クラス
class OwnerHomeScreen extends StatefulWidget {
  final String currentOwnerId;
  const OwnerHomeScreen({super.key, required this.currentOwnerId});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  int _selectedIndex = 0;

  // 表示する画面のリスト
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // BottomNavigationBarの各タブに対応する画面を定義します。
    _widgetOptions = <Widget>[
      // 1番目のタブ: 物件一覧画面
      OwnedPropertiesListScreen(currentOwnerId: widget.currentOwnerId),
      // 2番目のタブ: 物件追加画面
      const AddPropertyScreen(),
      // 3番目のタブ: オーナーの個人情報画面
      OwnerPersonalInfoScreen(ownerId: widget.currentOwnerId),
    ];
  }

  // タブがタップされたときに呼ばれるメソッド
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('オーナーダッシュボード'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ログアウトしました。')),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: '物件一覧',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_home),
            label: '物件追加',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '個人情報',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class OwnerPersonalInfoScreen extends StatelessWidget {
  final String ownerId;
  const OwnerPersonalInfoScreen({super.key, required this.ownerId});

  @override
  Widget build(BuildContext context) {
    // この画面はbody部分だけを使うのでScaffoldは不要
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '個人情報設定',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'ログイン中のオーナーID:',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              ownerId,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              '（ここにユーザー名、連絡先などの設定UIを実装予定）',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
