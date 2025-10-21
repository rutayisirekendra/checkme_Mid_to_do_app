import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/main/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await DatabaseService.init();
  
  // Initialize notifications
  await NotificationService.init();
  
  runApp(const ProviderScope(child: CheckMeApp()));
}

class CheckMeApp extends ConsumerWidget {
  const CheckMeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeProvider);
    
    // Initialize theme when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeProvider.notifier).initializeTheme();
    });
    
    return MaterialApp(
      title: 'CheckMe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: authState == AuthState.authenticated 
          ? const MainScreen()
          : const AuthScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
