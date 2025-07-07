import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'quiz_question.dart'; // QuizQuestionクラスをインポート

// URLを開くための非同期関数をトップレベルに移動 (変更なし)
Future<void> _launchURL(String urlString) async {
  final Uri url = Uri.parse(urlString);
  if (!await launchUrl(url)) {
    debugPrint('Could not launch $url');
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '画面遷移サンプル',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マナーについて'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Google Drive リンク1を開くボタン
            ElevatedButton(
              onPressed: () {
                _launchURL('https://drive.google.com/file/d/120kXCEsqjI9p9plddjQa1j25sqQY9PTH/view?usp=drive_link');
              },
              child: const Text('Google Drive リンク1を開く'),
            ),
            const SizedBox(height: 20),
            // Google Drive リンク2を開くボタン
            ElevatedButton(
              onPressed: () {
                _launchURL('https://drive.google.com/file/d/10TSoY3ldXm72c_Zpwdo9AS_r9t7s2blc/view?usp=drive_link');
              },
              child: const Text('Google Drive リンク2を開く'),
            ),
            const SizedBox(height: 20),
            // 次の画面へ遷移するボタン
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondScreen()),
                );
              },
              child: const Text('次の画面へ (クイズ)'),
            ),
          ],
        ),
      ),
    );
  }
}

// SecondScreen の変更
class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  // --- クイズデータ ---
  final List<QuizQuestion> _questions = [
    QuizQuestion(
      questionText: 'Q1: 夜中にしてはいけないことは？',
      options: ['A) 料理', 'B) 掃除機', 'C) ゲーム'],
      correctAnswer: 'B) 掃除機',
    ),
    QuizQuestion(
      questionText: 'Q2: ペットを許可なく飼っていいか？',
      options: ['A) 飼ってはダメ', 'B) 飼っていい'],
      correctAnswer: 'A) 飼ってはダメ',
    ),
    QuizQuestion(
      questionText: 'Q3: 共有スペースは物を置いたり自由に使っていい？',
      options: ['A) 正しい', 'B) 間違っている'],
      correctAnswer: 'B) 間違っている',
    ),
    QuizQuestion(
      questionText: 'Q4: 部屋の中でしてはいけないことは？',
      options: ['A) 読書', 'B) ゲーム', 'C) 楽器演奏'],
      correctAnswer: 'C) 楽器演奏',
    ),
    QuizQuestion(
      questionText: 'Q5: 自転車、バイク、車はいつでも持ってもいい？',
      options: ['A) 良い', 'B) 届け出が必要'],
      correctAnswer: 'B) 届け出が必要',
    ),
  ];

  int _currentQuestionIndex = 0;
  String? _selectedOption;
  int _score = 0;
  // ★追加: クイズが終了し、かつ全問正解だったかを示すフラグ
  bool _isQuizCompletedAndCorrect = false;

  void _nextQuestion() {
    setState(() {
      if (_selectedOption == _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }

      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _selectedOption = null;
      } else {
        // 全問終了
        _isQuizCompletedAndCorrect = (_score == _questions.length); // 全問正解か判定
        _showResult();
      }
    });
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(_isQuizCompletedAndCorrect ? '全問正解！' : 'クイズ結果'),
          content: Text(_isQuizCompletedAndCorrect
              ? 'おめでとうございます！全問正解です！'
              : '残念！5問中 $_score 問正解でした。'),
          actions: <Widget>[
            TextButton(
              child: Text(_isQuizCompletedAndCorrect ? 'クイズを終了する' : '最初のページに戻る'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ダイアログを閉じる
                if (_isQuizCompletedAndCorrect) {
                  // 全問正解の場合、クイズ画面を閉じて、別の状態を表示するためにsetState
                  // ここでは画面遷移ではなく、同じSecondScreen内のUIを切り替えるため、
                  // あえてNavigator.pop()でSecondScreenを閉じず、状態を変更する
                  setState(() {
                    // 何もしないか、あるいはQuizScreen内のUIを全問正解表示に切り替えるフラグを設定
                  });
                } else {
                  // 不正解の場合、最初のページに戻る
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
            // 再挑戦ボタン
            TextButton(
              child: const Text('もう一度プレイ'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ダイアログを閉じる
                setState(() {
                  _currentQuestionIndex = 0;
                  _score = 0;
                  _selectedOption = null;
                  _isQuizCompletedAndCorrect = false; // フラグもリセット
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ★変更: クイズが全問正解で終了した場合のUI
    if (_isQuizCompletedAndCorrect && _currentQuestionIndex == _questions.length - 1) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('おめでとうございます！'),
          automaticallyImplyLeading: false, // 戻るボタンを非表示にする
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 100.0,
              ),
              const SizedBox(height: 20),
              const Text(
                '全問正解おめでとうございます！',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // 最初のページに戻る
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('最初のページに戻る'),
              ),
            ],
          ),
        ),
      );
    } else {
      // 通常のクイズ画面のUI
      final currentQuestion = _questions[_currentQuestionIndex];
      return Scaffold(
        appBar: AppBar(
          title: const Text('クイズ画面'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                '問題 ${_currentQuestionIndex + 1}/${_questions.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                currentQuestion.questionText,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ...currentQuestion.options.map((option) {
                return RadioListTile<String>(
                  title: Text(option, style: const TextStyle(fontSize: 18)),
                  value: option,
                  groupValue: _selectedOption,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedOption = value;
                    });
                  },
                );
              }).toList(),
              const Spacer(),
              ElevatedButton(
                onPressed: _selectedOption == null
                    ? null
                    : _nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(
                  _currentQuestionIndex < _questions.length - 1
                      ? '次の問題へ'
                      : '結果を見る',
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    }
  }
}