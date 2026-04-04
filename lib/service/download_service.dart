import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'secure_storage_service.dart';

typedef DownloadProgressCallback = void Function(double progress, String status);

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final SecureStorageService _storage = SecureStorageService();
  bool _isDownloadCancelled = false;

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // For Android 13+, app-private storage doesn't require permissions
      // For Android 6-12, request storage permission
      final status = await Permission.storage.request();

      log("permission status: $status");
      
      if (status.isPermanentlyDenied) {
        log("permission permanently denied. Opening app settings...");
        await openAppSettings();
        return false;
      }
      
      // Return true for granted or for Android 13+ which auto-grants for app-private dirs
      return status.isGranted || status.isDenied;
    }
    return true;
  }

  Future<String?> downloadModel({
    required String modelId,
    required String filename,
    required DownloadProgressCallback onProgress,
  }) async {
    try {
      // final status = await Permission.storage.status;
      // log("again permission status: $status");
      // Get permissions
      if (!await requestPermissions()) {
        onProgress(0, 'Storage permission denied');
        return null;
      }

      // Get app directory
      final appDir = await getApplicationDocumentsDirectory();
      final actualModelsDir = Directory('${appDir.path}/models');

      if (!await actualModelsDir.exists()) {
        await actualModelsDir.create(recursive: true);
      }
      
      if (!await actualModelsDir.exists()) {
        await actualModelsDir.create(recursive: true);
      }

      // Save to native expected path for direct compatibility
      final filePath = '${actualModelsDir.path}/$filename';
      log('DEBUG: DownloadService - Model will be saved to native path: $filePath');

      // Check if already downloaded
      if (File(filePath).existsSync()) {
        final existingFile = File(filePath);
        final stat = await existingFile.stat();
        log('DEBUG: Existing model file size: ${stat.size} bytes');
        
        if (stat.size > 0) {
          onProgress(1.0, 'Already downloaded');
          log('DEBUG: DownloadService - Already downloaded, returning path: $filePath');
          return filePath;
        } else {
          log('DEBUG: Existing file is empty, re-downloading...');
          await existingFile.delete();
        }
      }

      // Reset cancellation flag
      _isDownloadCancelled = false;

      onProgress(0, 'Starting download...');

      // Get download URL
      final downloadUrl = 'https://huggingface.co/$modelId/resolve/main/$filename';

      // Get token for authenticated download
      final token = await _storage.getAccessToken();
      final Map<String, String> headers = token != null
          ? {'Authorization': 'Bearer $token'}
          : {};

      // Start download
      final request = http.Request('GET', Uri.parse(downloadUrl));
      request.headers.addAll(headers);
      final response = await request.send();

      if (response.statusCode != 200) {
        log('Download failed: ${response.statusCode}');
        throw Exception('Download failed: ${response.statusCode}');
      }

      // Get content length for progress tracking
      final contentLength = response.contentLength ?? 0;
      var bytesDownloaded = 0;

      final file = File(filePath);
      final sink = file.openWrite();

      await for (var chunk in response.stream) {
        // Check if download was cancelled
        if (_isDownloadCancelled) {
          await sink.close();
          await _cleanupIncompleteDownload(filePath);
          onProgress(0, 'Download cancelled');
          return null;
        }

        sink.add(chunk);
        bytesDownloaded += chunk.length;

        if (contentLength > 0) {
          final progress = bytesDownloaded / contentLength;
          onProgress(progress, 'Downloading... ${(progress * 100).toStringAsFixed(1)}%');
        }
      }

      await sink.flush();
      await sink.close();

      // Check if download was cancelled during completion
      if (_isDownloadCancelled) {
        await _cleanupIncompleteDownload(filePath);
        onProgress(0, 'Download cancelled');
        return null;
      }

      // Verify file exists
      if (await file.exists()) {
        // Save to downloaded models list
        final downloaded = await _storage.getDownloadedModels();
        if (!downloaded.contains(filePath)) {
          downloaded.add(filePath);
          await _storage.saveDownloadedModels(downloaded);
        }

        onProgress(1.0, 'Download complete!');
        return filePath;
      }

      return null;

    } catch (e) {
      onProgress(0, 'Error: $e');
      return null;
    }
  }

  // Cancel current download
  void cancelDownload() {
    _isDownloadCancelled = true;
    log('DEBUG: Download cancelled by user');
  }

  // Clean up incomplete download
  Future<void> _cleanupIncompleteDownload(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        log('DEBUG: Cleaned up incomplete download: $filePath');
      }
    } catch (e) {
      log('Error cleaning up incomplete download: $e');
    }
  }

  Future<List<File>> getDownloadedModelFiles() async {
    final paths = await _storage.getDownloadedModels();
    return paths.map((path) => File(path)).where((f) => f.existsSync()).toList();
  }

  Future<bool> deleteModel(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();

        // Remove from list
        final downloaded = await _storage.getDownloadedModels();
        downloaded.remove(path);
        await _storage.saveDownloadedModels(downloaded);

        return true;
      }
      return false;
    } catch (e) {
      log('Delete error: $e');
      return false;
    }
  }
}