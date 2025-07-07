// quiz_question.dart
class QuizQuestion {
  final String questionText;
  final List<String> options;
  final String correctAnswer;

  const QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });
}