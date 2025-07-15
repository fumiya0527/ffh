import 'package:flutter/material.dart';

class AreaSelector extends StatefulWidget {
  // ★変更: List<Map<String, String>> を親に渡すようにする
  final ValueChanged<List<Map<String, String>>> onAreasChanged;

  const AreaSelector({super.key, required this.onAreasChanged});

  @override
  State<AreaSelector> createState() => _AreaSelectorState();
}

class _AreaSelectorState extends State<AreaSelector> {
  String? _selectedCityOrWard;
  String? _selectedNeighborhood;

  // ★変更: 内部で管理するリストの型を List<Map<String, String>> に変更
  List<Map<String, String>> _selectedDesiredAreas = [];

  final Map<String, List<String>> hyogoAreaData = {
    // ... (hyogoAreaData の内容は変更なし)
    "神戸市東灘区 (Kobe City Higashinada Ward)": [
      "青木", "魚崎北町", "魚崎中町", "魚崎西町", "魚崎浜町", "魚崎南町", "岡本", "鴨子ヶ原", "北青木",
      "甲南台", "甲南町", "向洋町中", "向洋町西", "向洋町東", "住吉台", "住吉浜手", "住吉本町", "住吉宮町",
      "住吉山手", "田中町", "深江北町", "深江浜町", "深江南町", "深江本町", "深江和灘町", "本庄町", "御影",
      "御影石町", "御影塚町", "御影中町", "御影浜町", "御影本町", "御影山手"
    ],
    "神戸市灘区 (Kobe City Nada Ward)": [
      "青谷町", "赤坂通", "味泥町", "泉通", "岩屋北町", "岩屋中町", "岩屋南町", "上野通", "烏帽子町",
      "大内通", "大石北町", "大石南町", "大石東町", "大石八幡町", "王子町", "上河原通", "神ノ木通", "神前町",
      "岸地通", "国玉通", "楠丘町", "楠ケ丘町", "倉石通", "黒土", "高徳町", "桜ケ丘町", "沢の鶴", "篠原",
      "篠原伯母野山町", "篠原中町", "下河原通", "城内通", "新在家南町", "水道筋", "千旦通", "高羽", "徳井",
      "中郷町", "永手", "灘北通", "灘浜東", "灘浜南", "西灘", "畑原通", "浜田町", "原田通", "稗原町",
      "日尾町", "琵琶町", "備後町", "福住通", "船寺通", "摩耶海岸通", "摩耶埠頭", "箕岡通", "宮山町",
      "森後町", "薬師通", "八幡町", "六甲山町", "六甲台町", "六甲町"
    ],
    "神戸市中央区 (Kobe City Chuo Ward)": [
      "相生町", "磯上通", "磯辺通", "伊藤町", "江戸町", "小野柄通", "海岸通", "加納町", "京町", "国香通",
      "琴ノ緒町", "小篭通", "栄町通", "坂口通", "三宮町", "東雲通", "下山手通", "新港町", "諏訪山町",
      "多聞通", "中山手通", "浪花町", "二宮町", "野崎通", "旗塚通", "花隈町", "浜辺通", "播磨町", "東町",
      "東本通", "日暮通", "葺合町", "布引町", "弁天町", "ポートアイランド", "前町", "真砂通", "南本町",
      "宮本通", "元町高架通", "元町通", "森永町", "若菜通", "脇浜海岸通", "脇浜町", "割塚通"
    ],
    "神戸市兵庫区 (Kobe City Hyogo Ward)": [
      "荒田町", "石井町", "上沢通", "駅南通", "大井通", "会下山町", "笠松通", "菊水町", "北仲通", "楠谷町",
      "小河通", "五宮町", "七宮町", "新開地", "神明町", "千鳥町", "大開通", "中道通", "西仲通", "浜中町",
      "東山町", "鵯越町", "古湊通", "御崎本町", "水木通", "湊町", "南仲町", "夢野町", "吉田町", "和田山通",
      "和田宮通", "和田岬町"
    ],
    "神戸市長田区 (Kobe City Nagata Ward)": [
      "池田谷", "一番町", "鶯町", "大塚町", "腕塚町", "海運町", "垣内町", "神楽町", "片山町", "兼田町",
      "苅藻島町", "川西通", "久保町", "駒ヶ林町", "五番町", "駒栄町", "長楽町", "大橋町", "高取山町",
      "千歳町", "寺池町", "長田町", "長田天神町", "名倉町", "西尻池町", "野田町", "浜添通", "東尻池町",
      "房王寺町", "細田町", "本庄町", "真野町", "御屋敷通", "南駒栄町", "宮川町", "若松町"
    ],
    "神戸市須磨区 (Kobe City Suma Ward)": [
      "青葉町", "池田町", "一ノ谷町", "板宿町", "稲葉町", "大手", "大田町", "奥須磨", "神の谷", "北町",
      "行平町", "車", "小寺町", "桜木町", "潮見台町", "白川", "菅の台", "須磨浦通", "須磨寺町", "外浜町",
      "大黒町", "多井畑", "月見山", "寺田町", "道正台", "中落合", "西落合", "東白川台", "東町", "平田町",
      "古川町", "前池町", "南落合", "緑が丘", "妙法寺", "弥生が丘", "横尾"
    ],
    "神戸市垂水区 (Kobe City Tarumi Ward)": [
      "青山台", "朝谷", "霞ヶ丘", "学が丘", "神田", "小束台", "塩屋町", "下畑町", "星が丘", "星陵台",
      "清玄町", "千鳥が丘", "高丸", "多聞台", "多聞町", "つつじが丘", "潮見が丘", "天ノ下町", "仲田",
      "中道", "西舞子", "東舞子町", "日向", "福田", "本多聞", "舞子台", "舞多聞西", "舞多聞東", "松風台",
      "美山台", "名谷町", "桃山台"
    ],
    "神戸市北区 (Kobe City Kita Ward)": [
      "有野町", "有野台", "有馬町", "泉台", "大沢町", "大池", "大脇台", "岡場", "小倉台", "鹿の子台",
      "唐櫃台", "菊水台", "君影町", "京地", "幸陽町", "甲栄台", "五葉", "杉尾台", "鈴蘭台", "鈴蘭台北町",
      "鈴蘭台東町", "惣山町", "道場町", "長尾町", "中里", "西大池", "西山", "谷上", "八多町", "花山台",
      "ひよどり台", "藤原台", "松が枝町", "南五葉", "山田町", "八多町"
    ],
    "神戸市西区 (Kobe City Nishi Ward)": [
      "伊川谷町", "押部谷町", "学園東町", "春日台", "樫野台", "狩場台", "糀台", "工業団地", "桜が丘東町",
      "竹の台", "月が丘", "玉津町", "天王山", "中野", "櫨谷町", "平野町", "福吉台", "美賀多台", "見津が丘",
      "森友"
    ],
    "尼崎市 (Amagasaki City)": [
      "潮江", "神田北通", "常光寺", "立花町", "塚口本町", "東園田町", "南塚口町", "武庫之荘",
      "昭和通", "西難波町", "浜田町", "元浜町", "開明町", "南武庫之荘", "道意町"
    ],
    "伊丹市 (Itami City)": [
      "荒牧", "荻野", "春日丘", "北河原", "千僧", "南野", "船原", "中央", "桜ヶ丘", "宮ノ前",
      "昆陽", "池尻", "東有岡", "西台", "口酒井"
    ],
    "西宮市 (Nishinomiya City)": [
      "池田町", "上甲子園", "甲東園", "甲陽園", "高木西町", "苦楽園一番町", "鳴尾浜", "広田町",
      "羽衣町", "今津", "大社町", "瓦林町", "甲子園口", "甲子園浜", "山口町", "鷲林寺", "門戸厄神"
    ],
    "宝塚市 (Takarazuka City)": [
      "安倉中", "伊孑志", "花屋敷荘園", "光ガ丘", "山本丸橋", "清荒神", "長谷", "大原野", "小浜",
      "逆瀬台", "末広町", "栄町", "仁川", "御殿山"
    ],
    "川西市 (Kawanishi City)": [
      "大和東", "清和台東", "鼓が滝", "多田院", "東多田", "南花屋敷", "錦松台", "緑台", "向陽台",
      "絹延橋", "久代", "火打", "けやき坂"
    ],
    "芦屋市 (Ashiya City)": [
      "大原町", "甲南町", "精道町", "月若町", "西山町", "六麓荘町", "船戸町", "打出小槌町", "宮塚町",
      "高浜町", "浜風町", "潮見町", "涼風町"
    ],
    "明石市 (Akashi City)": [
      "魚住町西岡", "大久保町ゆりのき通", "藤江", "林崎町", "松江", "和坂", "相生町", "旭が丘",
      "太寺", "大蔵海岸通", "金ケ崎", "貴崎", "小久保", "西明石", "東野町", "本町", "山下町"
    ],
    "加古川市 (Kakogawa City)": [
      "尾上町口里", "加古川町寺家町", "神野町", "野口町野口", "平岡町新在家", "八幡町中西条",
      "東神吉町", "志方町", "米田町", "別府町", "神吉町", "東加古川", "西神吉町"
    ],
    "高砂市 (Takasago City)": [
      "阿弥陀", "曽根町", "高砂町", "米田町", "荒井町", "竜山", "伊保", "今市", "魚橋", "梅井",
      "北浜", "中島", "百合ヶ丘"
    ],
    "姫路市 (Himeji City)": [
      "安田", "駅前町", "柿島", "五軒邸", "紺屋町", "白浜町", "飾磨区", "広畑区", "網干区",
      "香寺町", "夢前町", "林田町", "家島町", "的形町", "大津区", "勝原区", "余部区"
    ]
  };

  List<String> getCityOrWardNames() {
    return hyogoAreaData.keys.toList();
  }

  List<String> getNeighborhoods(String? cityOrWard) {
    if (cityOrWard == null || !hyogoAreaData.containsKey(cityOrWard)) return [];
    return hyogoAreaData[cityOrWard] ?? [];
  }

  void addSelectedArea() {
    if (_selectedCityOrWard != null && _selectedNeighborhood != null) {
      // ★変更: ここで city と town を抽出し、Map<String, String> を作成
      String city = _selectedCityOrWard!.replaceAll(RegExp(r'\(.*?\)'), '').trim();
      String town = _selectedNeighborhood!.trim();

      final Map<String, String> areaMap = {'city': city, 'town': town};

      // 重複チェック: cityとtownが同じ組み合わせのものが既にないか確認
      bool isDuplicate = _selectedDesiredAreas.any(
        (existingArea) => existingArea['city'] == areaMap['city'] && existingArea['town'] == areaMap['town'],
      );

      if (!isDuplicate) {
        setState(() {
          _selectedDesiredAreas.add(areaMap);
          widget.onAreasChanged(_selectedDesiredAreas); // 親ウィジェットにMapのリストを通知
        });
      }
    }
  }

  void removeSelectedArea(Map<String, String> areaToRemove) {
    setState(() {
      _selectedDesiredAreas.removeWhere(
        (area) => area['city'] == areaToRemove['city'] && area['town'] == areaToRemove['town'],
      );
      widget.onAreasChanged(_selectedDesiredAreas); // 親ウィジェットに通知
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = Colors.teal[800]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 市・区の選択ドロップダウン
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: '市・区',
            hintText: '市・区を選択 (Select City/Ward)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.location_city, color: mainColor),
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
          ),
          value: _selectedCityOrWard,
          items: getCityOrWardNames()
              .map((name) => DropdownMenuItem(value: name, child: Text(name)))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedCityOrWard = val;
              _selectedNeighborhood = null;
            });
          },
        ),
        Text(
          'City/Ward',
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),

        // 地域・丁目の選択ドロップダウン
        if (_selectedCityOrWard != null)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '地域・丁目',
                hintText: '地域・丁目を選択 (Select Neighborhood/Block)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.place, color: mainColor),
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
              ),
              value: _selectedNeighborhood,
              items: getNeighborhoods(_selectedCityOrWard)
                  .map((neighborhood) =>
                      DropdownMenuItem(value: neighborhood, child: Text(neighborhood)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedNeighborhood = val;
                });
              },
            ),
          ),
        if (_selectedCityOrWard != null)
          Text(
            'Neighborhood/Block',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            onPressed: (_selectedCityOrWard != null && _selectedNeighborhood != null)
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

        if (_selectedDesiredAreas.isNotEmpty)
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
              // ★変更: Mapのリストを表示するために ListTileのtitleも変更
              ..._selectedDesiredAreas.map((areaMap) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(
                        '${areaMap['city'] ?? ''} > ${areaMap['town'] ?? ''}', // 表示用に整形
                        style: const TextStyle(fontSize: 15),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeSelectedArea(areaMap),
                      ),
                    ),
                  )),
            ],
          ),
      ],
    );
  }
}