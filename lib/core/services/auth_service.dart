import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import '../../data/models/user_model.dart';
import '../utils/constants.dart';
import 'secure_storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SecureStorageService _storage = SecureStorageService();

  // Generate PKCE code verifier and challenge [citation:3]
  String _generateCodeVerifier() {
    final random = List<int>.generate(64, (_) => DateTime.now().microsecond % 256);
    return base64Url.encode(random)
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');
  }

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes)
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');
  }

  // Step 1: Start OAuth flow [citation:1][citation:10]
  Future<bool> signInWithHuggingFace() async {
    try {
      // Generate PKCE values
      final codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(codeVerifier);

      // Store verifier for later use
      await _storage.saveTokens(
        accessToken: codeVerifier,  // Temporarily store verifier
      );

      // Build authorization URL [citation:10]
      final authUrl = Uri.parse(hfAuthUrl).replace(
        queryParameters: {
          'client_id': hfClientId,
          'redirect_uri': hfRedirectUri,
          'response_type': 'code',
          'scope': hfScopes.join(' '),
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
          'state': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      // Launch browser for authentication [citation:2][citation:5]
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'hf-flutter-auth',
      );

      // Extract code from callback URL
      final callbackUri = Uri.parse(result);
      final code = callbackUri.queryParameters['code'];

      if (code == null) {
        log('Error: No authorization code received');
        throw Exception('No authorization code received');
      }

      // Exchange code for token
      return await _exchangeCodeForToken(code, codeVerifier);

    } catch (e) {
      log('OAuth error: $e');
      return false;
    }
  }

  // Step 2: Exchange authorization code for tokens [citation:1][citation:10]
  Future<bool> _exchangeCodeForToken(String code, String codeVerifier) async {
    try {
      final tokenResponse = await http.post(
        Uri.parse(hfTokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': hfClientId,
          'client_secret': hfClientSecret,
          'code': code,
          'redirect_uri': hfRedirectUri,
          'grant_type': 'authorization_code',
          'code_verifier': codeVerifier,
        },
      );

      if (tokenResponse.statusCode != 200) {
        log('Token exchange failed: ${tokenResponse.body}');
        throw Exception('Token exchange failed: ${tokenResponse.body}');
      }

      final tokenData = jsonDecode(tokenResponse.body);

      // Save tokens
      await _storage.saveTokens(
        accessToken: tokenData['access_token'],
        refreshToken: tokenData['refresh_token'],
        expiresIn: tokenData['expires_in'],
      );

      // Get user info
      return await _getUserInfo(tokenData['access_token']);

    } catch (e) {
      log('Token exchange error: $e');
      return false;
    }
  }

  // Step 3: Get user information
  Future<bool> _getUserInfo(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(hfUserinfoUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final user = User.fromJson(userData);
        await _storage.saveUserInfo(user);
        return true;
      }
      return false;
    } catch (e) {
      log('User info error: $e');
      return false;
    }
  }

  // Refresh token when expired
  Future<bool> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse(hfTokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': hfClientId,
          'client_secret': hfClientSecret,
          'refresh_token': refreshToken,
          'grant_type': 'refresh_token',
        },
      );

      if (response.statusCode == 200) {
        final tokenData = jsonDecode(response.body);
        await _storage.saveTokens(
          accessToken: tokenData['access_token'],
          refreshToken: tokenData['refresh_token'],
          expiresIn: tokenData['expires_in'],
        );
        return true;
      }
      return false;
    } catch (e) {
      log('Token refresh error: $e');
      return false;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.getAccessToken();
    if (token == null) return false;

    final isValid = await _storage.isTokenValid();
    if (!isValid) {
      // Try to refresh
      return await refreshToken();
    }
    return true;
  }

  // Logout
  Future<void> logout() async {
    await _storage.clearAll();
  }
}