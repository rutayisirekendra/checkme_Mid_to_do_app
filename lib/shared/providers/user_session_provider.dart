import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import 'auth_provider.dart';

// Provider to get the current user's ID
final currentUserIdProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.maybeWhen(
    data: (user) => user?.id,
    orElse: () => null,
  );
});

// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId != null && userId.isNotEmpty;
});

// Provider to get the current user synchronously
final currentUserSyncProvider = Provider<User?>((ref) {
  return ref.watch(userStateProvider);
});
