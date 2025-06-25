import 'package:flutter/material.dart';

class AreaSelector extends StatefulWidget {
  const AreaSelector({super.key});

  @override
  State<AreaSelector> createState() => _AreaSelectorState();
}

class _AreaSelectorState extends State<AreaSelector> {
  String? _region;
  String? _prefecture;
  String? _city;

  final List<String> selectedAreas = [];

  final Map<String, Map<String, List<String>>> areaData = {
    '北海道・東北': {
      '北海道': ['札幌市', '函館市', '旭川市','その他'],
      '青森県': ['青森市', '八戸市','その他'],
      '岩手県': ['盛岡市', '一関市','その他'],
      '宮城県': ['仙台市', '石巻市','その他'],
      '秋田県': ['秋田市','その他'],
      '山形県': ['山形市','その他'],
      '福島県': ['福島市', '郡山市','その他'],
    },
    '北陸': {
      '富山県': ['富山市', '高岡市','その他'],
      '石川県': ['金沢市', '小松市','その他'],
      '福井県': ['福井市', '敦賀市','その他'],
    },
    '甲信越': {
      '新潟県': ['新潟市', '長岡市','その他'],
      '山梨県': ['甲府市','その他'],
      '長野県': ['長野市', '松本市','その他'],
    },
    '関東': {
      '東京都': ['千代田区','中央区','港区','新宿区','文京区','台東区','墨田区','江東区',
                '品川区','目黒区','大田区','世田谷区','渋谷区','中野区','杉並区','豊島区',
                '北区','荒川区','板橋区','練馬区','足立区','葛飾区','江戸川区','その他市部'],
      '神奈川県': ['横浜市','川崎市','相模原市','その他'],
      '埼玉県': ['さいたま市','川越市','その他'],
      '千葉県': ['千葉市','船橋市','その他'],
      '茨城県': ['水戸市','つくば市','その他'],
      '栃木県': ['宇都宮市','その他'],
      '群馬県': ['前橋市','その他'],
    },
    '東海': {
      '静岡県': ['静岡市','浜松市','その他'],
      '愛知県': ['名古屋市','豊橋市','その他'],
      '岐阜県': ['岐阜市','その他'],
      '三重県': ['津市','四日市市','その他'],
    },
    '近畿': {
      '大阪府': ['大阪市都島区','大阪市福島区','大阪市此花区','大阪市西区','大阪市港区',
                '大阪市大正区','大阪市天王寺区','大阪市浪速区','大阪市西淀川区','大阪市東淀川区',
                '大阪市東成区','大阪市生野区','大阪市旭区','大阪市城東区','大阪市淀川区',
                '大阪市鶴見区','大阪市住之江区','大阪市平野区','大阪市北区','大阪市中央区','堺市','その他'],
      '京都府': ['京都市','その他'],
      '兵庫県': ['神戸市', '西宮市','その他'],
      '奈良県': ['奈良市','その他'],
      '滋賀県': ['大津市','その他'],
      '和歌山県': ['和歌山市','その他'],
    },
    '中国': {
      '広島県': ['広島市','その他'],
      '岡山県': ['岡山市','その他'],
      '山口県': ['下関市','山口市','その他'],
      '鳥取県': ['鳥取市','その他'],
      '島根県': ['松江市','その他'],
    },
    '四国': {
      '徳島県': ['徳島市','その他'],
      '香川県': ['高松市','その他'],
      '愛媛県': ['松山市','その他'],
      '高知県': ['高知市','その他'],
    },
    '九州・沖縄': {
      '福岡県': ['福岡市', '北九州市','その他'],
      '佐賀県': ['佐賀市','その他'],
      '長崎県': ['長崎市','その他'],
      '熊本県': ['熊本市','その他'],
      '大分県': ['大分市','その他'],
      '宮崎県': ['宮崎市','その他'],
      '鹿児島県': ['鹿児島市','その他'],
      '沖縄県': ['那覇市','その他'],
    },
  };

  List<String> getPrefectures() {
    if (_region == null) return [];
    return areaData[_region!]!.keys.toList();
  }

  List<String> getCities() {
    if (_region == null || _prefecture == null) return [];
    return areaData[_region!]![_prefecture!] ?? [];
  }

  void addSelectedArea() {
    if (_region != null && _prefecture != null && _city != null) {
      final area = '$_region > $_prefecture > $_city';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("希望エリアを選択（複数可）",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: '地域カテゴリ'),
          value: _region,
          items: areaData.keys
              .map((region) =>
                  DropdownMenuItem(value: region, child: Text(region)))
              .toList(),
          onChanged: (val) {
            setState(() {
              _region = val;
              _prefecture = null;
              _city = null;
            });
          },
        ),

        if (_region != null)
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: '都道府県'),
            value: _prefecture,
            items: getPrefectures()
                .map((pref) =>
                    DropdownMenuItem(value: pref, child: Text(pref)))
                .toList(),
            onChanged: (val) {
              setState(() {
                _prefecture = val;
                _city = null;
              });
            },
          ),

        if (_prefecture != null)
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: '市区町村'),
            value: _city,
            items: getCities()
                .map((city) =>
                    DropdownMenuItem(value: city, child: Text(city)))
                .toList(),
            onChanged: (val) {
              setState(() {
                _city = val;
              });
            },
          ),

        const SizedBox(height: 10),

        ElevatedButton(
          onPressed:
              (_region != null && _prefecture != null && _city != null)
                  ? addSelectedArea
                  : null,
          child: const Text('この希望エリアを追加'),
        ),

        const SizedBox(height: 20),

        if (selectedAreas.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '選択された希望エリア:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...selectedAreas.map((area) => ListTile(
                    title: Text(area),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeSelectedArea(area),
                    ),
                  )),
            ],
          ),
      ],
    );
  }
}
