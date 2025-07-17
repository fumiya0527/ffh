import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; 
import 'firebase_options.dart';
import 'Auth.dart';
import 'main.dart';
import 'AddProperty.dart';
import 'OwnedProperties.dart';
import 'OwnerPersonal.dart';

//オーナーホーム画面クラス
class OwnerHomeScreen extends StatefulWidget {
  final String currentOwnerId;
  const OwnerHomeScreen({super.key, required this.currentOwnerId});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      //OwnerPersonalInfoScreen(ownerId: widget.currentOwnerId),
      OwnedPropertiesListScreen(currentOwnerId: widget.currentOwnerId),
      const AddPropertyScreen(),
      OwnerPersonalInfoScreen(ownerId: widget.currentOwnerId),
    ];
  }

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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ログアウトしました。')),
              );
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

// class OwnerPersonalInfoScreen extends StatelessWidget {
//   final String ownerId;
//   const OwnerPersonalInfoScreen({super.key, required this.ownerId});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         '個人情報設定画面\n(ログイン中のオーナーID: ${ownerId})\nここにユーザー名、連絡先などの設定UIを実装',
//         textAlign: TextAlign.center,
//         style: const TextStyle(fontSize: 18, color: Colors.black54),
//       ),
//     );
//   }
// }