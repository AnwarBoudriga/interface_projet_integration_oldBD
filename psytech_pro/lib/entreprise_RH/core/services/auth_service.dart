/// Service d'authentification fictif (aucun backend).
class AuthService {
  /// Clé de démonstration acceptée par le mock.
  static const String mockCompanyKey = 'PSYTECH-2026';

  Future<bool> loginWithCompanyKey(String key) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return key.trim().toUpperCase() == mockCompanyKey;
  }
}
