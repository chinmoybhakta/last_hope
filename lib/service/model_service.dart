import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ModelService {
  static final ModelService _instance = ModelService._internal();
  factory ModelService() => _instance;
  ModelService._internal();

  // Get all available models
  Future<List<ModelInfo>> getAvailableModels() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDir.path}/models');
      if (!await dir.exists()) {
        return [];
      }

      final files = await dir.list().toList();
      final ggufFiles = files
          .where((f) => f is File && f.path.endsWith('.gguf'))
          .cast<File>()
          .toList();

      return ggufFiles.map((file) => ModelInfo(
        name: path.basenameWithoutExtension(file.path),
        path: file.path,
        size: file.lengthSync(),
        lastModified: file.lastModifiedSync(),
      )).toList();
    } catch (e) {
      log('Error getting models: $e');
      return [];
    }
  }

  // Delete a model
  Future<bool> deleteModel(String modelPath) async {
    try {
      final file = File(modelPath);
      if (await file.exists()) {
        await file.delete();
        log('Model deleted: $modelPath');
        return true;
      }
      return false;
    } catch (e) {
      log('Error deleting model: $e');
      return false;
    }
  }

  // Get model size in human readable format
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class ModelInfo {
  final String name;
  final String path;
  final int size;
  final DateTime lastModified;

  ModelInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.lastModified,
  });

  String get formattedSize => ModelService().formatFileSize(size);
  String get formattedDate => '${lastModified.day}-${lastModified.month}-${lastModified.year}';
}
