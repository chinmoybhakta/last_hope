import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:last_hope_ai/data/model/user_model.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      // ignore: deprecated_member_use
      encryptedSharedPreferences: true,
    ),
  );

  // Save tokens after OAuth [citation:2][citation:5]
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    int? expiresIn,
  }) async {
    await _storage.write(key: 'hf_access_token', value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: 'hf_refresh_token', value: refreshToken);
    }
    if (expiresIn != null) {
      final expiryTime = DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);
      await _storage.write(key: 'hf_token_expiry', value: expiryTime.toString());
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'hf_access_token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'hf_refresh_token');
  }

  Future<bool> isTokenValid() async {
    final expiryStr = await _storage.read(key: 'hf_token_expiry');
    if (expiryStr == null) return false;

    final expiry = int.tryParse(expiryStr) ?? 0;
    return DateTime.now().millisecondsSinceEpoch < expiry;
  }

  // Save user info
  Future<void> saveUserInfo(User user) async {
    await _storage.write(key: 'hf_user_info', value: jsonEncode(user.toJson()));
  }

  Future<User?> getUserInfo() async {
    final userStr = await _storage.read(key: 'hf_user_info');
    if (userStr == null) return null;
    return User.fromJson(jsonDecode(userStr));
  }

  // Save downloaded models list
  Future<void> saveDownloadedModels(List<String> modelPaths) async {
    await _storage.write(key: 'downloaded_models', value: jsonEncode(modelPaths));
  }

  Future<List<String>> getDownloadedModels() async {
    final modelsStr = await _storage.read(key: 'downloaded_models');
    if (modelsStr == null) return [];
    return List<String>.from(jsonDecode(modelsStr));
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}