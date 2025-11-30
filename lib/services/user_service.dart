import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/models/user.dart';
import 'package:swarn_abhushan/providers/user_provider.dart';
import 'package:swarn_abhushan/services/loader_service.dart';
import 'package:swarn_abhushan/utils/api.dart';
import 'package:swarn_abhushan/utils/toastr.dart';

class UserService {
  final Ref _ref;
  String? _prevSearch;

  UserService(this._ref);

  Api get _api => _ref.read(apiProvider);
  UserNotifier get _userNotifier => _ref.read(userNotifierProvider.notifier);
  LoaderService get _loader => _ref.read(loaderServiceProvider);

  Future<User> createUser({required String name, required String phone, String? email = '', String? address = ''}) async {
    try {
      _loader.show();
      final res = await _api.post(
        'users',
        body: {
          'name': name,
          'mobile': phone,
          if(email!.trim().isNotEmpty) 'email': email,
          if(address!.trim().isNotEmpty)'address': address,
        },
      );

      final user = User.fromMap(res);
      await _userNotifier.addUser(user);
      Toastr.show('User created successfully');
      return user;
    } catch (e) {
      rethrow;
    } finally {
      _loader.hide();
    }
  }

  Future<User> getUserById(String id) async {
    try {
      _loader.show();
      final response = await _api.get('users/$id');
      final user = User.fromJson(response['data']);
      return user;
    } catch (e) {
      rethrow;
    } finally {
      _loader.hide();
    }
  }
  
  Future<User> updateUser(String uuid, String? name, String? phone, String? email, String? address) async {
    try {
      _loader.show();
      final response = await _api.put(
        'users/$uuid',
        body: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
          if (address != null) 'address': address,
        },
      );
      final updateUser = User.fromMap(response);
      _userNotifier.updateUser(updateUser);
      Toastr.show('User updated successfully');
      return updateUser;
    } catch (e) {
      rethrow;
    } finally {
      _loader.hide();
    }
  }

  Future<List<User>> fetchUsers(String? keyword, int page, int limit) async {
    try {
      _loader.show();
      page = _prevSearch == keyword ? page : 0;
      _prevSearch = keyword;
      final response = await _api.post(
        'users/search',
        body: {
          if(keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword,
          'page': page,
          'limit': limit,
        }
      );
      final List data = response['data'] ?? [];
      final users = data.map((e) => User.fromMap(e)).toList();
      await _userNotifier.loadUsers(
        users: users,
        total: response['total'] ?? users.length,
        page: response['page'] ?? 1,
        limit: response['limit'] ?? limit,
        isLastPage: response['isLastPage'] ?? false,
        isPreviousPage: response['isPreviousPage'] ?? false,
        append: page > 1,
      );
      return users;
    } catch (e) {
      rethrow;
    } finally {
      _loader.hide();
    }
  }
  
  Future<void> deleteUser(String id) async {
    try {
      _loader.show();
      await _api.delete('users/$id');
      _userNotifier.deleteUser(id);
      Toastr.show('User deleted successfully');
    } catch (e) {
      rethrow;
    } finally {
      _loader.hide();
    }
  }
}
