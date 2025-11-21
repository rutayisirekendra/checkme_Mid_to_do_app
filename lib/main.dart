import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/main/main_screen.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Hive database
  await DatabaseService.init();
  
  // Initialize notifications
  await NotificationService.init();
  
  runApp(const ProviderScope(child: CheckMeApp()));
}

class CheckMeApp extends ConsumerStatefulWidget {
  const CheckMeApp({super.key});

  @override
  ConsumerState<CheckMeApp> createState() => _CheckMeAppState();
}

class _CheckMeAppState extends ConsumerState<CheckMeApp> {
  bool _showSplash = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash screen for 5 seconds
    await Future.delayed(const Duration(seconds: 5));
    
    if (mounted) {
      setState(() {
        _showSplash = false;
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    
    // Initialize theme when app starts
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(themeProvider.notifier).initializeTheme();
      });
    }
    
    return MaterialApp(
      title: 'CheckMe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: _showSplash 
          ? const SplashScreen()
          : const AuthGate(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}

// Auth gate to handle authentication state
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);
    
    return authStateAsync.when(
      data: (authState) {
        switch (authState) {
          case AuthState.loading:
            return const SplashScreen();
          case AuthState.authenticated:
            // Update user state provider
            final userAsync = ref.watch(currentUserProvider);
            userAsync.whenData((user) {
              if (user != null) {
                Future.microtask(() {
                  ref.read(userStateProvider.notifier).state = user;
                });
              }
            });
            return const MainScreen();
          case AuthState.unauthenticated:
            return const AuthScreen();
        }
      },
      loading: () => const SplashScreen(),
      error: (_, __) => const AuthScreen(),
    );
  }
}
