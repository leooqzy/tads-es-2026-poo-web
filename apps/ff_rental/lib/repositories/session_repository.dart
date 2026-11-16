import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/api_constants.dart';
import '../models/user.dart';

class SessionRepository {
  SessionRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _userKey = 'ff_rental_user';

  Future<void> saveToken(String token) async {
    await _storage.write(key: ApiConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: ApiConstants.tokenKey);
  }

  Future<void> saveUser(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final userData = await _storage.read(key: _userKey);

    if (userData == null || userData.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(userData);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return User.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearToken() async {
    await _storage.delete(key: ApiConstants.tokenKey);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: ApiConstants.tokenKey);
    await _storage.delete(key: _userKey);
  }
}
