import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_options.dart';
import 'OwnerHomeScreen.dart'; 
import 'image.dart';

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

  XFile? _image;

  final TextEditingController _propertyNameController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _streetAddressController = TextEditingController();

  String? _selectedCityOrWard; 
  final List<String> _citiesAndWards = [
    '神戸市東灘区', '神戸市灘区', '神戸市中央区', '神戸市兵庫区', '神戸市長田区', '神戸市須磨区',
    '神戸市垂水区', '神戸市北区', '神戸市西区',
    '尼崎市', '伊丹市', '西宮市', '宝塚市', '川西市', '芦屋市', '明石市', '加古川市', '高砂市', '姫路市',
  ];

  String? _selectedTown;
  List<String> _townsForSelectedCity = []; 

  final Map<String, List<String>> _townsByCity = {
    '神戸市東灘区': ['青木', '魚崎北町', '魚崎中町', '魚崎西町', '魚崎浜町', '魚崎南町', '岡本', '鴨子ヶ原', '北青木',
    '甲南台', '甲南町', '向洋町中', '向洋町西', '向洋町東', '住吉台', '住吉浜手', '住吉本町', '住吉宮町',
    '住吉山手', '田中町', '深江北町', '深江浜町', '深江南町', '深江本町', '深江和灘町', '本庄町', '御影',
    '御影石町', '御影塚町', '御影中町', '御影浜町', '御影本町', '御影山手'],
    '神戸市灘区': ['青谷町', '赤坂通', '味泥町', '泉通', '岩屋北町', '岩屋中町', '岩屋南町', '上野通', '烏帽子町',
    '大内通', '大石北町', '大石南町', '大石東町', '大石八幡町', '王子町', '上河原通', '神ノ木通', '神前町',
    '岸地通', '国玉通', '楠丘町', '楠ケ丘町', '倉石通', '黒土', '高徳町', '桜ケ丘町', '沢の鶴',
    '篠原', '篠原伯母野山町', '篠原中町', '下河原通', '城内通', '新在家南町', '水道筋', '千旦通', '高羽',
    '徳井', '中郷町', '永手', '灘北通', '灘浜東', '灘浜南', '西灘', '畑原通', '浜田町', '原田通',
    '稗原町', '日尾町', '琵琶町', '備後町', '福住通', '船寺通', '摩耶海岸通', '摩耶埠頭', '箕岡通',
    '宮山町', '森後町', '薬師通', '八幡町', '六甲山町', '六甲台町', '六甲町'],
    '神戸市中央区': ['相生町', '磯上通', '磯辺通', '伊藤町', '江戸町', '小野柄通', '海岸通', '加納町', '京町',
    '国香通', '琴ノ緒町', '小篭通', '栄町通', '坂口通', '三宮町', '東雲通', '下山手通', '新港町',
    '諏訪山町', '多聞通', '中山手通', '浪花町', '二宮町', '野崎通', '旗塚通', '花隈町', '浜辺通',
    '播磨町', '東町', '東本通', '日暮通', '葺合町', '布引町', '弁天町', 'ポートアイランド', '前町',
    '真砂通', '南本町', '宮本通', '元町高架通', '元町通', '森永町', '若菜通', '脇浜海岸通', '脇浜町',
    '割塚通'],
    '神戸市兵庫区': ['荒田町', '石井町', '上沢通', '駅南通', '大井通', '会下山町', '笠松通', '菊水町', '北仲通',
    '楠谷町', '小河通', '五宮町', '七宮町', '新開地', '神明町', '千鳥町', '大開通', '中道通',
    '西仲通', '浜中町', '東山町', '鵯越町', '古湊通', '御崎本町', '水木通', '湊町', '南仲町',
    '夢野町', '吉田町', '和田山通', '和田宮通', '和田岬町'],
    '神戸市長田区': ['池田谷', '一番町', '鶯町', '大塚町', '腕塚町', '海運町', '垣内町', '神楽町', '片山町',
    '兼田町', '苅藻島町', '川西通', '久保町', '駒ヶ林町', '五番町', '駒栄町', '長楽町',
    '大橋町', '高取山町', '千歳町', '寺池町', '長田町', '長田天神町', '名倉町', '西尻池町', '野田町',
    '浜添通', '東尻池町', '房王寺町', '細田町', '本庄町', '真野町', '御屋敷通', '南駒栄町', '宮川町',
    '若松町'],
    '神戸市須磨区': ['青葉町', '池田町', '一ノ谷町', '板宿町', '稲葉町', '大手', '大田町', '奥須磨', '神の谷',
    '北町', '行平町', '車', '小寺町', '桜木町', '潮見台町', '白川', '菅の台', '須磨浦通',
    '須磨寺町', '外浜町', '大黒町', '多井畑', '月見山', '寺田町', '道正台', '中落合', '西落合',
    '東白川台', '東町', '平田町', '古川町', '前池町', '南落合', '緑が丘', '妙法寺', '弥生が丘',
    '横尾'],
    '神戸市垂水区': ['青山台', '朝谷', '霞ヶ丘', '学が丘', '神田', '小束台', '塩屋町', '下畑町', '星が丘',
    '星陵台', '清玄町', '千鳥が丘', '高丸', '多聞台', '多聞町', 'つつじが丘', '潮見が丘', '天ノ下町',
    '仲田', '中道', '西舞子', '東舞子町', '日向', '福田', '本多聞', '舞子台', '舞多聞西',
    '舞多聞東', '松風台', '美山台', '名谷町', '桃山台'],
    '神戸市北区': ['有野町', '有野台', '有馬町', '泉台', '大沢町', '大池', '大脇台', '岡場', '小倉台',
    '鹿の子台', '唐櫃台', '菊水台', '君影町', '京地', '幸陽町', '甲栄台', '五葉', '杉尾台',
    '鈴蘭台', '鈴蘭台北町', '鈴蘭台東町', '惣山町', '道場町', '長尾町', '中里', '西大池', '西山',
    '谷上', '八多町', '花山台', 'ひよどり台', '藤原台', '松が枝町', '南五葉', '山田町'],
    '神戸市西区': ['伊川谷町', '押部谷町', '学園東町', '春日台', '樫野台', '狩場台', '糀台', '工業団地', '桜が丘東町',
    '竹の台', '月が丘', '玉津町', '天王山', '中野', '櫨谷町', '平野町', '福吉台', '美賀多台',
    '見津が丘', '森友'],
    '尼崎市': ['潮江', '神田北通', '常光寺', '立花町', '塚口本町', '東園田町', '南塚口町', '武庫之荘', '昭和通',
    '西難波町', '浜田町', '元浜町', '開明町', '南武庫之荘', '道意町'],
    '伊丹市': ['荒牧', '荻野', '春日丘', '北河原', '千僧', '南野', '船原', '中央', '桜ヶ丘', '宮ノ前',
    '昆陽', '池尻', '東有岡', '西台', '口酒井'],
    '西宮市': ['池田町', '上甲子園', '甲東園', '甲陽園', '高木西町', '苦楽園一番町', '鳴尾浜', '広田町', '羽衣町',
    '今津', '大社町', '瓦林町', '甲子園口', '山口町', '鷲林寺', '門戸厄神'],
    '宝塚市': ['安倉中', '伊孑志', '花屋敷荘園', '光ガ丘', '山本丸橋', '清荒神', '長谷', '大原野', '小浜',
    '逆瀬台', '末広町', '栄町', '仁川', '御殿山'],
    '川西市': ['大和東', '清和台東', '鼓が滝', '多田院', '東多田', '南花屋敷', '錦松台', '緑台', '向陽台',
    '絹延橋', '久代', '火打', 'けやき坂'],
    '芦屋市': ['大原町', '甲南町', '精道町', '呉川町', '月若町', '西山町', '六麓荘町', '船戸町', '打出小槌町', '宮塚町',
    '高浜町', '浜風町', '潮見町', '涼風町'],
    '明石市': ['魚住町西岡', '大久保町ゆりのき通', '藤江', '林崎町', '松江', '和坂', '相生町', '旭が丘', '太寺',
    '大蔵海岸通', '金ケ崎', '貴崎', '小久保', '西明石', '東野町', '本町', '山下町'],
    '加古川市': ['尾上町口里', '加古川町寺家町', '神野町', '野口町野口', '平岡町新在家', '八幡町中西条', '東神吉町', '志方町',
    '米田町', '別府町', '神吉町', '東加古川', '西神吉町'],
    '高砂市': ['阿弥陀', '曽根町', '高砂町', '米田町', '荒井町', '竜山', '伊保', '今市', '魚橋',
    '梅井', '北浜', '中島', '百合ヶ丘'],
    '姫路市': ['安田', '駅前町', '柿島', '五軒邸', '紺屋町', '白浜町', '飾磨区', '広畑区', '網干区',
    '香寺町', '夢前町', '林田町', '家島町', '的形町', '大津区', '勝原区', '余部区'],
  };

  String? _selectedBuildingAge;
  final List<String> _buildingAgeOptions = [
    '5年以内', '10年以内', '20年以内', '20年以上',
  ];

  String? _selectedFloorPlan;
  final List<String> _floorPlans = ['1R', '1K', '1DK', '1LDK', '2K', '2DK', '2LDK', '3K以上'];

  String? _selectedDistanceToStation;
  final List<String> _distances = ['1分以内', '5分以内', '10分以内', '15分以内', '20分以上'];

  final List<Map<String, dynamic>> _amenities = [
    {'title': 'バス・トイレ別', 'checked': false},
    {'title': 'エアコン付き', 'checked': false},
    {'title': 'オートロック', 'checked': false},
    {'title': 'ペット可', 'checked': false},
    {'title': 'インターネット無料', 'checked': false},
    {'title': '駐車場あり', 'checked': false},
    {'title': '和室', 'checked': false},
    {'title': 'IHコンロ', 'checked': false},
    {'title': 'バルコニーあり', 'checked': false},
  ];

  @override
  void dispose() {
    _propertyNameController.dispose();
    _rentController.dispose();
    _streetAddressController.dispose(); 
    super.dispose();
  }

  void _onCitySelected(String? newValue) {
    setState(() {
      _selectedCityOrWard = newValue;
      _selectedTown = null; 
      _townsForSelectedCity = newValue != null ? (_townsByCity[newValue] ?? []) : [];
    });
  }

  void _registerProperty() async {
    setState(() {
      _autovalidateForm = true;
    });

    if (_formKey.currentState!.validate() &&
        _selectedCityOrWard != null && 
        _selectedTown != null &&      
        _streetAddressController.text.isNotEmpty && 
        _selectedBuildingAge != null &&
        _selectedFloorPlan != null &&
        _selectedDistanceToStation != null) {

      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('物件を登録するにはログインが必要です。')),
        );
        return;
      }

      String? imageUrl;
      if (_image != null) {
        imageUrl = await uploadImage(_image!);
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('画像アップロード失敗')),);
          return;
        }
      }

      final String fullAddress = '$_selectedCityOrWard$_selectedTown${_streetAddressController.text}';

      final Map<String, dynamic> propertyData = {
        'ownerId': user.uid,
        'propertyName': _propertyNameController.text,
        'address': fullAddress, 
        'city': _selectedCityOrWard!,
        'town': _selectedTown!,
        'streetAddress': _streetAddressController.text,
        'rent': int.tryParse(_rentController.text) ?? 0,
        'buildingAge': _selectedBuildingAge!,
        'floorPlan': _selectedFloorPlan!,
        'distanceToStation': _selectedDistanceToStation!,
        'amenities': _amenities.where((item) => item['checked']).map((item) => item['title']).toList(),
        'timestamp': FieldValue.serverTimestamp(),
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

      try {
        await FirebaseFirestore.instance.collection('properties').add(propertyData);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('物件情報登録完了')),);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => OwnerHomeScreen(currentOwnerId: user.uid)),
          (Route<dynamic> Route) => false,
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

              InputDecorator(
                decoration: InputDecoration(
                  labelText: '所在地 (市/区)',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  errorText: _autovalidateForm && _selectedCityOrWard == null
                      ? '市/区を選択してください'
                      : null,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCityOrWard,
                    hint: const Text('選択してください'),
                    isExpanded: true,
                    onChanged: _onCitySelected, 
                    items: _citiesAndWards.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              InputDecorator(
                decoration: InputDecoration(
                  labelText: '所在地 (町/村)',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  errorText: _autovalidateForm && _selectedTown == null
                      ? '町/村を選択してください'
                      : null,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTown,
                    hint: const Text('選択してください'),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTown = newValue;
                      });
                    },
                    items: _townsForSelectedCity.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _streetAddressController,
                decoration: const InputDecoration(
                  labelText: '番地など',
                  hintText: '例: 1-2-3 ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '番地を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

               const Text('物件画像', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8),),
                child: _image == null
                    ? const Center(child: Text('画像が選択されていません'))
                    : Image.network(_image!.path, fit: BoxFit.cover), 
              ),
              const SizedBox(height: 8.0),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    setState(() { _image = pickedFile; });
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('ギャラリーから画像を選択'),
                ),
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
              const SizedBox(height: 16.0),

              InputDecorator(
                decoration: InputDecoration(
                  labelText: '築年数',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  errorText: _autovalidateForm && _selectedBuildingAge == null
                      ? '築年数を選択してください'
                      : null,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedBuildingAge,
                    hint: const Text('選択してください'),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBuildingAge = newValue;
                      });
                    },
                    items: _buildingAgeOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
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