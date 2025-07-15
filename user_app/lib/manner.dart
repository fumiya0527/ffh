import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'quiz_question.dart'; // QuizQuestionクラスをインポート
import 'house_select.dart';
// import 'main.dart'; // MyAppはmain.dartにあるため、ここでは不要（もしmain関数がここにあったら削除）
 // 例: クイズ完了後の遷移先としてホーム画面を想定

// URLを開くための非同期関数
Future<void> _launchURL(String urlString) async {
  final Uri url = Uri.parse(urlString);
  if (!await launchUrl(url)) {
    debugPrint('Could not launch $url');
    // エラーメッセージをユーザーに表示するスナックバーなどを追加することも検討
  }
}

// MyApp は main.dart にあるため、ここでは不要です。
// void main() {
//   runApp(const MyApp());
// }

// マナー画面
class MannerScreen extends StatelessWidget {
  const MannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // アプリ全体で使うメインの色を定義
    final Color mainBackgroundColor = const Color(0xFFEFF7F6); // やさしい背景色
    final Color mainColor = Colors.teal[800]!; // 濃いティール
    final Color secondaryColor = Colors.teal; // 明るいティール

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Manners',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 2),
            const Text(
              'マナーについて',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        centerTitle: false,
        automaticallyImplyLeading: false, // 戻るボタンを非表示にする (登録後必須フローのため)
      ),
      body: Container(
        color: mainBackgroundColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    Text(
                      'Learn about Japanese living manners',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '日本の生活マナーを学びましょう',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Google Drive リンク1を開くボタン
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      _launchURL('https://drive.google.com/file/d/1iLa-dmVviF42X1uSbgsNc_op-fjcmc3d/view?usp=drive_link');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Open Video 1',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '動画1を見る',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Google Drive リンク2を開くボタン
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      _launchURL('https://drive.google.com/file/d/10TSoY3ldXm72c_Zpwdo9AS_r9t7s2blc/view?usp=drive_link');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Open Video 2',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '動画2を見る',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // 次の画面へ遷移するボタン (クイズ)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QuizScreen()), // QuizScreenへ遷移
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor, // サブカラーを使用
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Start Quiz',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'クイズをはじめる',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// クイズ画面
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // --- クイズデータ ---
  final List<QuizQuestion> _questions = [
    QuizQuestion(
      questionText: 'Q1: 夜中にしてはいけないことは？ (What should you not do late at night?)',
      options: ['A) 料理 (Cooking)', 'B) 掃除機 (Vacuuming)', 'C) ゲーム (Playing games)'],
      correctAnswer: 'B) 掃除機 (Vacuuming)',
    ),
    QuizQuestion(
      questionText: 'Q2: ペットを許可なく飼っていいか？ (Is it okay to keep pets without permission?)',
      options: ['A) 飼ってはダメ (No, you cannot)', 'B) 飼っていい (Yes, you can)'],
      correctAnswer: 'A) 飼ってはダメ (No, you cannot)',
    ),
    QuizQuestion(
      questionText: 'Q3: 共有スペースは物を置いたり自由に使っていい？ (Is it okay to put things in common spaces or use them freely?)',
      options: ['A) 正しい (Correct)', 'B) 間違っている (Incorrect)'],
      correctAnswer: 'B) 間違っている (Incorrect)',
    ),
    QuizQuestion(
      questionText: 'Q4: 部屋の中でしてはいけないことは？ (What should you not do inside your room?)',
      options: ['A) 読書 (Reading)', 'B) ゲーム (Playing games)', 'C) 楽器演奏 (Playing musical instruments)'],
      correctAnswer: 'C) 楽器演奏 (Playing musical instruments)',
    ),
    QuizQuestion(
      questionText: 'Q5: 自転車、バイク、車はいつでも持ってもいい？ (Is it okay to own a bicycle, motorcycle, or car at any time?)',
      options: ['A) 良い (Yes)', 'B) 届け出が必要 (Notification is required)'],
      correctAnswer: 'B) 届け出が必要 (Notification is required)',
    ),
  ];

  int _currentQuestionIndex = 0;
  String? _selectedOption;
  int _score = 0;
  bool _isQuizCompleted = false; // クイズが終了したかどうかのフラグ
  bool _isQuizPassed = false; // クイズに合格したかどうかのフラグ（全問正解）

  void _nextQuestion() {
    setState(() {
      if (_selectedOption == _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }

      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _selectedOption = null; // 次の問題へ進む前に選択肢をリセット
      } else {
        // 全問終了
        _isQuizCompleted = true;
        _isQuizPassed = (_score == _questions.length); // 全問正解か判定
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    // アプリ全体で使うメインの色を定義
    final Color mainColor = Colors.teal[800]!; // 濃いティール

    showDialog(
      context: context,
      barrierDismissible: false, // ダイアログ外タップで閉じない
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            _isQuizPassed ? '全問正解！ (Perfect Score!)' : 'クイズ結果 (Quiz Result)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isQuizPassed ? mainColor : Colors.red[700],
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isQuizPassed ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: _isQuizPassed ? mainColor : Colors.red[700],
                size: 60,
              ),
              const SizedBox(height: 15),
              Text(
                _isQuizPassed
                    ? 'おめでとうございます！\n全問正解です！\n(Congratulations! You got all correct!)'
                    : '残念！\n${_questions.length}問中 $_score 問正解でした。\n(Too bad! You got $_score out of ${_questions.length} correct.)',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            // クイズ完了後のボタン
            if (_isQuizPassed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: Column(
                    children: [
                      Text('Start App', style: TextStyle(fontSize: 14, color: Colors.white70)),
                      const SizedBox(height: 2),
                      const Text('アプリをはじめる', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // ダイアログを閉じる

                    // 正しい画面遷移のコード
                    Navigator.push( // または Navigator.pushAndRemoveUntil
                      context,
                      MaterialPageRoute(builder: (context) => const HouseSelectScreen()), // あなたのクラス名に合わせる
                    );
                  },
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                      ),
                      child: Column(
                        children: [
                          Text('Try Again', style: TextStyle(fontSize: 14, color: Colors.white70)),
                          const SizedBox(height: 2),
                          const Text('もう一度プレイ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // ダイアログを閉じる
                        setState(() {
                          _currentQuestionIndex = 0;
                          _score = 0;
                          _selectedOption = null;
                          _isQuizCompleted = false; // フラグもリセット
                          _isQuizPassed = false; // フラグもリセット
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: mainColor,
                        side: BorderSide(color: mainColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: Column(
                        children: [
                          Text('Back to Manners', style: TextStyle(fontSize: 14, color: mainColor.withOpacity(0.8))),
                          const SizedBox(height: 2),
                          Text('マナー画面に戻る', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainColor)),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // ダイアログを閉じる
                        Navigator.of(context).pop(); // クイズ画面を閉じてマナー画面に戻る
                      },
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // アプリ全体で使うメインの色を定義
    final Color mainBackgroundColor = const Color(0xFFEFF7F6); // やさしい背景色
    final Color mainColor = Colors.teal[800]!; // 濃いティール
    final Color secondaryColor = Colors.teal; // 明るいティール

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 2),
            const Text(
              'クイズ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        centerTitle: false,
        automaticallyImplyLeading: false, // 戻るボタンを非表示にする (クイズ中は戻れないように)
      ),
      body: Container(
        color: mainBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 問題数表示
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700.withOpacity(0.8)), // ★修正点★
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '問題 ${_currentQuestionIndex + 1}/${_questions.length}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 質問文
              Text(
                currentQuestion.questionText,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 30),

              // 選択肢
              ...currentQuestion.options.map((option) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: _selectedOption == option ? 4 : 1, // 選択時に影を強調
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: _selectedOption == option ? mainColor : Colors.grey.shade300, // 選択時に枠線を強調
                      width: _selectedOption == option ? 2 : 1,
                    ),
                  ),
                  child: RadioListTile<String>(
                    title: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _selectedOption == option ? mainColor : Colors.black87, // 選択時のテキスト色
                      ),
                    ),
                    value: option,
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                    activeColor: mainColor, // ラジオボタンの色
                  ),
                );
              }).toList(),
              const Spacer(),

              // 次へ/結果を見る ボタン
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _selectedOption == null
                      ? null
                      : _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentQuestionIndex < _questions.length - 1
                            ? 'Next Question'
                            : 'See Result',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentQuestionIndex < _questions.length - 1
                            ? '次の問題へ'
                            : '結果を見る',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
