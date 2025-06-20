import 'package:flutter/material.dart';

class AreaSelector extends StatefulWidget {
  const AreaSelector({Key? key}) : super(key: key);
  @override
  _AreaSelectorState createState() => _AreaSelectorState();
}

class _AreaSelectorState extends State<AreaSelector> {
  String? _selectedRegion;
  String? _selectedPrefecture;
  String? _selectedCity;

  final Map<String, Map<String, List<String>>> areaData = {
    '関西': {
      '大阪府': ['梅田', 'なんば', '天王寺'],
      '京都府': ['京都市', '宇治市'],
      '兵庫県': ['神戸市', '西宮市'],
    },
    '関東': {
      '東京都': ['新宿', '渋谷', '池袋'],
      '神奈川県': ['横浜市', '川崎市'],
      '千葉県': ['千葉市', '船橋市'],
    },
    '中部': {
      '愛知県': ['名古屋市', '豊田市'],
      '静岡県': ['静岡市', '浜松市'],
    },
    '北海道・東北': {
      '北海道': ['札幌市', '旭川市'],
      '宮城県': ['仙台市', '石巻市'],
    },
    '中国・四国': {
      '広島県': ['広島市', '福山市'],
      '香川県': ['高松市'],
    },
    '九州・沖縄': {
      '福岡県': ['福岡市', '北九州市'],
      '沖縄県': ['那覇市'],
    }
  };

  List<String> getPrefectures() {
    if (_selectedRegion == null) return [];
    return areaData[_selectedRegion!]!.keys.toList();
  }

  List<String> getCities() {
    if (_selectedRegion == null || _selectedPrefecture == null) return [];
    return areaData[_selectedRegion!]![_selectedPrefecture!] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('希望エリアを選択してください',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

        SizedBox(height: 12),

        // 地域カテゴリ
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: '地域カテゴリ（例：関東・関西など）'),
          value: _selectedRegion,
          items: areaData.keys
              .map((region) => DropdownMenuItem(
                    value: region,
                    child: Text(region),
                  ))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedRegion = val;
              _selectedPrefecture = null;
              _selectedCity = null;
            });
          },
        ),

        // 都道府県
        if (_selectedRegion != null)
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: '都道府県'),
            value: _selectedPrefecture,
            items: getPrefectures()
                .map((pref) => DropdownMenuItem(
                      value: pref,
                      child: Text(pref),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedPrefecture = val;
                _selectedCity = null;
              });
            },
          ),

        // 市区町村
        if (_selectedPrefecture != null)
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: '市・区など'),
            value: _selectedCity,
            items: getCities()
                .map((city) => DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedCity = val;
              });
            },
          ),

        SizedBox(height: 20),

        if (_selectedCity != null)
          Text(
            '選択された希望地：$_selectedRegion > $_selectedPrefecture > $_selectedCity',
            style: TextStyle(color: Colors.green.shade700, fontSize: 16),
          ),
      ],
    );
  }
}
