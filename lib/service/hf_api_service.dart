import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:last_hope_ai/data/model/model_info.dart';
import '../utils/constants.dart';
import 'auth_service.dart';
import 'secure_storage_service.dart';

class HFAPIService {
  static final HFAPIService _instance = HFAPIService._internal();
  factory HFAPIService() => _instance;
  HFAPIService._internal();

  final AuthService _auth = AuthService();
  final SecureStorageService _storage = SecureStorageService();

  // ONLY these specific models with their GGUF repositories
  // ignore: constant_identifier_names
  static const List<Map<String, String>> _SURVIVAL_MODELS = [
    {
      'name': 'TinyLlama 1.1B (Q4_K_M)',
      'repo': 'TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF',
      'filename': 'tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf',
      'size': '~600MB',
      'description': 'Fast, efficient, good for basic survival info',
    },
    {
      'name': 'Phi-2 2.7B (Q4_K_M)',
      'repo': 'TheBloke/phi-2-GGUF',
      'filename': 'phi-2.Q4_K_M.gguf',
      'size': '~900MB',
      'description': 'Excellent reasoning, better for complex survival scenarios',
    },
    {
      'name': 'Llama 3.2 1B Instruct (Q4_K_M)',
      'repo': 'hugging-quants/Llama-3.2-1B-Instruct-Q4_K_M-GGUF',
      'filename': 'llama-3.2-1b-instruct-q4_k_m.gguf',
      'size': '~800MB',
      'description': 'Very fast, better instruction following than TinyLlama, ideal for chat assistants',
    },
    {
      'name': 'Qwen 2.5 1.5B (Q4_K_M)',
      'repo': 'Qwen/Qwen2.5-1.5B-Instruct-GGUF',
      'filename': 'qwen2.5-1.5b-instruct-q4_k_m.gguf',
      'size': '~900MB',
      'description': 'Excellent reasoning and structured answers, great for survival scenarios',
    },
  ];

  // Get authenticated headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get only the two survival models we need
  Future<List<HFModelInfo>> getSurvivalModels() async {
    try {
      final headers = await _getHeaders();

      if (!await _auth.isLoggedIn()) {
        log('Error: Not authenticated');
        throw Exception('Not authenticated');
      }

      List<HFModelInfo> survivalModels = [];

      // Fetch each model individually
      for (final modelInfo in _SURVIVAL_MODELS) {
        try {
          final repoId = modelInfo['repo']!;
          final filename = modelInfo['filename']!;

          log('📦 Fetching survival model: $repoId');

          final modelUrl = '$hfApiBase/models/$repoId';
          final response = await http.get(
            Uri.parse(modelUrl),
            headers: headers,
          );

          if (response.statusCode == 200) {
            final modelJson = jsonDecode(response.body);
            final model = HFModelInfo.fromJson(modelJson);

            // Add custom fields to the model
            model.customData = {
              'recommended_file': filename,
              'display_name': modelInfo['name'],
              'size': modelInfo['size'],
              'description': modelInfo['description'],
            };

            // Set files to just the one we want
            model.files = [filename];

            survivalModels.add(model);
            log('✅ Added survival model: ${modelInfo['name']}');
          } else if (response.statusCode == 401 || response.statusCode == 403) {
            log('⚠️ Access denied for $repoId - may require login');
          } else {
            log('❌ Failed to fetch $repoId: ${response.statusCode}');
          }
        } catch (e) {
          log('❌ Error fetching model: $e');
          continue;
        }

        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 300));
      }

      log('✅ Found ${survivalModels.length} survival models');
      return survivalModels;

    } catch (e) {
      log('❌ Error getting survival models: $e');
      return [];
    }
  }

  /// Get download URL for the specific model file
  String getModelDownloadUrl(String repoId, String filename) {
    return 'https://huggingface.co/$repoId/resolve/main/$filename';
  }

  /// Get the recommended file for a model
  String? getRecommendedFile(HFModelInfo model) {
    return model.customData?['recommended_file'];
  }

  /// Get display name for a model
  String getDisplayName(HFModelInfo model) {
    return model.customData?['display_name'] ?? model.displayName;
  }

  /// Get model size description
  String getModelSize(HFModelInfo model) {
    return model.customData?['size'] ?? 'Unknown';
  }

  /// Get model description
  String getModelDescription(HFModelInfo model) {
    return model.customData?['description'] ?? model.description;
  }

  // Keep these for backward compatibility, but they'll just call getSurvivalModels
  Future<List<HFModelInfo>> searchGGUFModels({String query = ''}) async {
    return getSurvivalModels();
  }

  Future<List<HFModelInfo>> getPocketPalModels() async {
    return getSurvivalModels();
  }

  Future<List<HFModelInfo>> searchPocketPalModels({String query = ''}) async {
    return getSurvivalModels();
  }
}