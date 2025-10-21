import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

// Current user provider
final currentUserProvider = StateProvider<User?>((ref) => AuthService.currentUser);

// Authentication state provider
final authStateProvider = StateProvider<AuthState>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null ? AuthState.authenticated : AuthState.unauthenticated;
});

// Login provider
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref);
});

// Register provider
final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
  return RegisterNotifier(ref);
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
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
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
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
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
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  final Ref ref;

  LoginNotifier(this.ref) : super(LoginState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await AuthService.login(email, password);
      if (success) {
        ref.read(currentUserProvider.notifier).state = AuthService.currentUser;
        ref.read(authStateProvider.notifier).state = AuthState.authenticated;
        state = state.copyWith(isLoading: false, success: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid email or password',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed. Please try again.',
      );
    }
  }

  Future<void> loginWithBiometrics() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await AuthService.authenticateWithBiometrics();
      if (success) {
        ref.read(currentUserProvider.notifier).state = AuthService.currentUser;
        ref.read(authStateProvider.notifier).state = AuthState.authenticated;
        state = state.copyWith(isLoading: false, success: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Biometric authentication failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Biometric authentication failed. Please try again.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  final Ref ref;

  RegisterNotifier(this.ref) : super(RegisterState());

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await AuthService.register(name, email, password);
      if (success) {
        ref.read(currentUserProvider.notifier).state = AuthService.currentUser;
        ref.read(authStateProvider.notifier).state = AuthState.authenticated;
        state = state.copyWith(isLoading: false, success: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Registration failed. User may already exist.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed. Please try again.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
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
        ref.read(currentUserProvider.notifier).state = AuthService.currentUser;
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

  Future<void> updateTheme(bool isDarkMode) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await AuthService.updateTheme(isDarkMode);
      if (success) {
        ref.read(currentUserProvider.notifier).state = AuthService.currentUser;
        state = state.copyWith(isLoading: false, success: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Theme update failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Theme update failed. Please try again.',
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
        ref.read(currentUserProvider.notifier).state = AuthService.currentUser;
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
        ref.read(currentUserProvider.notifier).state = AuthService.currentUser;
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
        ref.read(currentUserProvider.notifier).state = AuthService.currentUser;
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

  Future<void> logout() async {
    await AuthService.logout();
    ref.read(currentUserProvider.notifier).state = null;
    ref.read(authStateProvider.notifier).state = AuthState.unauthenticated;
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await AuthService.deleteAccount();
      if (success) {
        ref.read(currentUserProvider.notifier).state = null;
        ref.read(authStateProvider.notifier).state = AuthState.unauthenticated;
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

  void clearError() {
    state = state.copyWith(error: null);
  }
}


