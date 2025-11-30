import 'dart:convert';

import 'package:swarn_abhushan/utils/api.dart';

class ItemService {
  late Api _api;
  ItemService() {
    _api = Api();
  }

  Future<dynamic> createNew(Map<String, dynamic> req) async {
    try {
      final res = await _api.post('items', body: json.encode(req));
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchItems(String? keyword, int page, int limit) async {
    try {
      final res = await _api.post(
        'items/search',
        body: json.encode({'keyword': keyword, 'page': page, 'limit': limit}),
      );
      return res;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<dynamic> updateItem(String uuid, Map<String, Object?> reqbody) async {
    try {
      final res = await _api.put('items/$uuid', body: json.encode(reqbody));
      return res;
    } catch (e) {
      rethrow;
    }
  }

  
  Future<dynamic> getItem(String uuid) async {
    try {
      final res = await _api.get('items/$uuid');
      return res;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<dynamic> deleteItem(String uuid) async {
    try {
      final res = await _api.delete('items/$uuid');
      return res;
    } catch (e) {
      rethrow;
    }
  }
}