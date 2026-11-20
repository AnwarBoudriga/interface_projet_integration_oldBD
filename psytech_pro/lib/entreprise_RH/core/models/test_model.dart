class TestModel {
  const TestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.category,
    required this.minScore,
    required this.showScore,
    this.published = false,
  });

  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final String category;

  /// Score minimum de réussite, en pourcentage (0-100).
  final int minScore;
  final bool showScore;
  final bool published;

  TestModel copyWith({bool? published}) => TestModel(
        id: id,
        title: title,
        description: description,
        durationMinutes: durationMinutes,
        category: category,
        minScore: minScore,
        showScore: showScore,
        published: published ?? this.published,
      );
}
