import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app_config.dart';
import 'session_store.dart';

class ApiException implements Exception {
  ApiException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  Uri _uri(String path) {
    final base = kApiBase.endsWith('/') ? kApiBase.substring(0, kApiBase.length - 1) : kApiBase;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  Future<Map<String, dynamic>> _handle(http.Response r) async {
    Map<String, dynamic>? body;
    try {
      body = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>?;
    } catch (_) {
      body = null;
    }
    if (r.statusCode >= 200 && r.statusCode < 300) {
      if (body == null) {
        return {'success': true, 'data': null};
      }
      if (body['success'] == true) {
        return body;
      }
      throw ApiException(body['message']?.toString() ?? 'Request failed', r.statusCode);
    }
    final msg = body?['message']?.toString() ?? 'HTTP ${r.statusCode}';
    throw ApiException(msg, r.statusCode);
  }

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final t = await SessionStore.getToken();
      if (t != null && t.isNotEmpty) {
        h['Authorization'] = 'Bearer $t';
      }
    }
    return h;
  }

  Future<Map<String, dynamic>> get(String path, {bool auth = true}) async {
    final r = await http.get(_uri(path), headers: await _headers(auth: auth));
    return _handle(r);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final r = await http.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(r);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final r = await http.put(
      _uri(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(r);
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final r = await http.patch(
      _uri(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(r);
  }

  Future<Map<String, dynamic>> delete(String path, {bool auth = true}) async {
    final r = await http.delete(_uri(path), headers: await _headers(auth: auth));
    return _handle(r);
  }
}
