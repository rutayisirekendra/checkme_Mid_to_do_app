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
      final user = await FirebaseAuthService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      
      if (user != null) {
        // Update simple state provider
        ref.read(userStateProvider.notifier).state = user;
        state = state.copyWith(isLoading: false, success: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Login failed. Please check your credentials.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loginWithBiometrics() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await AuthService.authenticateWithBiometrics();
      if (success) {
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
      final user = await FirebaseAuthService.registerWithEmailPassword(
        name: name,
        email: email,
        password: password,
      );
      
      if (user != null) {
        // Update simple state provider
        ref.read(userStateProvider.notifier).state = user;
        state = state.copyWith(isLoading: false, success: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Registration failed. Please try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
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

  Future<void> logout() async {
    try {
      await FirebaseAuthService.signOut();
      ref.read(userStateProvider.notifier).state = null;
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
