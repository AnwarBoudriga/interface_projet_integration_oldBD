class ResultLine {
  const ResultLine({
    required this.question,
    required this.chosen,
    required this.correct,
    required this.earned,
    required this.points,
  });

  final String question;
  final String chosen;
  final String correct;
  final int earned;
  final int points;
}

class CandidateResult {
  const CandidateResult({
    required this.invitationId,
    required this.lines,
    required this.minScore,
  });

  final String invitationId;
  final List<ResultLine> lines;
  final int minScore;

  int get score => lines.fold(0, (sum, l) => sum + l.earned);
  int get total => lines.fold(0, (sum, l) => sum + l.points);
  double get percent => total == 0 ? 0 : score * 100 / total;
  bool get passed => percent >= minScore;
}
