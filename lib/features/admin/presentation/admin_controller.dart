import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_profile.dart';
import '../repository/admin_repository.dart';

// State for the list of parents
final adminParentsProvider = FutureProvider<List<UserProfile>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.fetchAllParents();
});

// Provider to fetch kids for a specific parent (Family)
final adminKidsProvider = FutureProvider.family<List<UserProfile>, String>((ref, parentId) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.fetchKidsForParent(parentId);
});

// AdminController to handle actions. 
// Using AsyncNotifier<void> to represent action state (loading/success/error)
class AdminController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initial state needed really, just null
    return null;
  }

  Future<void> addMoney(String userId, double amount) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(adminRepositoryProvider);
      await repository.addMoney(userId, amount);
      
      // Refresh user lists
      ref.invalidate(adminParentsProvider);
      // We can iterate invalidation if needed, or just let UI refresh pulls handle it
    });
  }
}

final adminControllerProvider = AsyncNotifierProvider<AdminController, void>(() {
  return AdminController();
});
