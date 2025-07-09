import 'package:flutter/material.dart';
import 'login.dart'; // 遷移先画面
 
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    final Color mainColor = Colors.teal[800]!;
 
    return Scaffold(
      backgroundColor: const Color(0xFFEFF7F6), // やさしい背景色
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Text(
                  'For foreigner home',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                    letterSpacing: 1.5,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Kind',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.teal,
                              ),
                            ),
                            Text(
                              'やさしい',
                              style: TextStyle(
                                fontSize: 30,
                                color: mainColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const WidgetSpan(child: SizedBox(width: 16)),
 
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Japanese',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.teal,
                              ),
                            ),
                            Text(
                              '日本語',
                              style: TextStyle(
                                fontSize: 30,
                                color: mainColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const WidgetSpan(child: SizedBox(width: 16)),
 
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Housing Search',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.teal,
                              ),
                            ),
                            Text(
                              '住宅検索',
                              style: TextStyle(
                                fontSize: 30,
                                color: mainColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginChoiceScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Column(
                children: const [
                  Text(
                    'START',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'はじめる',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}