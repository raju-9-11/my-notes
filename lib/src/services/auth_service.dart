
abstract class AuthService {
  Stream<String?> get authStateChanges;
  Future<void> signInWithEmail(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signInAnonymously();
  Future<void> signOut();
  String? get currentUser;
}
