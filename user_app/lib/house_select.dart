import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart'; 
import 'package:ffh/house_select.dart'; // ffh/house_select.dart のパスを正確に
import 'package:firebase_auth/firebase_auth.dart';


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

class _AppRootScreenState extends State<AppRootScreen> {
  int _selectedIndex = 0;
  // UserInterestStatusScreen の currentUserId は、実際のログインユーザーのUIDに置き換える必要があります
  // 例: UserInterestStatusScreen(currentUserId: FirebaseAuth.instance.currentUser?.uid ?? 'default_guest_id'),
  static const List<Widget> _widgetOptions = <Widget>[
    MainScreen(),
    UserInterestStatusScreen(currentUserId: 'user_abc_123'), // ダミーID。要修正。
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
  // ユーザーの希望条件を格納する変数
  Map<String, dynamic>? _userDesiredConditions;
  // ユーザーの希望に合致した物件を格納するリスト
  List<Map<String, dynamic>> _matchingProperties = [];

  // Firestoreのインスタンス
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ダミーの物件画像データ (Firebaseから取得したデータで表示する場合は、このリストは不要になります)
  final List<List<List<String>>> propertyImages = [
    [['assets/home1.jpg', 'assets/home1_1.jpg', 'assets/home1_2.jpg'] ,['9cp0aiaiEs0yTSQ40DWM']], // 'manRSK0lpWSBp24da51bKzQw2li2' が物件ID
    [['assets/home2.jpg', 'assets/home2_1.jpg'],[ 'UYhCХEd5qR0tCsG3o2РС']], // 'guLSsrP22ETfWOHEuCU3OuKzv6P2' が物件ID
    [['assets/home3.jpg', 'assets/home3_1.jpg'],[ 'twWytYCGkUhpHnfpvZQf']], // 'guLSsrP22ETfWOHEuCU3OuKzv6P2' が物件ID
  ];
  int currentIndex = 0; // 現在表示している物件のインデックス (ダミーデータ用)


  @override
  void initState() {
    super.initState();
    _loadUserAndProperties(); // ユーザー条件と物件データを読み込む
  }

  // ユーザーの希望条件をFirestoreから取得する関数
  Future<void> _fetchUserDesiredConditions() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('ユーザーがログインしていません。');
      // ログイン画面へリダイレクトするなどの処理をここに追加することも検討
      return;
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection('user_ID').doc(currentUser.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          // desiredConditionsが存在しない可能性も考慮し、nullチェックを追加
          _userDesiredConditions = userData['desiredConditions'] as Map<String, dynamic>?;
          print('ユーザー希望条件を読み込みました: $_userDesiredConditions');
        });
      } else {
        print('ユーザーの希望条件が見つかりません。');
      }
    } catch (e) {
      print('ユーザー希望条件の取得中にエラーが発生しました: $e');
    }
  }

  // 物件をフィルタリングする関数
  Future<void> _filterProperties() async {
    if (_userDesiredConditions == null) {
      print('ユーザーの希望条件がまだ読み込まれていないか、取得できませんでした。');
      // 例: スナックバーでユーザーに希望条件の設定を促す
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('物件を絞り込むには、まず「あなたの状況」画面で希望条件を設定してください。')),
      );
      return;
    }

    try {
      QuerySnapshot propertiesSnapshot = await _firestore.collection('properties').get();
      List<Map<String, dynamic>> allProperties = propertiesSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      List<Map<String, dynamic>> tempMatchingProperties = [];

      for (var property in allProperties) {
        bool matches = _checkPropertyMatches(property, _userDesiredConditions!);
        if (matches) {
          tempMatchingProperties.add(property);
        }
      }

      setState(() {
        _matchingProperties = tempMatchingProperties;
        print('合致する物件の数: ${_matchingProperties.length}');
        if (_matchingProperties.isEmpty) {
          print('合致する物件がありませんでした。');
        } else {
          _matchingProperties.forEach((p) => print('合致した物件: ${p['propertyName']} (ID: ${p['ownerId']})'));
        }
      });
    } catch (e) {
      print('物件のフィルタリング中にエラーが発生しました: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('物件のフィルタリング中にエラーが発生しました: ${e.toString()}')),
      );
    }
  }

  // 個別の物件がユーザー条件に合致するかを判定するロジック
  bool _checkPropertyMatches(Map<String, dynamic> property, Map<String, dynamic> desired) {
    // 1. 家賃範囲の比較
    int propertyRent = property['rent'] as int? ?? 0;
    int desiredRentMin = desired['rentRangeMin'] as int? ?? 0;
    int desiredRentMax = desired['rentRangeMax'] as int? ?? 200000; 

    if (propertyRent < desiredRentMin || propertyRent > desiredRentMax) {
      return false;
    }

    // 2. 希望エリア (city, town) の比較
    String propertyCity = property['city'] as String? ?? '';
    String propertyTown = property['town'] as String? ?? '';
    String desiredCity = desired['city'] as String? ?? '';
    String desiredTown = desired['town'] as String? ?? '';

    // 希望エリアが設定されている場合のみ比較
    if (desiredCity.isNotEmpty && propertyCity != desiredCity) {
      return false;
    }
    if (desiredTown.isNotEmpty && propertyTown != desiredTown) {
      return false;
    }

    // 3. 築年数の比較 (UserConditionもPropertyRegistrationScreenも日本語のみで保存されている前提)
    String propertyBuildingAge = property['buildingAge'] as String? ?? '';
    String desiredBuildingAge = desired['buildingAge'] as String? ?? '';
    if (desiredBuildingAge.isNotEmpty && propertyBuildingAge != desiredBuildingAge) {
      return false;
    }

    // 4. 間取りの比較 (UserConditionもPropertyRegistrationScreenも日本語のみで保存されている前提)
    String propertyFloorPlan = property['floorPlan'] as String? ?? '';
    String desiredLayout = desired['selectedLayout'] as String? ?? '';
    if (desiredLayout.isNotEmpty && propertyFloorPlan != desiredLayout) {
      return false;
    }

    // 5. 駅からの距離の比較 (UserConditionもPropertyRegistrationScreenも日本語のみで保存されている前提)
    String propertyDistanceToStation = property['distanceToStation'] as String? ?? '';
    String desiredDistanceToStation = desired['distanceToStation'] as String? ?? '';
    if (desiredDistanceToStation.isNotEmpty && propertyDistanceToStation != desiredDistanceToStation) {
      return false;
    }

    // 6. 設備・特徴 (amenities) の比較
    List<String> propertyAmenities = (property['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    List<String> desiredAmenities = (desired['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    for (String desiredAmenity in desiredAmenities) {
      if (!propertyAmenities.contains(desiredAmenity)) {
        return false; // ユーザーが希望する設備が1つでも物件に存在しない場合、false
      }
    }
    
    return true;
  }

  // 初期化時にユーザー条件と物件を読み込み、フィルタリングを実行
  Future<void> _loadUserAndProperties() async {
    await _fetchUserDesiredConditions();
    if (_userDesiredConditions != null) {
      await _filterProperties();
    } else {
      print('ユーザー条件が読み込めなかったため、フィルタリングはスキップされました。');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('物件一覧')),
      body: Column( // body を Column で囲み、その中に既存のコンテンツと新しい表示を追加
        children: [
          // 元の画像スライド表示部分
          Hero(
            tag: 'imageHero',
            child: GestureDetector(
              onTap: () {
                // propertyImagesはダミーデータなので、Firestoreからのデータと連携させるには
                // DetailScreenへのデータ渡し方を変更する必要があります。
                // ここでは仮にダミーデータのままとしています。
                final List<String> currentPropertyImagePaths = propertyImages[currentIndex][0]
                    .where((path) => path.endsWith('.jpg'))
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      initialImagePath: currentPropertyImagePaths.isNotEmpty ? currentPropertyImagePaths[0] : '',
                      propertyImages: propertyImages[currentIndex][0] + propertyImages[currentIndex][1],
                    ),
                  ),
                );
              },
              child: SizedBox(
                width: screenWidth * 0.5,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    propertyImages[currentIndex][0][0], // ダミーデータの最初の画像を表示
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
          ),
          // 合致する物件IDのリスト表示
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '合致する物件ID (Matching Property IDs):',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_userDesiredConditions == null)
                  const Text('ユーザー条件を読み込み中です...', style: TextStyle(color: Colors.grey))
                else if (_matchingProperties.isEmpty)
                  const Text('該当する物件IDはありません。')
                else
                  ..._matchingProperties.map((property) {
                    return Text(
                      property['ownerId'] ?? 'ID不明',
                      style: const TextStyle(fontSize: 14),
                    );
                  }).toList(),
              ],
            ),
          ),
        ],
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

  // ★変更点: Firebaseへの「興味あり」処理をここに直接記述
  Future<void> _sendInterestToFirebase(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      // ログインしていない場合、処理せず、ログを出すのみ
      print('エラー: ユーザーがログインしていません。');
      return;
    }

    final String userId = currentUser.uid;

    try {
      DocumentReference propertyDocRef = _firestore.collection('properties').doc(_propertyId);

      // FieldValue.arrayUnion を使って、userHope配列にユーザーIDを追加
      // 既に存在する場合は追加されず、存在しない場合のみ追加される
      await propertyDocRef.update({
        'userHope': FieldValue.arrayUnion([userId]),
      });
      print('DEBUG: 物件ID $_propertyId の userHope にユーザーID $userId を追加しました。');

    } catch (e) {
      print('エラー: Firebaseへのデータ更新に失敗しました: $e');
    } finally {
      // 処理が完了したら、前の画面に戻る
      Navigator.pop(context); 
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
                onPressed: () => _sendInterestToFirebase(context), // ボタンで関数を呼び出す
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