import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'reserve.dart'; // ScheduleRequestScreen があるファイル
import 'start.dart';
// import 'login_screen.dart'; // ★注意: あなたのプロジェクトのログイン画面ファイルをインポートしてください

class HouseSelectScreen extends StatelessWidget {
  const HouseSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ユーザー向け物件アプリ',
      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AppRootScreen(),
    );
  }
}

class AppRootScreen extends StatefulWidget {
  const AppRootScreen({super.key});

  @override
  State<AppRootScreen> createState() => _AppRootScreenState();
}

// ▼▼▼ このウィジェットを修正しました ▼▼▼
class _AppRootScreenState extends State<AppRootScreen> {
  int _selectedIndex = 0;
  
  // AppBarのタイトルを動的に変更するためのリスト
  static const List<String> _widgetTitles = <String>[
    '物件一覧',
    'あなたの状況',
    '設定',
  ];

  static const List<Widget> _widgetOptions = <Widget>[
    MainScreen(),
    UserInterestStatusScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ログアウト処理の関数
  Future<void> _logout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ログアウトの確認'),
          content: const Text('本当にログアウトしますか？'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('ログアウト'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const StartScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 共通のAppBarをここに追加
      appBar: AppBar(
        title: Text(_widgetTitles.elementAt(_selectedIndex)),
        actions: [
          // 右上のログアウトアイコンボタン
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '物件を見る'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'あなたの状況'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
// ▲▲▲ ここまで修正 ▲▲▲

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // (中身は変更ありません)
  Map<String, dynamic>? _userDesiredConditions;
  List<Map<String, dynamic>> _matchingProperties = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<List<List<String>>> propertyImages = [
    [['assets/home1.jpg', 'assets/home1_1.jpg', 'assets/home1_2.jpg'] ,['PHIgANlo1dljSxOT2ymB']],
    [['assets/home2.jpg', 'assets/home2_1.jpg'],[ 'UYhCХEd5qR0tCsG3o2РС']],
    [['assets/home3.jpg', 'assets/home3_1.jpg'],[ 'twWytYCGkUhpHnfpvZQf']],
  ];
  int currentIndex = 0;
  @override
  void initState() { super.initState(); _loadUserAndProperties(); }
  Future<void> _fetchUserDesiredConditions() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;
    try {
      DocumentSnapshot userDoc = await _firestore.collection('user_ID').doc(currentUser.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (mounted) { setState(() { _userDesiredConditions = userData['desiredConditions'] as Map<String, dynamic>?; }); }
      }
    } catch (e) { print('ユーザー希望条件の取得中にエラー: $e'); }
  }
  Future<void> _filterProperties() async {
    if (_userDesiredConditions == null) return;
    try {
      QuerySnapshot propertiesSnapshot = await _firestore.collection('properties').get();
      List<Map<String, dynamic>> allProperties = propertiesSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['propertyId'] = doc.id;
        return data;
      }).toList();
      List<Map<String, dynamic>> tempMatchingProperties = [];
      for (var property in allProperties) {
        if (_checkPropertyMatches(property, _userDesiredConditions!)) { tempMatchingProperties.add(property); }
      }
      if (mounted) { setState(() => _matchingProperties = tempMatchingProperties); }
    } catch (e) { print('物件のフィルタリング中にエラー: $e'); }
  }
  bool _checkPropertyMatches(Map<String, dynamic> property, Map<String, dynamic> desired) {
    int propertyRent = property['rent'] as int? ?? 0;
    int desiredRentMin = desired['rentRangeMin'] as int? ?? 0;
    int desiredRentMax = desired['rentRangeMax'] as int? ?? 200000;
    if (propertyRent < desiredRentMin || propertyRent > desiredRentMax) return false;
    String propertyCity = property['city'] as String? ?? '';
    String desiredCity = desired['city'] as String? ?? '';
    if (desiredCity.isNotEmpty && propertyCity != desiredCity) return false;
    return true;
  }
  Future<void> _loadUserAndProperties() async {
    await _fetchUserDesiredConditions();
    if (_userDesiredConditions != null) { await _filterProperties(); }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(title: const Text('物件一覧')), // ← この行を削除
      body: Column(
        children: [
          Hero(
            tag: 'imageHero',
            child: GestureDetector(
              onTap: () {
                final List<String> currentPropertyImagePaths = propertyImages[currentIndex][0].where((path) => path.endsWith('.jpg')).toList();
                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(
                  initialImagePath: currentPropertyImagePaths.isNotEmpty ? currentPropertyImagePaths[0] : '',
                  propertyImages: propertyImages[currentIndex][0] + propertyImages[currentIndex][1],
                )));
              },
              child: SizedBox(
                width: screenWidth * 0.5,
                child: AspectRatio(aspectRatio: 16 / 9, child: Image.asset(propertyImages[currentIndex][0][0], fit: BoxFit.cover)),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () => setState(() => currentIndex = (currentIndex + propertyImages.length - 1) % propertyImages.length), child: const Text('前の物件へ')),
              const SizedBox(width: 20),
              ElevatedButton(onPressed: () => setState(() => currentIndex = (currentIndex + 1) % propertyImages.length), child: const Text('次の物件へ')),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('合致する物件:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_matchingProperties.isEmpty) const Text('該当する物件はありません。')
                  else Expanded(child: ListView.builder(itemCount: _matchingProperties.length, itemBuilder: (context, index) {
                           return Card(margin: const EdgeInsets.symmetric(vertical: 4), child: ListTile(
                               title: Text(_matchingProperties[index]['propertyName'] ?? '名称不明'),
                               subtitle: Text('${_matchingProperties[index]['city'] ?? ''} ${_matchingProperties[index]['rent']?.toString() ?? ''}円'),
                             ),
                           );
                        }),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// (DetailScreenのコードは変更ありません)
class DetailScreen extends StatefulWidget {
  final String initialImagePath;
  final List<String> propertyImages;
  const DetailScreen({super.key, required this.initialImagePath, required this.propertyImages});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}
class _DetailScreenState extends State<DetailScreen> {
  late int _currentImageIndex;
  late List<String> _validImagePaths;
  late String _propertyId;
  @override
  void initState() {
    super.initState();
    _validImagePaths = widget.propertyImages.where((path) => path.endsWith('.jpg')).toList();
    _propertyId = widget.propertyImages.isNotEmpty ? widget.propertyImages.last : 'no_id';
    _currentImageIndex = _validImagePaths.indexOf(widget.initialImagePath);
    if (_currentImageIndex == -1) _currentImageIndex = 0;
  }
  void _goToPreviousImage() => setState(() => _currentImageIndex = (_currentImageIndex - 1 + _validImagePaths.length) % _validImagePaths.length);
  void _goToNextImage() => setState(() => _currentImageIndex = (_currentImageIndex + 1) % _validImagePaths.length);
  Future<void> _sendInterestToFirebase(BuildContext context) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    try {
      await FirebaseFirestore.instance.collection('properties').doc(_propertyId).update({
        'userHope': FieldValue.arrayUnion([currentUser.uid]),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) { print('興味ありの送信に失敗: $e'); }
  }
 @override
 Widget build(BuildContext context) {
   final screenWidth = MediaQuery.of(context).size.width;
   return Scaffold(
     appBar: AppBar(title: const Text('物件詳細'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context),),),
     body: Center(child: SingleChildScrollView(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
             Stack(alignment: Alignment.center, children: [
                 Hero(tag: 'imageHero', child: SizedBox(width: screenWidth * 0.9, child: AspectRatio(aspectRatio: 16 / 9,
                       child: _validImagePaths.isNotEmpty ? Image.asset(_validImagePaths[_currentImageIndex], fit: BoxFit.cover) : const Center(child: Text('表示できる画像がありません。')),),),),
                 if (_validImagePaths.length > 1) Positioned(left: 10, child: IconButton(onPressed: _goToPreviousImage, icon: const Icon(Icons.arrow_back_ios, size: 40, color: Colors.orange,),),),
                 if (_validImagePaths.length > 1) Positioned(right: 10, child: IconButton(onPressed: _goToNextImage, icon: const Icon(Icons.arrow_forward_ios, size: 40, color: Colors.orange,),),),
               ],),
             const SizedBox(height: 20),
             Text(_validImagePaths.isNotEmpty ? '${_currentImageIndex + 1} / ${_validImagePaths.length}' : '画像なし', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
             const SizedBox(height: 20),
             Text('物件ID: $_propertyId', style: const TextStyle(fontSize: 14, color: Colors.grey),),
             const Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), child: Text('この物件は、広々としたリビングと日当たりの良いバルコニーが特徴です。静かな住宅街に位置し、近くには公園やショッピング施設があります。詳細は後ほど担当者からご連絡いたします。', textAlign: TextAlign.center, style: TextStyle(fontSize: 16),),),
             const SizedBox(height: 30),
             ElevatedButton(
               onPressed: () => _sendInterestToFirebase(context),
               style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18), backgroundColor: Colors.green, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
               child: const Text('この物件に興味あり！'),
             ),
           ],),),),
   );
 }
}

class UserInterestStatusScreen extends StatefulWidget {
  const UserInterestStatusScreen({super.key});
  @override
  State<UserInterestStatusScreen> createState() => _UserInterestStatusScreenState();
}

class _UserInterestStatusScreenState extends State<UserInterestStatusScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Widget _getPropertyName(String propertyId, {TextStyle? style}) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('properties').doc(propertyId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Text('物件...', style: style);
        final data = snapshot.data!.data() as Map<String, dynamic>;
        return Text(data['propertyName'] ?? '名称不明', style: style);
      },
    );
  }
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) { await launchUrl(uri, mode: LaunchMode.externalApplication); }
  }
  Widget _buildSectionHeader(String title, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('ログインが必要です。')));
    }
    return Scaffold(
      // appBar: AppBar(title: const Text('あなたの状況')), // ← この行を削除
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('user_ID').doc(currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
                final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final List<dynamic> userCalendar = userData['UserCalendar'] ?? [];
                final confirmed = userCalendar.where((s) => s['status'] == 'confirmed').toList();
                final reschedule = userCalendar.where((s) => s['status'] == 'rejected').toList();
                final requested = userCalendar.where((s) => s['status'] == 'requested').toList();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (confirmed.isNotEmpty) ...[
                      _buildSectionHeader('🗓️ 確定済みの予定', Colors.blue),
                      ...confirmed.map((s) => _buildConfirmedCard(s)).toList(),
                      const SizedBox(height: 24),
                    ],
                    if (reschedule.isNotEmpty) ...[
                      _buildSectionHeader('🟡 再調整が必要な予定', Colors.amber),
                      ...reschedule.map((s) => _buildRescheduleCard(s)).toList(),
                      const SizedBox(height: 24),
                    ],
                    if (requested.isNotEmpty) ...[
                      _buildSectionHeader('送信済み・返信待ち', Colors.grey),
                      ...requested.map((s) => _buildRequestedCard(s)).toList(),
                      const SizedBox(height: 24),
                    ],
                  ],
                );
              },
            ),
            _buildSectionHeader('✅ 承認された物件', Colors.green),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('properties').where('user_license', arrayContains: currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Card(child: ListTile(title: Text('承認された物件はまだありません。')));
                return Column(children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(margin: const EdgeInsets.symmetric(vertical: 4), child: ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(data['propertyName'] ?? '名称不明'),
                        trailing: ElevatedButton(child: const Text('日程調整へ'),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScheduleRequestScreen(propertyId: doc.id, ownerId: data['ownerId']))),),),);
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 30),
            _buildSectionHeader('⏳ 「興味あり」返答待ちの物件', Colors.orange),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('properties').where('userHope', arrayContains: currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Card(child: ListTile(title: Text('返答待ちの物件はありません。')));
                return Column(children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(margin: const EdgeInsets.symmetric(vertical: 4), child: ListTile(leading: const Icon(Icons.hourglass_top, color: Colors.orange), title: Text(data['propertyName'] ?? '名称不明'),),);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
 Widget _buildConfirmedCard(Map<String, dynamic> schedule) {
  final DateTime time = (schedule['confirmedTime'] as Timestamp).toDate();
  final String link = schedule['zoomLink'] ?? '';
  return Card(margin: const EdgeInsets.symmetric(vertical: 6), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _getPropertyName(schedule['propertyId']),
        const Divider(height: 20),
        Text('確定日時: ${DateFormat('yyyy/MM/dd (E) HH:mm', 'ja_JP').format(time)}'),
        const SizedBox(height: 12),
        const Text('面談URL:', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        if (link.isNotEmpty) InkWell(onTap: () => _launchURL(link), child: Text(link, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),)
        else const Text('URLはまだ発行されていません'),
      ],),),);
}
  Widget _buildRescheduleCard(Map<String, dynamic> schedule) {
    return Card(margin: const EdgeInsets.symmetric(vertical: 6), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _getPropertyName(schedule['propertyId']),
        const SizedBox(height: 8),
        const Text('オーナーから日程の再調整依頼が届きました。'),
        const SizedBox(height: 10),
        ElevatedButton.icon(icon: const Icon(Icons.calendar_today), label: const Text('日程を再調整する'),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScheduleRequestScreen(propertyId: schedule['propertyId'], ownerId: schedule['ownerId']))),),
      ])));
  }
  Widget _buildRequestedCard(Map<String, dynamic> schedule) {
    return Card(margin: const EdgeInsets.symmetric(vertical: 6), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _getPropertyName(schedule['propertyId']),
        const SizedBox(height: 8),
        const Text('オーナーからの返信をお待ちください。'),
      ])));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(title: const Text('設定')), // ← この行を削除
      body: Center(child: Text('設定画面です')),
    );
  }
}