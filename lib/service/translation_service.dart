import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:last_hope_translator/model/language_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class TranslationService {
  OnDeviceTranslator? _translator;
  final OnDeviceTranslatorModelManager _modelManager = OnDeviceTranslatorModelManager();
  final Connectivity _connectivity = Connectivity();
  
  // Progress tracking
  final Map<String, double> _downloadProgress = {};
  final Map<String, StreamController<double>> _progressControllers = {};
  final Map<String, Timer?> _progressTimers = {};
  
  bool get isTranslatorReady => _translator != null;
  
  TranslationService() {
    _init();
  }
  
  Future<void> _init() async {
    _connectivity.onConnectivityChanged.listen((result) {
      if (kDebugMode) {
        print('Connectivity changed: $result');
      }
    });
  }
  
  /// Get progress stream for a specific language
  Stream<double> getProgressStream(String languageCode) {
    if (!_progressControllers.containsKey(languageCode)) {
      _progressControllers[languageCode] = StreamController<double>.broadcast();
    }
    return _progressControllers[languageCode]!.stream;
  }
  
  /// Update download progress
  void _updateProgress(String languageCode, double progress) {
    _downloadProgress[languageCode] = progress;
    if (_progressControllers.containsKey(languageCode)) {
      _progressControllers[languageCode]!.add(progress);
    }
    if (kDebugMode) {
      print('Progress for $languageCode: ${(progress * 100).toInt()}%');
    }
  }
  
  /// Check if internet connection is available
  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final hasInternet = !connectivityResult.contains(ConnectivityResult.none);
      if (kDebugMode) {
        print('Internet connection: $hasInternet (${connectivityResult.map((e) => e.name).join(', ')})');
      }
      return hasInternet;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      return false;
    }
  }
  
  /// Delete model if it exists (to reset stuck downloads)
  Future<bool> _deleteModel(String languageCode) async {
    try {
      if (kDebugMode) {
        print('Attempting to delete model: $languageCode');
      }
      await _modelManager.deleteModel(languageCode);
      if (kDebugMode) {
        print('Model deleted: $languageCode');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting model: $e');
      }
      return false;
    }
  }
  
  /// Check if models are already downloaded
  Future<bool> _areModelsDownloaded(LanguageModel source, LanguageModel target) async {
    try {
      final sourceCode = source.mlKitLanguage.bcpCode;
      final targetCode = target.mlKitLanguage.bcpCode;
      
      final isSourceDownloaded = await _modelManager.isModelDownloaded(sourceCode);
      final isTargetDownloaded = await _modelManager.isModelDownloaded(targetCode);
      
      if (kDebugMode) {
        print('Source ($sourceCode) downloaded: $isSourceDownloaded');
        print('Target ($targetCode) downloaded: $isTargetDownloaded');
      }
      
      return isSourceDownloaded && isTargetDownloaded;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking models: $e');
      }
      return false;
    }
  }
  
  /// Download model with retry logic and progress simulation
  Future<bool> _downloadModelWithRetry(
    String languageCode, 
    String languageName, 
    Function(String) onProgress,
    {int maxRetries = 3}
  ) async {
    int attempt = 0;
    
    while (attempt < maxRetries) {
      attempt++;
      if (kDebugMode) {
        print('Download attempt $attempt for $languageCode');
      }
      
      try {
        final success = await _downloadModel(languageCode, languageName, onProgress);
        if (success) {
          // Verify download completed
          final isDownloaded = await _modelManager.isModelDownloaded(languageCode);
          if (isDownloaded) {
            if (kDebugMode) {
              print('✅ Model $languageCode successfully downloaded and verified');
            }
            return true;
          } else {
            if (kDebugMode) {
              print('⚠️ Model $languageCode download completed but verification failed');
            }
            throw Exception('Model verification failed');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Attempt $attempt failed for $languageCode: $e');
        }
        
        // Clean up failed download
        await _deleteModel(languageCode);
        
        if (attempt < maxRetries) {
          onProgress('Retrying $languageName download (attempt $attempt/$maxRetries)...');
          await Future.delayed(Duration(seconds: 2 * attempt)); // Exponential backoff
        } else {
          onProgress('❌ Failed to download $languageName after $maxRetries attempts');
          return false;
        }
      }
    }
    
    return false;
  }
  
  /// Download model with proper error handling
  Future<bool> _downloadModel(
    String languageCode, 
    String languageName, 
    Function(String) onProgress
  ) async {
    try {
      onProgress('Downloading $languageName model...');
      _updateProgress(languageCode, 0.0);
      
      // Cancel any existing progress timer
      _progressTimers[languageCode]?.cancel();
      
      // Check if already downloaded
      final isDownloaded = await _modelManager.isModelDownloaded(languageCode);
      if (isDownloaded) {
        if (kDebugMode) {
          print('Model $languageCode already downloaded');
        }
        _updateProgress(languageCode, 1.0);
        return true;
      }
      
      // Start download with progress simulation
      final completer = Completer<bool>();
      bool isCompleted = false;
      
      // Start progress simulation
      _progressTimers[languageCode] = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (!isCompleted) {
          final currentProgress = _downloadProgress[languageCode] ?? 0.0;
          if (currentProgress < 0.85) {
            // Simulate progress up to 85%
            final newProgress = (currentProgress + 0.05).clamp(0.0, 0.85);
            _updateProgress(languageCode, newProgress);
          } else if (currentProgress >= 0.85 && currentProgress < 0.95) {
            // Slow down progress near completion
            final newProgress = (currentProgress + 0.01).clamp(0.0, 0.95);
            _updateProgress(languageCode, newProgress);
          }
        }
      });
      
      // Set timeout for download (2 minutes)
      final timeout = Future.delayed(const Duration(minutes: 2), () {
        if (!completer.isCompleted) {
          if (kDebugMode) {
            print('Download timeout for $languageCode');
          }
          completer.completeError(TimeoutException('Download timeout after 2 minutes'));
        }
      });
      
      try {
        if (kDebugMode) {
          print('Starting download for $languageCode');
        }
        
        // Start the actual download
        await _modelManager.downloadModel(languageCode);
        
        isCompleted = true;
        _progressTimers[languageCode]?.cancel();
        _updateProgress(languageCode, 1.0);
        
        if (!completer.isCompleted) {
          completer.complete(true);
        }
        
        timeout.catchError((_) {});
        
        if (kDebugMode) {
          print('Download completed for $languageCode');
        }
        return true;
        
      } catch (e) {
        isCompleted = true;
        _progressTimers[languageCode]?.cancel();
        
        if (kDebugMode) {
          print('Download error for $languageCode: $e');
        }
        
        // Check if it's a partial download
        final isPartialDownloaded = await _modelManager.isModelDownloaded(languageCode);
        if (isPartialDownloaded) {
          if (kDebugMode) {
            print('Partial download detected, cleaning up...');
          }
          await _deleteModel(languageCode);
        }
        
        _updateProgress(languageCode, -1.0);
        rethrow;
      } finally {
        timeout.catchError((_) {});
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('Failed to download $languageCode: $e');
      }
      onProgress('❌ Failed to download $languageName model: $e');
      return false;
    }
  }
  
  /// Special handling for Hindi model (known issues)
  Future<bool> _downloadHindiModel(LanguageModel hindi, Function(String) onProgress) async {
    onProgress('Preparing Hindi model download...');
    
    // First, delete any existing Hindi model to ensure clean download
    final hindiCode = hindi.mlKitLanguage.bcpCode;
    final isExisting = await _modelManager.isModelDownloaded(hindiCode);
    
    if (isExisting) {
      onProgress('Removing existing Hindi model for clean download...');
      await _deleteModel(hindiCode);
      await Future.delayed(const Duration(seconds: 1));
    }
    
    // Try alternative download approach for Hindi
    onProgress('Downloading Hindi model (this may take a moment)...');
    
    // Use retry logic for Hindi
    return await _downloadModelWithRetry(
      hindiCode,
      hindi.name,
      onProgress,
      maxRetries: 3,
    );
  }
  
  /// Prepare translator with special handling for Hindi
  Future<bool> prepareTranslator(
    LanguageModel source,
    LanguageModel target,
    Function(String) onProgress,
  ) async {
    try {
      if (kDebugMode) {
        print('Preparing translator for ${source.name} -> ${target.name}');
      }
      
      // Check if models are already downloaded
      onProgress('Checking if models are available...');
      final bool modelsDownloaded = await _areModelsDownloaded(source, target);
      
      if (modelsDownloaded) {
        _translator?.close();
        _translator = OnDeviceTranslator(
          sourceLanguage: source.mlKitLanguage,
          targetLanguage: target.mlKitLanguage,
        );
        onProgress('✅ Ready to translate');
        return true;
      }
      
      // Check internet
      onProgress('Checking internet connection...');
      final bool hasInternet = await _hasInternetConnection();
      
      if (!hasInternet) {
        onProgress('❌ No internet connection. Please ensure your internet connection to download language models.');
        return false;
      }
      
      // Handle Hindi specially if it's source or target
      bool sourceSuccess = true;
      bool targetSuccess = true;
      
      if (source.name == 'Hindi') {
        sourceSuccess = await _downloadHindiModel(source, onProgress);
      } else {
        sourceSuccess = await _downloadModelWithRetry(
          source.mlKitLanguage.bcpCode,
          source.name,
          onProgress,
        );
      }
      
      if (!sourceSuccess) {
        onProgress('❌ Failed to download ${source.name} model');
        return false;
      }
      
      if (target.name == 'Hindi') {
        targetSuccess = await _downloadHindiModel(target, onProgress);
      } else {
        targetSuccess = await _downloadModelWithRetry(
          target.mlKitLanguage.bcpCode,
          target.name,
          onProgress,
        );
      }
      
      if (!targetSuccess) {
        onProgress('❌ Failed to download ${target.name} model');
        return false;
      }
      
      // Initialize translator
      _translator?.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: source.mlKitLanguage,
        targetLanguage: target.mlKitLanguage,
      );
      
      onProgress('✅ Models ready to translate');
      return true;
      
    } catch (e) {
      if (kDebugMode) {
        print('Error in prepareTranslator: $e');
      }
      onProgress('❌ Error: $e');
      return false;
    }
  }
  
  /// Force reset and redownload Hindi model
  Future<bool> resetHindiModel(Function(String) onProgress) async {
    final hindiLanguage = SupportedLanguages.languages.firstWhere(
      (lang) => lang.name == 'Hindi',
      orElse: () => SupportedLanguages.languages.first,
    );
    
    if (hindiLanguage.name != 'Hindi') {
      onProgress('❌ Hindi language not found');
      return false;
    }
    
    onProgress('Resetting Hindi model...');
    final hindiCode = hindiLanguage.mlKitLanguage.bcpCode;
    
    // Delete existing model
    final deleted = await _deleteModel(hindiCode);
    if (deleted) {
      onProgress('Hindi model removed. Re-downloading...');
      await Future.delayed(const Duration(seconds: 1));
    }
    
    // Download fresh
    return await _downloadHindiModel(hindiLanguage, onProgress);
  }
  
  Future<String> translate(String text) async {
    if (_translator == null || text.isEmpty) {
      return '';
    }
    
    try {
      final result = await _translator!.translateText(text.trim());
      return result;
    } catch (e) {
      throw Exception('Translation failed: $e');
    }
  }
  
  void dispose() {
    _translator?.close();
    for (var timer in _progressTimers.values) {
      timer?.cancel();
    }
    _progressTimers.clear();
    for (var controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    _downloadProgress.clear();
  }
}