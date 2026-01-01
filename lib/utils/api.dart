import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:swarn_abhushan/utils/toastr.dart';

class Api {
  final Duration defaultTimeout = const Duration(seconds: 100);
  final Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };
  // final String baseUrl = 'https://jewelry-backend-xu5k.onrender.com/api/';
  final String baseUrl = 'https://quietistic-uniterative-heide.ngrok-free.dev/api/';
  final String devUrl = 'http://10.252.52.118:4000/api/';

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    dynamic body,
  }) async {
    Uri uri = Uri.parse(baseUrl + path);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: {...uri.queryParameters, ...queryParameters});
    }

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: {...defaultHeaders, ...?headers})
              .timeout(defaultTimeout);
          break;
        case 'POST':
          response = await http
              .post(uri,
                  headers: {...defaultHeaders, ...?headers},
                  body: body is String ? body : jsonEncode(body))
              .timeout(defaultTimeout);
          break;
        case 'PUT':
          response = await http
              .put(uri,
                  headers: {...defaultHeaders, ...?headers},
                  body: body is String ? body : jsonEncode(body))
              .timeout(defaultTimeout);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: {...defaultHeaders, ...?headers} )
              .timeout(defaultTimeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
      final decodedBody = _decodeResponse(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decodedBody;
      } else {
        final msg = decodedBody['message'];
        String errorMsg;
        if(msg is List){
          errorMsg = msg.join('\t');
        } else if (msg is Map) {
          errorMsg = msg.values.join('\n');
        } else {
          errorMsg = msg?.toString() ?? 'Something went wrong (${response.statusCode})';
        }
        Toastr.show(errorMsg, success: false);
        throw errorMsg;
      }
    } on TimeoutException catch (e) {
      final msg = 'Request timed out. Please try again. $e';
      Toastr.show(msg, success: false);
      throw Exception(msg);
    } on Exception catch (e) {
      Toastr.show(e.toString(), success: false);
      throw Exception(e.toString());
    }
  }

  dynamic _decodeResponse(String body) {
    if (body.isEmpty) return {};
    try {
      final decoded = json.decode(body);
      return decoded is Map<String, dynamic> || decoded is List ? decoded : {'data': decoded};
    } catch (_) {
      return {'data': body};
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return _send('GET', path, queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? queryParameters,
    dynamic body,
  }) {
    return _send('POST', path, queryParameters: queryParameters, body: body);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, String>? queryParameters,
    dynamic body,
  }) {
    return _send('PUT', path, queryParameters: queryParameters, body: body);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? queryParameters,
    dynamic body,
  }) {
    return _send('DELETE', path, queryParameters: queryParameters, body: body);
  }

  Future<Uint8List> getPdf(String path) async {
    final uri = Uri.parse(baseUrl + path);
    try {
      final response = await http.get(uri, headers: { 'Accept': 'application/pdf' }).timeout(defaultTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }

      throw Exception("Failed to load PDF: ${response.statusCode}");
    } on TimeoutException catch (e) {
      final msg = 'Request timed out. Please try again. $e';
      Toastr.show(msg, success: false);
      throw Exception(msg);
    } on Exception catch (e) {
      Toastr.show(e.toString(), success: false);
      throw Exception(e.toString());
    }
  }

}

final apiProvider = Provider<Api>((ref) => Api());
