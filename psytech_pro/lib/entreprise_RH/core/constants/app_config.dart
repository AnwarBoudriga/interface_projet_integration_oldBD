/// Réglages du frontend.
class AppConfig {
  AppConfig._();

  /// false = l'application démarre vide (comme les maquettes).
  /// true  = des données de démonstration sont préchargées
  /// (tests, questions, banque, candidats, un résultat).
  static const bool useDemoData = false;
}
