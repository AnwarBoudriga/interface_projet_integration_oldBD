class InvitationModel {
  const InvitationModel({
    required this.id,
    required this.name,
    required this.email,
    required this.testId,
    required this.testTitle,
    required this.expiresAt,
    required this.key,
    this.status = 'Invité',
  });

  final String id;
  final String name;
  final String email;
  final String testId;
  final String testTitle;
  final DateTime expiresAt;
  final String key;

  /// « Invité », « En cours » ou « Terminé ».
  final String status;

  String get displayStatus =>
      (status != 'Terminé' && expiresAt.isBefore(DateTime.now()))
          ? 'Expiré'
          : status;
}
