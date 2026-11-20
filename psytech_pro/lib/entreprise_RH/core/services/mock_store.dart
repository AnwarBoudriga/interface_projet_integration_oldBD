import 'dart:math';

import 'package:flutter/foundation.dart';

import '../constants/app_config.dart';
import '../models/candidate_result.dart';
import '../models/invitation_model.dart';
import '../models/question_model.dart';
import '../models/test_model.dart';
import 'csv_parser.dart';

/// Données fictives locales partagées par tous les écrans (aucun backend).
class MockStore extends ChangeNotifier {
  MockStore._() {
    if (AppConfig.useDemoData) _seedDemo();
  }

  static final MockStore instance = MockStore._();

  final List<TestModel> _tests = [];
  final List<QuestionModel> _questions = [];
  final List<QuestionModel> _bank = [];
  final List<InvitationModel> _invitations = [];
  final Map<String, CandidateResult> _results = {};
  final Random _random = Random();
  String? _selectedTestId;
  int _seq = 0;

  String _id(String prefix) => '$prefix${++_seq}';

  // ---------------- Lecture ----------------
  List<TestModel> get tests => List.unmodifiable(_tests);
  List<TestModel> get publishedTests =>
      _tests.where((t) => t.published).toList();
  TestModel? get selectedTest => testById(_selectedTestId);

  TestModel? testById(String? id) {
    if (id == null) return null;
    for (final t in _tests) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<QuestionModel> questionsOf(String testId) =>
      _questions.where((q) => q.testId == testId).toList();

  List<QuestionModel> get selectedQuestions {
    final t = selectedTest;
    return t == null ? <QuestionModel>[] : questionsOf(t.id);
  }

  List<QuestionModel> get bank => List.unmodifiable(_bank);

  /// Plus récentes d'abord.
  List<InvitationModel> get invitations =>
      List.unmodifiable(_invitations.reversed);

  CandidateResult? resultFor(String invitationId) => _results[invitationId];
  List<CandidateResult> get results => _results.values.toList();

  // ---------------- Tests ----------------
  void selectTest(String? id) {
    _selectedTestId = id;
    notifyListeners();
  }

  TestModel createTest({
    required String title,
    required String description,
    required int durationMinutes,
    required String category,
    required int minScore,
    required bool showScore,
  }) {
    final t = TestModel(
      id: _id('t'),
      title: title,
      description: description,
      durationMinutes: durationMinutes,
      category: category,
      minScore: minScore,
      showScore: showScore,
    );
    _tests.add(t);
    _selectedTestId ??= t.id;
    notifyListeners();
    return t;
  }

  TestModel? duplicateTest(String id) {
    final src = testById(id);
    if (src == null) return null;
    final copy = TestModel(
      id: _id('t'),
      title: '${src.title} (copie)',
      description: src.description,
      durationMinutes: src.durationMinutes,
      category: src.category,
      minScore: src.minScore,
      showScore: src.showScore,
    );
    _tests.add(copy);
    for (final q in questionsOf(src.id)) {
      _questions.add(q.copyWith(id: _id('q'), testId: copy.id));
    }
    _selectedTestId = copy.id;
    notifyListeners();
    return copy;
  }

  /// Retourne un message d'erreur, ou null si la publication a réussi.
  String? publishTest(String id) {
    final t = testById(id);
    if (t == null) return 'Test introuvable.';
    if (questionsOf(id).isEmpty) {
      return 'Ajoutez au moins une question avant de publier ce test.';
    }
    _replaceTest(t.copyWith(published: true));
    return null;
  }

  void unpublishTest(String id) {
    final t = testById(id);
    if (t != null) _replaceTest(t.copyWith(published: false));
  }

  void _replaceTest(TestModel t) {
    final i = _tests.indexWhere((e) => e.id == t.id);
    if (i >= 0) {
      _tests[i] = t;
      notifyListeners();
    }
  }

  // ---------------- Questions ----------------
  QuestionModel addQuestion({
    required String testId,
    required String text,
    required List<String> options,
    required int correctIndex,
    required int points,
  }) {
    final q = QuestionModel(
      id: _id('q'),
      testId: testId,
      text: text,
      options: options,
      correctIndex: correctIndex,
      points: points,
    );
    _questions.add(q);
    notifyListeners();
    return q;
  }

  void updateQuestion(QuestionModel q) {
    final i = _questions.indexWhere((e) => e.id == q.id);
    if (i >= 0) {
      _questions[i] = q;
      notifyListeners();
    }
  }

  void deleteQuestion(String id) {
    _questions.removeWhere((q) => q.id == id);
    notifyListeners();
  }

  /// [delta] = -1 (monter) ou +1 (descendre).
  void moveQuestion(String id, int delta) {
    final matches = _questions.where((e) => e.id == id).toList();
    if (matches.isEmpty) return;
    final q = matches.first;
    final sameTest = _questions.where((e) => e.testId == q.testId).toList();
    final i = sameTest.indexOf(q);
    final j = i + delta;
    if (j < 0 || j >= sameTest.length) return;
    final gi = _questions.indexOf(sameTest[i]);
    final gj = _questions.indexOf(sameTest[j]);
    final tmp = _questions[gi];
    _questions[gi] = _questions[gj];
    _questions[gj] = tmp;
    notifyListeners();
  }

  int addFromBank(String testId, Iterable<String> bankIds) {
    var n = 0;
    for (final b in _bank) {
      if (bankIds.contains(b.id)) {
        _questions.add(b.copyWith(id: _id('q'), testId: testId));
        n++;
      }
    }
    if (n > 0) notifyListeners();
    return n;
  }

  // ---------------- Invitations ----------------
  String _generateKey() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    String block() =>
        List.generate(4, (_) => chars[_random.nextInt(chars.length)]).join();
    return 'PT-${block()}-${block()}';
  }

  InvitationModel _newInvitation(
    String name,
    String email,
    TestModel test,
    DateTime expiresAt, {
    String status = 'Invité',
  }) {
    final inv = InvitationModel(
      id: _id('i'),
      name: name,
      email: email,
      testId: test.id,
      testTitle: test.title,
      expiresAt: expiresAt,
      key: _generateKey(),
      status: status,
    );
    _invitations.add(inv);
    return inv;
  }

  InvitationModel createInvitation({
    required String name,
    required String email,
    required TestModel test,
    required int days,
  }) {
    final inv = _newInvitation(
        name, email, test, DateTime.now().add(Duration(days: days)));
    notifyListeners();
    return inv;
  }

  int createInvitations(List<CsvRow> rows,
      {required TestModel test, required int days}) {
    final expiresAt = DateTime.now().add(Duration(days: days));
    for (final r in rows) {
      _newInvitation(r.name, r.email, test, expiresAt);
    }
    notifyListeners();
    return rows.length;
  }

  // ---------------- Données de démonstration ----------------
  void _seedDemo() {
    final t1 = createTest(
      title: 'Raisonnement logique',
      description: 'Évalue le raisonnement déductif et la logique.',
      durationMinutes: 30,
      category: 'Logique',
      minScore: 60,
      showScore: true,
    );
    createTest(
      title: 'Aptitudes numériques',
      description: 'Calcul mental et lecture de données chiffrées.',
      durationMinutes: 20,
      category: 'Numérique',
      minScore: 50,
      showScore: false,
    );

    addQuestion(
      testId: t1.id,
      text: 'Quelle est la suite logique : 2, 4, 8, 16, … ?',
      options: ['18', '24', '32', '64'],
      correctIndex: 2,
      points: 2,
    );
    addQuestion(
      testId: t1.id,
      text: 'Tous les A sont B. Tous les B sont C. Donc :',
      options: ['Tous les C sont A', 'Tous les A sont C', 'Aucun A n’est C', 'Certains C sont A'],
      correctIndex: 1,
      points: 2,
    );
    addQuestion(
      testId: t1.id,
      text: 'Quel nombre complète : 3, 6, 11, 18, … ?',
      options: ['25', '27', '29', '31'],
      correctIndex: 1,
      points: 1,
    );
    publishTest(t1.id);

    _bank.addAll([
      QuestionModel(
        id: _id('b'),
        testId: '',
        text: 'Quel mot est l’intrus : chaise, table, armoire, stylo ?',
        options: ['chaise', 'table', 'armoire', 'stylo'],
        correctIndex: 3,
        points: 1,
      ),
      QuestionModel(
        id: _id('b'),
        testId: '',
        text: '25 % de 240 vaut :',
        options: ['50', '60', '65', '80'],
        correctIndex: 1,
        points: 1,
      ),
      QuestionModel(
        id: _id('b'),
        testId: '',
        text: 'Si 3 ouvriers font un travail en 12 jours, 6 ouvriers le font en :',
        options: ['4 jours', '6 jours', '9 jours', '24 jours'],
        correctIndex: 1,
        points: 2,
      ),
    ]);

    final done = _newInvitation('Sara Ben Ali', 'sara.benali@example.com', t1,
        DateTime.now().add(const Duration(days: 5)),
        status: 'Terminé');
    _newInvitation('Karim Trabelsi', 'karim.trabelsi@example.com', t1,
        DateTime.now().add(const Duration(days: 7)));
    _newInvitation('Nour Haddad', 'nour.haddad@example.com', t1,
        DateTime.now().add(const Duration(days: 2)),
        status: 'En cours');

    final qs = questionsOf(t1.id);
    final chosen = [2, 0, 1];
    _results[done.id] = CandidateResult(
      invitationId: done.id,
      minScore: t1.minScore,
      lines: [
        for (var i = 0; i < qs.length; i++)
          ResultLine(
            question: qs[i].text,
            chosen: qs[i].optionLabel(chosen[i]),
            correct: qs[i].optionLabel(qs[i].correctIndex),
            earned: chosen[i] == qs[i].correctIndex ? qs[i].points : 0,
            points: qs[i].points,
          ),
      ],
    );
    _selectedTestId = t1.id;
  }
}
