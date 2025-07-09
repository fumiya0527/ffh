// user_app/lib/main.dart (ユーザー側主要機能とアプリ全体構造)


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart'; 
import 'package:ffh/house_select.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     print('Firebase Initialized Successfully!');
//   } catch (e) {
//     print('Failed to initialize Firebase: $e');
//   }

//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

class _AppRootScreenState extends State<AppRootScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    MainScreen(),
    UserInterestStatusScreen(currentUserId: 'user_abc_123'),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '物件を見る',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'あなたの状況',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
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
  final List<List<List<String>>> propertyImages = [
    [['assets/home1.jpg', 'assets/home1_1.jpg', 'assets/home1_2.jpg'] ,['manRSK0lpWSBp24da51bKzQw2li2']], // 'manRSK0lpWSBp24da51bKzQw2li2' が物件ID
    [['assets/home2.jpg', 'assets/home2_1.jpg'],[ 'guLSsrP22ETfWOHEuCU3OuKzv6P2']], // 'guLSsrP22ETfWOHEuCU3OuKzv6P2' が物件ID
    [['assets/home3.jpg', 'assets/home3_1.jpg'],[ 'guLSsrP22ETfWOHEuCU3OuKzv6P2']], // 'guLSsrP22ETfWOHEuCU3OuKzv6P2' が物件ID
  ];

  int currentIndex = 0; // 現在表示している物件のインデックス

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('物件一覧')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'imageHero',
              child: GestureDetector(
                onTap: () {
                  // 現在の物件の画像リストから、JPGパスだけをフィルタリング
                  final List<String> currentPropertyImagePaths = propertyImages[currentIndex][0]
                      .where((path) => path.endsWith('.jpg'))
                      .toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        // 最初のJPG画像パスをinitialImagePathとして渡す
                        initialImagePath: currentPropertyImagePaths.isNotEmpty ? currentPropertyImagePaths[0] : '',
                        // フィルタリングされていない元の物件の全画像リストを渡す（DetailScreenでIDを抽出するため）
                        propertyImages: propertyImages[currentIndex][0] + propertyImages[currentIndex][1], // 画像パスと物件IDを結合して渡す
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: screenWidth * 0.5,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      propertyImages[currentIndex][0][0], // 変更後: propertyImages[currentIndex][0]が画像パスのリスト
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentIndex = (currentIndex + propertyImages.length - 1) % propertyImages.length;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('前の物件へ'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentIndex = (currentIndex + 1) % propertyImages.length;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('次の物件へ'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final String initialImagePath;
  final List<String> propertyImages; // JPGでないものを含むリスト

  const DetailScreen({
    super.key,
    required this.initialImagePath,
    required this.propertyImages,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late int _currentImageIndex; // 現在表示している画像のインデックス
  late List<String> _validImagePaths; // JPGファイルのみを格納するリスト
  late String _propertyId; // DetailScreen内で物件IDを保持する変数

  @override
  void initState() {
    super.initState();
    // 渡されたpropertyImagesリストをフィルタリングし、有効なJPGパスのみを抽出
    _validImagePaths = widget.propertyImages
        .where((imagePath) => imagePath.endsWith('.jpg'))
        .toList();

    // propertyImagesの最後の要素を物件IDとして抽出
    _propertyId = widget.propertyImages.isNotEmpty ? widget.propertyImages.last : 'no_property_id_found';


    // 渡された初期画像パスがフィルタリングされたリストのどこにあるかを見つける
    _currentImageIndex = _validImagePaths.indexOf(widget.initialImagePath);

    // もし見つからなければ、または有効な画像がなければ、安全のため0番目の画像にする
    if (_currentImageIndex == -1 || _validImagePaths.isEmpty) {
      _currentImageIndex = 0;
    }
  }

  void _goToPreviousImage() {
    setState(() {
      if (_validImagePaths.isNotEmpty) {
        _currentImageIndex = (_currentImageIndex - 1 + _validImagePaths.length) % _validImagePaths.length;
      } else {
        _currentImageIndex = 0;
      }
    });
  }

  void _goToNextImage() {
    setState(() {
      if (_validImagePaths.isNotEmpty) {
        _currentImageIndex = (_currentImageIndex + 1) % _validImagePaths.length;
      } else {
        _currentImageIndex = 0;
      }
    });
  }

  Future<void> _sendInterestToFirebase(BuildContext context) async {
    const String dummyUserId = 'user_abc_123';
    final String propertyIdToSend = _propertyId; // initStateで抽出した物件IDを使用

    try {
      await FirebaseFirestore.instance.collection('userInterests').add({
        'userId': dummyUserId,
        'propertyId': propertyIdToSend,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('物件への意思表示を送信しました！')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Firebaseへのデータ送信に失敗しました: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('意思表示の送信に失敗しました: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('物件詳細'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: 'imageHero',
                    child: SizedBox(
                      width: screenWidth * 0.9,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _validImagePaths.isNotEmpty
                            ? Image.asset(
                                _validImagePaths[_currentImageIndex],
                                fit: BoxFit.cover,
                              )
                            : const Center(child: Text('表示できる画像がありません。')),
                      ),
                    ),
                  ),

                  if (_validImagePaths.length > 1)
                    Positioned(
                      left: 10,
                      child: IconButton(
                        onPressed: _goToPreviousImage,
                        icon: const Icon(Icons.arrow_back_ios, size: 40, color: Colors.orange,),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),

                  if (_validImagePaths.length > 1)
                    Positioned(
                      right: 10,
                      child: IconButton(
                        onPressed: _goToNextImage,
                        icon: const Icon(Icons.arrow_forward_ios, size: 40, color: Colors.orange,),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _validImagePaths.isNotEmpty
                    ? '${_currentImageIndex + 1} / ${_validImagePaths.length}'
                    : '画像なし',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                '物件ID: $_propertyId',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'この物件は、広々としたリビングと日当たりの良いバルコニーが特徴です。静かな住宅街に位置し、近くには公園やショッピング施設があります。詳細は後ほど担当者からご連絡いたします。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _sendInterestToFirebase(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: const Text('この物件に興味あり！'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserInterestStatusScreen extends StatelessWidget {
  final String currentUserId;

  const UserInterestStatusScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('あなたの意思表示状況')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('userInterests')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('データ取得失敗: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final myInterests = snapshot.data!.docs;
          if (myInterests.isEmpty) {
            return const Center(child: Text('まだ物件への意思表示はしていません。'));
          }

          return ListView.builder(
            itemCount: myInterests.length,
            itemBuilder: (context, index) {
              final data = myInterests[index].data() as Map<String, dynamic>;
              final String? ownerResponseUrl = data['ownerResponseUrl'] as String?;
              final String status = data['status'] as String? ?? 'pending';

              String statusText;
              Color statusColor;
              switch (status) {
                case 'pending':
                  statusText = '保留中：オーナーからの返答をお待ちください。';
                  statusColor = Colors.orange;
                  break;
                case 'accepted':
                  statusText = '承認されました！';
                  statusColor = Colors.green;
                  break;
                case 'rejected':
                  statusText = '却下されました。';
                  statusColor = Colors.red;
                  break;
                default:
                  statusText = '不明なステータス';
                  statusColor = Colors.grey;
              }

              final Timestamp? timestamp = data['timestamp'] as Timestamp?;
              String formattedTime = '日時不明';
              if (timestamp != null) {
                formattedTime = DateFormat('yyyy/MM/dd HH:mm:ss').format(timestamp.toDate());
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 2,
                child: ListTile(
                  title: Text('物件ID: ${data['propertyId'] ?? '不明'}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(statusText, style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
                      if (status == 'accepted' && ownerResponseUrl != null && ownerResponseUrl.isNotEmpty)
                        InkWell(
                          onTap: () async {
                            final uri = Uri.parse(ownerResponseUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('URLを開けませんでした: $ownerResponseUrl'))
                              );
                            }
                          },
                          child: Text(
                            '対談URL: $ownerResponseUrl をクリックして開く',
                            style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                          ),
                        ),
                      if (status == 'pending')
                        const Text('オーナーからの返答をしばらくお待ちください。'),
                      Text('意思表示日時: $formattedTime'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: const Center(
        child: Text('設定画面です'),
      ),
    );
  }
}