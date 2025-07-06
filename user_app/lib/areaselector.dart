import 'package:flutter/material.dart';

class AreaSelector extends StatefulWidget {
  const AreaSelector({super.key});

  @override
  State<AreaSelector> createState() => _AreaSelectorState();
}

class _AreaSelectorState extends State<AreaSelector> {
  String? _selectedCity; // 例: 神戸市、姫路市
  String? _selectedWard; // 例: 中央区、香寺町
  String? _selectedNeighborhood; // 例: 三宮、駅前町

  final List<String> selectedAreas = [];

  // 兵庫県内の詳細なエリアデータ（市 -> 区・町 -> 地域・丁目）
  // すべての選択肢に英語の補助を追加
  final Map<String, Map<String, List<String>>> hyogoAreaData = {
    '神戸市 (Kobe City)': {
      '中央区 (Chuo Ward)': ['三宮 (Sannomiya)', '元町 (Motomachi)', '旧居留地 (Kyukyoryuchi)', 'ポートアイランド (Port Island)', 'その他 (Other)'],
      '灘区 (Nada Ward)': ['六甲 (Rokko)', '摩耶 (Maya)', '王子公園 (Oji Park)', 'その他 (Other)'],
      '東灘区 (Higashinada Ward)': ['岡本 (Okamoto)', '住吉 (Sumiyoshi)', '魚崎 (Uozaki)', 'その他 (Other)'],
      '兵庫区 (Hyogo Ward)': ['湊川 (Minatogawa)', '新開地 (Shinkaichi)', '和田岬 (Wadamisaki)', 'その他 (Other)'],
      '長田区 (Nagata Ward)': ['新長田 (Shin-Nagata)', '駒ヶ林 (Komagabayashi)', 'その他 (Other)'],
      '須磨区 (Suma Ward)': ['須磨浦 (Sumaura)', '板宿 (Itayado)', 'その他 (Other)'],
      '垂水区 (Tarumi Ward)': ['舞子 (Maiko)', '塩屋 (Shioya)', 'その他 (Other)'],
      '西区 (Nishi Ward)': ['学園都市 (Gakuen-toshi)', '西神中央 (Seishin-Chuo)', 'その他 (Other)'],
      '北区 (Kita Ward)': ['有馬温泉 (Arima Onsen)', '鈴蘭台 (Suzurandai)', 'その他 (Other)'],
    },
    '姫路市 (Himeji City)': {
      '姫路市中心部 (Himeji City Center)': ['駅前町 (Ekimae-cho)', '大手前 (Otemae)', 'その他 (Other)'],
      '香寺町 (Koderacho)': ['溝口 (Mizoguchi)', 'その他 (Other)'],
      '夢前町 (Yumesakicho)': ['前之庄 (Maenosho)', 'その他 (Other)'],
      '安富町 (Yasutomicho)': ['安富 (Yasutomi)', 'その他 (Other)'],
      '家島町 (Ieshimacho)': ['真浦 (Maura)', 'その他 (Other)'],
      'その他 (Other)': ['その他 (Other)'] // 姫路市内の上記以外の区・町
    },
    '尼崎市 (Amagasaki City)': {
      '尼崎市中心部 (Amagasaki City Center)': ['立花 (Tachibana)', 'その他 (Other)'],
      '武庫之荘 (Mukonoso)': ['武庫之荘 (Mukonoso)', 'その他 (Other)'],
      '園田 (Sonoda)': ['園田 (Sonoda)', 'その他 (Other)'],
      'その他 (Other)': ['その他 (Other)']
    },
    '明石市 (Akashi City)': {
      '明石市中心部 (Akashi City Center)': ['明石公園 (Akashi Park)', 'その他 (Other)'],
      '大久保町 (Okubocho)': ['大久保 (Okubo)', 'その他 (Other)'],
      '魚住町 (Uozumicho)': ['魚住 (Uozumi)', 'その他 (Other)'],
      'その他 (Other)': ['その他 (Other)']
    },
    '西宮市 (Nishinomiya City)': {
      '西宮市中心部 (Nishinomiya City Center)': ['西宮北口 (Nishinomiya-Kitaguchi)', '甲子園 (Koshien)', 'その他 (Other)'],
      '鳴尾 (Naruo)': ['鳴尾 (Naruo)', 'その他 (Other)'],
      'その他 (Other)': ['その他 (Other)']
    },
    '加古川市 (Kakogawa City)': {
      '加古川町 (Kakogawacho)': ['加古川町 (Kakogawacho)', 'その他 (Other)'],
      'その他 (Other)': ['その他 (Other)']
    },
    '宝塚市 (Takarazuka City)': {
      '宝塚市中心部 (Takarazuka City Center)': ['宝塚 (Takarazuka)', 'その他 (Other)'],
      '逆瀬川 (Sakasegawa)': ['逆瀬川 (Sakasegawa)', 'その他 (Other)'],
      'その他 (Other)': ['その他 (Other)']
    },
    '伊丹市 (Itami City)': {
      '伊丹市中心部 (Itami City Center)': ['伊丹 (Itami)', 'その他 (Other)'],
      'その他 (Other)': ['その他 (Other)']
    },
    '川西市 (Kawanishi City)': {
      '川西市中心部 (Kawanishi City Center)': ['川西能勢口 (Kawanishi-Noseguchi)', 'その他 (Other)'],
      'その他 (Other)': ['その他 (Other)']
    },
    '三田市 (Sanda City)': {
      '三田市中心部 (Sanda City Center)': ['三田 (Sanda)', 'その他 (Other)'],
      'その他 (Other)': ['その他 (Other)']
    },
    '芦屋市 (Ashiya City)': {
      '芦屋市中心部 (Ashiya City Center)': ['芦屋 (Ashiya)', 'その他 (Other)'],
      'その他 (Other)': ['その他 (Other)']
    },
    'その他市町村 (Other Cities/Towns)': { // 上記以外の市町村をまとめる
      'その他 (Other)': ['その他 (Other)']
    }
  };

  // 選択可能な市のリストを返す
  List<String> getCities() {
    return hyogoAreaData.keys.toList();
  }

  // 選択された市に基づいて、その中の区・町のリストを返す
  List<String> getWards(String? city) {
    if (city == null || !hyogoAreaData.containsKey(city)) return [];
    return hyogoAreaData[city]!.keys.toList();
  }

  // 選択された区・町に基づいて、その中の地域・丁目のリストを返す
  List<String> getNeighborhoods(String? city, String? ward) {
    if (city == null || ward == null || !hyogoAreaData.containsKey(city) || !hyogoAreaData[city]!.containsKey(ward)) return [];
    return hyogoAreaData[city]![ward] ?? [];
  }

  void addSelectedArea() {
    if (_selectedCity != null && _selectedWard != null && _selectedNeighborhood != null) {
      final area = '兵庫県 (Hyogo Pref.) > $_selectedCity > $_selectedWard > $_selectedNeighborhood'; // 英語補助も追加
      if (!selectedAreas.contains(area)) {
        setState(() {
          selectedAreas.add(area);
        });
      }
    }
  }

  void removeSelectedArea(String area) {
    setState(() {
      selectedAreas.remove(area);
    });
  }

  @override
  Widget build(BuildContext context) {
    // アプリ全体で使うメインの色を定義
    final Color mainColor = Colors.teal[800]!; // 濃いティール

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 市の選択ドロップダウン
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: '市', // 日本語のみに短縮
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.location_city, color: mainColor), // アイコン色もメインカラーに
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
          ),
          value: _selectedCity,
          items: getCities()
              .map((city) =>
                  DropdownMenuItem(value: city, child: Text(city))) // ここも英語併記の文字列を表示
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedCity = val;
              _selectedWard = null; // 市が変わったら区・町をリセット
              _selectedNeighborhood = null; // 地域・丁目もリセット
            });
          },
        ),
        Text(
          'City', // 英語を別のTextウィジェットで表示
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),

        // 区・町の選択ドロップダウン
        if (_selectedCity != null)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '区・町', // 日本語のみに短縮
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.location_on, color: mainColor), // アイコン色もメインカラーに
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
              ),
              value: _selectedWard,
              items: getWards(_selectedCity)
                  .map((ward) =>
                      DropdownMenuItem(value: ward, child: Text(ward))) // ここも英語併記の文字列を表示
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedWard = val;
                  _selectedNeighborhood = null; // 区・町が変わったら地域・丁目をリセット
                });
              },
            ),
          ),
        if (_selectedCity != null)
          Text(
            'Ward/Town', // 英語を別のTextウィジェットで表示
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),

        // 地域・丁目の選択ドロップダウン
        if (_selectedWard != null)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '地域・丁目', // 日本語のみに短縮
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.place, color: mainColor), // アイコン色もメインカラーに
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
              ),
              value: _selectedNeighborhood,
              items: getNeighborhoods(_selectedCity, _selectedWard)
                  .map((neighborhood) =>
                      DropdownMenuItem(value: neighborhood, child: Text(neighborhood))) // ここも英語併記の文字列を表示
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedNeighborhood = val;
                });
              },
            ),
          ),
        if (_selectedWard != null)
          Text(
            'Neighborhood/Block', // 英語を別のTextウィジェットで表示
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor, // メインカラー
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            onPressed:
                (_selectedCity != null && _selectedWard != null && _selectedNeighborhood != null)
                    ? addSelectedArea
                    : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Add this desired area',
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                ),
                const SizedBox(height: 2),
                const Text('この希望エリアを追加', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 30),

        if (selectedAreas.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected desired areas:',
                    style: TextStyle(fontSize: 14, color: Colors.black87.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '選ばれた希望エリア:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...selectedAreas.map((area) => Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(area, style: const TextStyle(fontSize: 15)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeSelectedArea(area),
                  ),
                ),
              )),
            ],
          ),
      ],
    );
  }
}