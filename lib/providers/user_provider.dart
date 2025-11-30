import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:swarn_abhushan/models/user.dart';
import 'package:swarn_abhushan/services/user_service.dart';

final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserState> {

  UserNotifier() : super(const UserState());

  Future<void> loadUsers({
    required List<User> users,
    required int total,
    required int page,
    required int limit,
    required bool isLastPage,
    required bool isPreviousPage,
    bool append = false,
  }) async {
    final newUsers = append ? [...state.users, ...users] : users;
    state = state.copyWith(
      users: newUsers,
      total: total,
      page: page,
      limit: limit,
      isLastPage: isLastPage,
      isPreviousPage: isPreviousPage
    );
  }


  Future<void> addUser(User user) async {
    final exists = state.users.any((u) => u.mobile == user.mobile);
    if (exists) {
      throw 'User with phone ${user.mobile} already exists.';
    }
    state = state.copyWith(users: [user, ...state.users]);
  }

  Future<void> updateUser(User updatedUser) async {
    final updatedList = state.users.map((t) => t.uuid == updatedUser.uuid ? updatedUser : t).toList();
    state = state.copyWith(users: updatedList);
  }

  Future<void> deleteUser(String id) async {
    final updatedList = state.users.where((u) => u.uuid != id).toList();
    state = state.copyWith(users: updatedList);
  }

  User? getUserById(String id) {
    return state.users.firstWhere((u) => u.uuid == id, orElse: () => User(
      uuid: '',
      name: '',
      mobile: '',
      email: '',
      address: '',
    ));
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref);
});
