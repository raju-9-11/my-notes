
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return MockAuthService();
});

class MockAuthService implements AuthService {
  final _controller = StreamController<String?>.broadcast();
  String? _currentUser;

  MockAuthService() {
    _controller.add(null);
  }

  @override
  Stream<String?> get authStateChanges => _controller.stream;

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = 'mock_email_user_id';
    _controller.add(_currentUser);
  }

  @override
  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = 'mock_google_user_id';
    _controller.add(_currentUser);
  }

  @override
  Future<void> signInAnonymously() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = 'guest_user_id';
    _controller.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _controller.add(_currentUser);
  }

  @override
  String? get currentUser => _currentUser;
}
