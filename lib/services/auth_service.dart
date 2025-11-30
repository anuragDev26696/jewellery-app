import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/services/loader_service.dart';
import 'package:swarn_abhushan/services/local_storage.dart';
import 'package:swarn_abhushan/utils/api.dart';
import 'package:swarn_abhushan/utils/toastr.dart';

class AuthService {
  final WidgetRef _ref;
  late Api api;
  late LoaderService _loaderService;
  
  AuthService(this._ref) {
    api = Api();
    _loaderService = _ref.read(loaderServiceProvider);
  }

  Future<dynamic> login(Map<String, Object?> req) async {
    try {
      _loaderService.show();
      final res = await api.post( 'auth/login', body: json.encode(req));
      if (res['accessToken'] != null) {
        await LocalStorage.saveToken(res['accessToken']);
        return res['user']!;
      } else {
        Toastr.show('Invlaid login response: no token found', success: false);
        return null;
      }
    } catch (e) {
      rethrow;
    } finally {
      _loaderService.hide();
    }
  }

  Future<void> logout() async {
    await LocalStorage.clearToken();
  }
  Future<bool> isLoggedIn() async {
    final token = await LocalStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}