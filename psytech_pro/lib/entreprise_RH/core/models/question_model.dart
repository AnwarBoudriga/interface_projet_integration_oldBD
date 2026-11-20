class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.testId,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.points,
  });

  final String id;

  /// Vide pour une question de la banque.
  final String testId;
  final String text;
  final List<String> options;
  final int correctIndex;
  final int points;

  String get correctLabel => String.fromCharCode(65 + correctIndex);

  String optionLabel(int index) =>
      '${String.fromCharCode(65 + index)}. ${options[index]}';

  QuestionModel copyWith({
    String? id,
    String? testId,
    String? text,
    List<String>? options,
    int? correctIndex,
    int? points,
  }) =>
      QuestionModel(
        id: id ?? this.id,
        testId: testId ?? this.testId,
        text: text ?? this.text,
        options: options ?? this.options,
        correctIndex: correctIndex ?? this.correctIndex,
        points: points ?? this.points,
      );
}
