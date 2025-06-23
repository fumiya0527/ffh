import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hero Demo',
      theme: ThemeData(primarySwatch: Colors.green),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<String> pictureBox = [
    'assets/home1.jpg',
    'assets/home2.jpg',
    'assets/home3.jpg',
  ];
  int i = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('Main Screen')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'imageHero',
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) =>
                        DetailScreen(imagePath: pictureBox[i]),
                  ));
                },
                child: Image.asset(
                  pictureBox[i],
                  width: screenWidth * 0.5,
                  height: screenWidth * 0.1,
                  fit: BoxFit.cover,
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
                  i = (i + 1) % pictureBox.length;
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('次の画像へ'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  i = (i +pictureBox.length-1 ) % pictureBox.length;
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('前の画像へ'),
            ),
            
              ]
            )
          ],
        
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String imagePath;

  const DetailScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  imagePath,
                  width: screenWidth * 0.5,
                  height: screenWidth * 0.1,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
          
                const Text(
                  'これは説明のテキストです',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed:() {
                    print('ここに物件を選択した先の大家との対談を作る');
                  },
                  child: const Text('botann'),
                ),


                
              ],
              
              
            ),
          ),
        ),
      ),
    );
  }
}