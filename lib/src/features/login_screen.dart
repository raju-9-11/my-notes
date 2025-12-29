
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mock_auth_service.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'My Journal',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Sign in with Email'),
                onPressed: () => auth.signInWithEmail('test@test.com', 'password'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Sign in with Google'),
                onPressed: () => auth.signInWithGoogle(),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => auth.signInAnonymously(),
                child: const Text('Continue as Guest (Offline Mode)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
