import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_auth_service.dart';

// Current user provider - now uses Firebase auth state
final currentUserProvider = StreamProvider<User?>((ref) async* {
  await for (final firebaseUser in FirebaseAuthService.authStateChanges) {
    if (firebaseUser != null) {
      // Get or create app user from Firebase user
      final appUser = await FirebaseAuthService.convertToAppUser(firebaseUser);
      yield appUser;
    } else {
      yield null;
    }
  }
});

// Authentication state provider
final authStateProvider = Provider<AsyncValue<AuthState>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  
  return userAsync.when(
    data: (user) => AsyncValue.data(
      user != null ? AuthState.authenticated : AuthState.unauthenticated
    ),
    loading: () => const AsyncValue.data(AuthState.loading),
    error: (error, stack) => const AsyncValue.data(AuthState.unauthenticated),
  );
});

// Simple user state provider for immediate access
final userStateProvider = StateProvider<User?>((ref) => null);

// Login provider
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref);
});

// Register provider
final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
  return RegisterNotifier(ref);
});

// Logout provider
final logoutProvider = StateNotifierProvider<LogoutNotifier, LogoutState>((ref) {
  return LogoutNotifier(ref);
});

// Profile provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});

enum AuthState {
  unauthenticated,
  authenticated,
  loading,
}

class LoginState {
  final bool isLoading;
  final String? error;
  final bool success;

  LoginState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      success: success ?? this.success,
    );
  }
}

class RegisterState {
  final bool isLoading;
  final String? error;
  final bool success;

  RegisterState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    bool clearError = false,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      success: success ?? this.success,
    );
  }
}

class ProfileState {
  final bool isLoading;
  final String? error;
  final bool success;

  ProfileState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    bool clearError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      success: success ?? this.success,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  final Ref ref;

  LoginNotifier(this.ref) : super(LoginState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    
    try {
      final user = await FirebaseAuthService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      
      if (user != null) {
        // Update simple state provider
        ref.read(userStateProvider.notifier).state = user;
        state = state.copyWith(isLoading: false, success: true, error: null);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Login failed. Please check your credentials.',
          success: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        success: false,
      );
    }
  }

  Future<void> loginWithBiometrics() async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    
    try {
      final success = await AuthService.authenticateWithBiometrics();
      if (success) {
        state = state.copyWith(isLoading: false, success: true, error: null);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Biometric authentication failed',
          success: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Biometric authentication failed. Please try again.',
        success: false,
      );
    }
  }
  
  void reset() {
    state = LoginState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  final Ref ref;

  RegisterNotifier(this.ref) : super(RegisterState());

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    
    try {
      final user = await FirebaseAuthService.registerWithEmailPassword(
        name: name,
        email: email,
        password: password,
      );
      
      if (user != null) {
        // Registration successful - user is already signed out in the service
        state = state.copyWith(isLoading: false, success: true, error: null);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Registration failed. Please try again.',
          success: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        success: false,
      );
    }
  }
  
  void reset() {
    state = RegisterState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref ref;

  ProfileNotifier(this.ref) : super(ProfileState());

  Future<void> updateProfile({
    String? name,
    String? avatarPath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await AuthService.updateProfile(
        name: name,
        avatarPath: avatarPath,
      );
      if (success) {
        // Update user state
        final currentUser = ref.read(userStateProvider);
        if (currentUser != null) {
          ref.read(userStateProvider.notifier).state = currentUser.copyWith(
            name: name ?? currentUser.name,
            avatarPath: avatarPath ?? currentUser.avatarPath,
          );
        }
        state = state.copyWith(isLoading: false, success: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Profile update failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Profile update failed. Please try again.',
      );
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await AuthService.changePassword(oldPassword, newPassword);
      if (success) {
        state = state.copyWith(isLoading: false, success: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Password change failed. Check your current password.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Password change failed. Please try again.',
      );
    }
  }

  Future<void> updateNotificationSettings({
    bool? enabled,
    int? timeBeforeDue,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await AuthService.updateNotificationSettings(
        enabled: enabled,
        timeBeforeDue: timeBeforeDue,
      );
      if (success) {
        final currentUser = ref.read(userStateProvider);
        if (currentUser != null) {
          ref.read(userStateProvider.notifier).state = currentUser.copyWith(
            notificationsEnabled: enabled ?? currentUser.notificationsEnabled,
            notificationTime: timeBeforeDue ?? currentUser.notificationTime,
          );
        }
        state = state.copyWith(isLoading: false, success: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Notification settings update failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Notification settings update failed. Please try again.',
      );
    }
  }

  Future<void> enableBiometricAuth() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await AuthService.enableBiometricAuth();
      if (success) {
        final currentUser = ref.read(userStateProvider);
        if (currentUser != null) {
          ref.read(userStateProvider.notifier).state = currentUser.copyWith(
            biometricEnabled: true,
          );
        }
        state = state.copyWith(isLoading: false, success: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Biometric authentication setup failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Biometric authentication setup failed. Please try again.',
      );
    }
  }

  Future<void> disableBiometricAuth() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await AuthService.disableBiometricAuth();
      if (success) {
        final currentUser = ref.read(userStateProvider);
        if (currentUser != null) {
          ref.read(userStateProvider.notifier).state = currentUser.copyWith(
            biometricEnabled: false,
          );
        }
        state = state.copyWith(isLoading: false, success: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Biometric authentication disable failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Biometric authentication disable failed. Please try again.',
      );
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await AuthService.deleteAccount();
      if (success) {
        await FirebaseAuthService.signOut();
        ref.read(userStateProvider.notifier).state = null;
        state = state.copyWith(isLoading: false, success: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Account deletion failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Account deletion failed. Please try again.',
      );
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuthService.signOut();
      ref.read(userStateProvider.notifier).state = null;
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

class LogoutState {
  final bool isLoading;
  final bool success;
  final String? error;

  LogoutState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });

  LogoutState copyWith({
    bool? isLoading,
    bool? success,
    String? error,
    bool clearError = false,
  }) {
    return LogoutState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LogoutNotifier extends StateNotifier<LogoutState> {
  final Ref ref;

  LogoutNotifier(this.ref) : super(LogoutState());

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await FirebaseAuthService.signOut();
      ref.read(userStateProvider.notifier).state = null;
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Logout failed: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}