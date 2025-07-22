import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'reserve.dart';
import 'start.dart';

final Color mainColor = Colors.teal[800]!;
final Color secondaryColor = Colors.teal;

class HouseSelectScreen extends StatelessWidget {
  const HouseSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppRootScreen();
  }
}

class AppRootScreen extends StatefulWidget {
  const AppRootScreen({super.key});

  @override
  State<AppRootScreen> createState() => _AppRootScreenState();
}

class _AppRootScreenState extends State<AppRootScreen> {
  int _selectedIndex = 0;
  
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

  Future<void> _logout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ログアウトの確認'),
          content: const Text('本当にログアウトしますか？'),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル', style: TextStyle(color: Theme.of(context).primaryColorDark)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('ログアウト', style: TextStyle(color: Colors.red[700])),
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
      appBar: AppBar(
        title: Text(_widgetTitles.elementAt(_selectedIndex)),
        actions: [
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
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'マナー資料'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: mainColor,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Map<String, dynamic>? _userDesiredConditions;
  List<Map<String, dynamic>> _matchingProperties = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<List<String>> _imageTemplates = [
    ['assets/homedate1.jpg', 'assets/homedate1_1.jpg'],
    ['assets/homedate2.jpg', 'assets/homedate2_2.jpg'],
    ['assets/homedate3.jpg', 'assets/homedate3_1.jpg'],
    ['assets/homedate4.jpg', 'assets/homedate4_1.jpg'],
    ['assets/homedate5.jpg', 'assets/homedate5_1.jpg'],
    ['assets/homedate6.jpg', 'assets/homedate6_1.jpg'],
    ['assets/homedate7.jpg', 'assets/homedate7_1.jpg'],
    ['assets/homedate8.jpg', 'assets/homedate8_1.jpg'],
    ['assets/homedate9.jpg', 'assets/homedate9_1.jpg'],
    ['assets/homedate10.jpg', 'assets/homedate10_1.jpg'],

  ];

  List<List<List<String>>> _displayableProperties = [];
  
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

      List<List<List<String>>> newDisplayableProperties = [];
      for (int i = 0; i < tempMatchingProperties.length; i++) {
        final imagePaths = _imageTemplates[i % _imageTemplates.length];
        final propertyId = tempMatchingProperties[i]['propertyId'];
        newDisplayableProperties.add([imagePaths, [propertyId]]);
      }
      
      if (mounted) { 
        setState(() {
          _matchingProperties = tempMatchingProperties;
          _displayableProperties = newDisplayableProperties;
          currentIndex = 0;
        }); 
      }
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_displayableProperties.isNotEmpty) ...[
                Hero(
                  tag: 'imageHero',
                  child: GestureDetector(
                    onTap: () {
                      final propertyToShow = _displayableProperties[currentIndex];
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(
                        propertyData: propertyToShow,
                      )));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.asset(
                          _displayableProperties[currentIndex][0][0], // 正しくcurrentIndexの物件の画像を参照する
                          key: ValueKey(_displayableProperties[currentIndex][0][0]),     // ★キーを追加して、画像が確実に更新されるようにする
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                        )
                      ),
                    ),
                  ),
                ),

                // ▼▼▼ ここに追加 ▼▼▼
                const SizedBox(height: 16),
                Text(
                  _matchingProperties[currentIndex]['propertyName'] ?? '名称不明',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // ▲▲▲ ここまで追加 ▲▲▲
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavButton(Icons.arrow_back, '前の物件へ', () => setState(() => currentIndex = (currentIndex + _displayableProperties.length - 1) % _displayableProperties.length)),
                    _buildNavButton(Icons.arrow_forward, '次の物件へ', () => setState(() => currentIndex = (currentIndex + 1) % _displayableProperties.length)),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 100, child: Center(child: Text('条件に合う物件の写真はありません。')))
              ],

              const Divider(height: 40),
              Text('あなたに合致する物件', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainColor)),
              const SizedBox(height: 8),
              _matchingProperties.isEmpty
                  ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32.0), child: Text('該当する物件はありません。')))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _matchingProperties.length,
                      itemBuilder: (context, index) {
                        final propertyData = _matchingProperties[index];
                        final String propertyName = propertyData['propertyName'] ?? '名称不明';
                        final String propertyId = propertyData['propertyId'];
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.home_work_outlined, color: mainColor),
                            title: Text('$propertyName (ID: $propertyId)'),
                            subtitle: Text('${propertyData['city'] ?? ''} ${propertyData['rent']?.toString() ?? ''}円'),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, VoidCallback onPressed) {
    return SizedBox(height: 55, child: ElevatedButton.icon(icon: Icon(icon), label: Text(label), onPressed: onPressed));
  }
}

  Widget _buildNavButton(IconData icon, String label, VoidCallback onPressed) {
    return SizedBox(
      height: 55,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
      ),
    );
  }

  int _getRankForDistance(String? distance) {
  if (distance == null) return 999; // データがない場合は最も不利なランクに
  const distanceRank = {
    '1分以内': 1,
    '5分以内': 5,
    '10分以内': 10,
    '15分以内': 15,
    '20分以上': 20,
  };
  return distanceRank[distance] ?? 999; // マップにない場合も不利なランクに
}

int _getRankForBuildingAge(String? age) {
  if (age == null) return 999;
  const ageRank = {
    '5年以内': 5,
    '10年以内': 10,
    '20年以内': 20,
    '20年以上': 99,
  };
  return ageRank[age] ?? 999;
}

class DetailScreen extends StatefulWidget {
  final List<List<String>> propertyData; 

  const DetailScreen({
    super.key,
    required this.propertyData,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late int _currentImageIndex;
  late List<String> _imagePaths;
  late String _propertyId;

  @override
  void initState() {
    super.initState();
    _currentImageIndex = 0;
    _imagePaths = widget.propertyData[0];
    _propertyId = widget.propertyData[1].isNotEmpty ? widget.propertyData[1][0] : 'no_id';
  }

  void _goToPreviousImage() => setState(() => _currentImageIndex = (_currentImageIndex - 1 + _imagePaths.length) % _imagePaths.length);
  void _goToNextImage() => setState(() => _currentImageIndex = (_currentImageIndex + 1) % _imagePaths.length);

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
      appBar: AppBar(title: const Text('物件詳細')),
      body: Center(child: SingleChildScrollView(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Stack(alignment: Alignment.center, children: [
                  Hero(tag: 'imageHero', child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(width: screenWidth * 0.9, child: AspectRatio(aspectRatio: 16 / 9,
                          child: _imagePaths.isNotEmpty 
                              ? Image.asset(_imagePaths[_currentImageIndex], fit: BoxFit.cover) 
                              : const Center(child: Text('表示できる画像がありません。')),
                    ),),
                  ),),
                  if (_imagePaths.length > 1) Positioned(left: 10, child: IconButton(onPressed: _goToPreviousImage, icon: const Icon(Icons.arrow_back_ios, size: 40, color: Colors.white70,),),),
                  if (_imagePaths.length > 1) Positioned(right: 10, child: IconButton(onPressed: _goToNextImage, icon: const Icon(Icons.arrow_forward_ios, size: 40, color: Colors.white70,),),),
                ],),
              const SizedBox(height: 20),
              Text(_imagePaths.isNotEmpty ? '${_currentImageIndex + 1} / ${_imagePaths.length}' : '画像なし', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              const SizedBox(height: 20),
              
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('properties').doc(_propertyId).get(),
                  builder: (context, snapshot) {
                    // データ取得中の表示
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: CircularProgressIndicator(),
                      );
                    }
                    // エラーまたはデータがない場合の表示
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Text('物件情報が見つかりません'),
                      );
                    }

                    // 取得したデータから必要な情報を取り出す
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final propertyName = data['propertyName'] ?? '名称不明';
                    final rent = data['rent'] as int? ?? 0;
                    final city = data['city'] ?? '';
                    final town = data['town'] ?? '';
                    final streetAddress = data['streetAddress'] ?? ''; // ★streetAddressを追加
                    final floorPlan = data['floorPlan'] ?? '情報なし';
                    final buildingAge = data['buildingAge'] ?? '情報なし';
                    final distanceToStation = data['distanceToStation'] ?? '情報なし';
                    final amenities = (data['amenities'] as List<dynamic>?)?.join(', ') ?? '情報なし';
                    
                    final currencyFormatter = NumberFormat('#,###');

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              propertyName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text('家賃: ${currencyFormatter.format(rent)}円', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          // ★city, town, streetAddress を連結して表示
                          Text('住所: $city$town$streetAddress', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text('間取り: $floorPlan', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text('築年数: $buildingAge', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text('駅からの距離: $distanceToStation', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 16),
                          const Text('設備:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(amenities, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  },
                ),
// ▲▲▲ ここまで差し替え ▲▲▲

              Text('物件ID: $_propertyId', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              // ▲▲▲ ここまで修正 ▲▲▲

              const SizedBox(height: 30),
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('この物件に興味あり！'),
                  onPressed: () => _sendInterestToFirebase(context),
                ),
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
  
  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text('ログインが必要です。'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ▼▼▼ ここからが修正後のロジック ▼▼▼
          _buildSectionHeader('面談の予定', Colors.blue, Icons.calendar_today),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('user_ID').doc(currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || !snapshot.data!.exists) return const Card(child: ListTile(title: Text('現在、調整中の面談予定はありません。')));
              
              final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
              final List<dynamic> userCalendar = userData['UserCalendar'] ?? [];
              
              if (userCalendar.isEmpty) return const Card(child: ListTile(title: Text('現在、調整中の面談予定はありません。')));

              return Column(
                children: userCalendar.map((scheduleData) {
                  final schedule = scheduleData as Map<String, dynamic>;
                  final status = schedule['status'] ?? 'unknown';
                  if (status == 'confirmed') return _buildConfirmedCard(schedule);
                  if (status == 'rejected') return _buildRescheduleCard(schedule);
                  return _buildRequestedCard(schedule);
                }).toList(),
              );
            },
          ),
          
          _buildSectionHeader('承認された物件', Colors.green, Icons.check_circle),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('properties').where('user_license', arrayContains: currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Card(child: ListTile(title: Text('承認された物件はまだありません。')));
              return Column(children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(child: ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(data['propertyName'] ?? '名称不明'),
                      trailing: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('日程調整へ'),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScheduleRequestScreen(propertyId: doc.id, ownerId: data['ownerId']))),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          
          _buildSectionHeader('「興味あり」返答待ち', Colors.orange, Icons.hourglass_top),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('properties').where('userHope', arrayContains: currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Card(child: ListTile(title: Text('返答待ちの物件はありません。')));
              return Column(children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(child: ListTile(leading: const Icon(Icons.hourglass_top, color: Colors.orange), title: Text(data['propertyName'] ?? '名称不明')));
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
  
  // --- ここから補助関数 ---
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
  
  Widget _buildSectionHeader(String title, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Row(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark)),
      ]),
    );
  }

  Widget _buildConfirmedCard(Map<String, dynamic> schedule) {
    final DateTime time = (schedule['confirmedTime'] as Timestamp).toDate();
    final String link = schedule['zoomLink'] ?? '';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getPropertyName(schedule['propertyId'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark)),
            const Divider(height: 20),
            Text('確定日時: ${DateFormat('yyyy/MM/dd (E) HH:mm', 'ja_JP').format(time)}'),
            const SizedBox(height: 12),
            const Text('面談URL:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            if (link.isNotEmpty)
              InkWell(
                onTap: () => _launchURL(link),
                child: Text(link, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
              )
            else
              const Text('URLはまだ発行されていません'),
          ],
        ),
      ),
    );
  }

  Widget _buildRescheduleCard(Map<String, dynamic> schedule) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getPropertyName(schedule['propertyId'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark)),
            const SizedBox(height: 8),
            const Text('オーナーから日程の再調整依頼が届きました。'),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: const Text('日程を再調整する'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScheduleRequestScreen(propertyId: schedule['propertyId'], ownerId: schedule['ownerId']))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestedCard(Map<String, dynamic> schedule) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getPropertyName(schedule['propertyId'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark)),
            const SizedBox(height: 8),
            const Text('オーナーからの返信をお待ちください。'),
          ],
        ),
      ),
    );
  }
}
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // URLを開くための補助関数
  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('このリンクを開けませんでした: $urlString')),
        );
      }
    }
  }

  // ポップなカードを作成するための補助ウィジェット
  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String topText,
    required String bottomText,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(topText, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 16),
              Icon(icon, size: 50, color: iconColor),
              const SizedBox(height: 16),
              Text(bottomText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 動画とPDFのURL
    const videoUrl = 'https://drive.google.com/file/d/1vrkutI5mjecmqeejPJbvVw87RvvRVykt/view?usp=drive_link';
    const pdfUrl = 'https://drive.google.com/file/d/15CMXu2UYdGq6o0hKyNEGTc58JVZ5Uo2F/view?usp=drive_link';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOptionCard(
              context: context,
              icon: Icons.play_circle_fill_rounded,
              iconColor: Colors.red.shade400,
              topText: '動画でマナーを学ぶ',
              bottomText: 'マナー動画',
              onTap: () => _launchURL(context, videoUrl),
            ),
            const SizedBox(height: 24),
            _buildOptionCard(
              context: context,
              icon: Icons.picture_as_pdf_rounded,
              iconColor: Colors.green.shade600,
              topText: '資料でマナーを読む',
              bottomText: '資料PDF',
              onTap: () => _launchURL(context, pdfUrl),
            ),
          ],
        ),
      ),
    );
  }
}