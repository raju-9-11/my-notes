
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/services/mock_auth_service.dart';
import 'src/services/storage_service.dart';
import 'src/features/login_screen.dart';
import 'src/features/home_screen.dart';
import 'src/features/journal/journal_list_screen.dart';
import 'src/features/journal/journal_editor_screen.dart';
import 'src/features/calendar/calendar_screen.dart';
import 'src/features/alarms/alarm_screen.dart';
import 'src/features/lists/list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final storageService = LocalStorageService();
  await storageService.init();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const MyApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/journal',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => HomeScreen(child: child),
      routes: [
        GoRoute(
          path: '/journal',
          builder: (context, state) => const JournalListScreen(),
        ),
         GoRoute(
          path: '/journal/new',
          builder: (context, state) => const JournalEditorScreen(),
        ),
        GoRoute(
          path: '/journal/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'];
            return JournalEditorScreen(journalId: id);
          },
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/alarms',
          builder: (context, state) => const AlarmScreen(),
        ),
        GoRoute(
          path: '/lists',
          builder: (context, state) => const ListScreen(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    // Basic Auth Guard
    // In a real app, listen to auth state changes properly
    // This is a simplified check
    return null;
  },
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStream = ref.watch(authServiceProvider).authStateChanges;

    return StreamBuilder<String?>(
      stream: authStream,
      builder: (context, snapshot) {
        // If not logged in, show login screen, else use router
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.active) {
             return MaterialApp(
               home: const LoginScreen(),
               theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
             );
        }

        return MaterialApp.router(
          routerConfig: _router,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
          ),
        );
      },
    );
  }
}
