import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Picker Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DateSelectionScreen(),
    );
  }
}

// --- 日付選択を行うメイン画面 ---
class DateSelectionScreen extends StatefulWidget {
  const DateSelectionScreen({super.key});

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  DateTime? _selectedDate; // 選択された日付を保持する変数

  // 日付ピッカーを表示する関数
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000), // 例: 2000年1月1日から
      lastDate: DateTime(2030), // 例: 2030年12月31日まで
      // (オプション) カレンダーピッカーのテーマをカスタマイズ
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // ヘッダーの背景色
              onPrimary: Colors.white, // ヘッダーのテキスト色
              onSurface: Colors.black, // カレンダー内の日付のテキスト色
            ),
            dialogBackgroundColor: Colors.white, // ダイアログの背景色
          ),
          child: child!,
        );
      },
    );

    // ユーザーが日付を選択して「OK」を押した場合
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // 選択された日付を更新
      });
    }
  }

  // 確定ボタンが押された時の処理
  void _confirmDateAndNavigate() {
    if (_selectedDate == null) {
      // 日付が選択されていない場合はエラーメッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日付を選択してください。')),
      );
      return;
    }

    // 次の画面（時間帯設定画面）に遷移し、選択された日付を渡す
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimeSelectionScreen(selectedDate: _selectedDate!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('面談の日程を選択してください'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 選択された日付を表示
            Text(
              _selectedDate == null
                  ? '日付が選択されていません'
                  : '選択された日付: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // 日付ピッカーを表示するためのボタン
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: const Text('日付を選択'),
            ),
            const SizedBox(height: 30), // 「確定」ボタンとの間にスペースを追加
            // 確定ボタン
            ElevatedButton(
              onPressed: _confirmDateAndNavigate, // 確定ボタンの処理
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('次へ'),
            ),
          ],
        ),
      ),
    );
  }
}


// --- 選択された日付を受け取り、時間帯を設定する画面 ---
class TimeSelectionScreen extends StatefulWidget {
  final DateTime selectedDate; // 前の画面から受け取る日付情報

  const TimeSelectionScreen({super.key, required this.selectedDate});

  @override
  State<TimeSelectionScreen> createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  TimeOfDay? _selectedTime; // 選択された時間帯を保持する変数

  // 時間ピッカーを表示する関数
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(), // 初期表示時間
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked; // 選択された時間帯を更新
      });
    }
  }

  // 予約確定ボタンが押された時の処理
  void _confirmReservation() {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('時間帯を選択してください。')),
      );
      return;
    }

    // ここで日付と時間帯が確定したことになる
    // 例: サーバーに予約情報を送信する、最終確認画面に遷移するなど

    // 予約情報を表示するアラート
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('予約確定'),
          content: Text(
            '以下の日程で予約しました:\n'
            '日付: ${widget.selectedDate.year}年${widget.selectedDate.month}月${widget.selectedDate.day}日\n'
            '時間: ${_selectedTime!.format(context)}', // 時間をフォーマットして表示
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // アラートを閉じる
                // 必要であれば、元の画面（日付選択画面）に戻る
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('時間帯設定'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '選択された日付: ${widget.selectedDate.year}年${widget.selectedDate.month}月${widget.selectedDate.day}日',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // 選択された時間帯を表示
            Text(
              _selectedTime == null
                  ? '時間帯が選択されていません'
                  : '選択された時間帯: ${_selectedTime!.format(context)}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // 時間ピッカーを表示するためのボタン
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: const Text('時間帯を選択'),
            ),
            const SizedBox(height: 30),
            // 予約確定ボタン
            ElevatedButton(
              onPressed: _confirmReservation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('予約確定'),
            ),
          ],
        ),
      ),
    );
  }
}