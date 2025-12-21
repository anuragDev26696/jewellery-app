import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/models/user.dart';
import 'package:swarn_abhushan/utils/api.dart';
import 'package:swarn_abhushan/utils/toastr.dart';

class UserService {
  final Ref _ref;
  String? _prevSearch;

  UserService(this._ref);

  Api get _api => _ref.read(apiProvider);

  Future<User> createUser(Map<String, dynamic> req) async {
    try {
      final res = await _api.post(
        'users',
        body: req,
      );

      final user = User.fromMap(res);
      Toastr.show('User created successfully');
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getUserById(String id) async {
    try {
      final response = await _api.get('users/$id');
      final user = User.fromJson(response['data']);
      return user;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<User> updateUser(String uuid, Map<String, dynamic> req) async {
    try {
      final response = await _api.put(
        'users/$uuid',
        body: req,
      );
      final updateUser = User.fromMap(response);
      Toastr.show('User updated successfully');
      return updateUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchUsers(String? keyword, int page, int limit) async {
    try {
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
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<dynamic> deleteUser(String id) async {
    try {
      await _api.delete('users/$id');
      Toastr.show('User deleted successfully');
      return id;
    } catch (e) {
      rethrow;
    }
  }
}
