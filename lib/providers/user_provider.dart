import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:swarn_abhushan/models/user.dart';
import 'package:swarn_abhushan/services/loader_service.dart';
import 'package:swarn_abhushan/services/user_service.dart';

final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});

class UserNotifier extends StateNotifier<UserState> {
  final Ref _ref;
  late final UserService _service;

  UserNotifier(this._ref) : super(const UserState()){
    _service = _ref.read(userServiceProvider);
  }
  LoaderService get _loader => _ref.read(loaderServiceProvider);

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


  Future<User> addUser(User user) async {
    final exists = state.users.any((u) => u.mobile == user.mobile);
    if (exists) {
      throw 'User with phone ${user.mobile} already exists.';
    }
    state = state.copyWith(isAdding: true);
    _loader.show();
    try {
      final res = await _service.createUser(user.toMap());
      state = state.copyWith(
        users: [res, ...state.users],
        total: state.total + 1,
      );
      return res;
    } finally {
      state = state.copyWith(isAdding: false);
      _loader.hide();
    }
  }

  Future<void> updateUser(User updatedUser) async {
    state = state.copyWith(isUpdating: true);
    _loader.show();
    try {
      final res = await _service.updateUser(updatedUser.uuid!, updatedUser.toMap());
      final updatedList = state.users.map((t) => t.uuid == res.uuid ? res : t).toList();
      state = state.copyWith(users: updatedList);
    } finally {
      state = state.copyWith(isUpdating: false);
      _loader.hide();
    }
  }

  Future<void> deleteUser(String id) async {
    _loader.show();
    try {
      await _service.deleteUser(id);
      final updatedList = state.users.where((u) => u.uuid != id).toList();
      state = state.copyWith(users: updatedList);
    } finally {
      _loader.hide();
    }
  }

  Future<void> searchUsers(String? keyword, int page, int limit) async {
    state = state.copyWith(isLoading: true);
    _loader.show();
    try {
      final response = await _service.fetchUsers(keyword, page, limit);
      final List data = response['data'] ?? [];
      final users = data.map((e) => User.fromMap(e)).toList();

      await loadUsers(
        users: users,
        total: response['total'] ?? users.length,
        page: response['page'] ?? 1,
        limit: response['limit'] ?? 50,
        isLastPage: response['isLastPage'] ?? false,
        isPreviousPage: response['isPreviousPage'] ?? false,
        append: page > 1,
      );
    } finally {
      state = state.copyWith(isLoading: false);
      _loader.hide();
    }
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
