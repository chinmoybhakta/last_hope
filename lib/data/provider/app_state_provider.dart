import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:last_hope_ai/service/auth_service.dart';
import 'package:last_hope_ai/service/model_loader_service.dart';
import 'package:path_provider/path_provider.dart';

// Model availability state
class ModelAvailabilityState {
  final bool hasModel;
  final bool isLoading;
  final String? error;
  final List<String> availableModels;

  ModelAvailabilityState({
    required this.hasModel,
    required this.isLoading,
    this.error,
    this.availableModels = const [],
  });

  ModelAvailabilityState copyWith({
    bool? hasModel,
    bool? isLoading,
    String? error,
    List<String>? availableModels,
  }) {
    return ModelAvailabilityState(
      hasModel: hasModel ?? this.hasModel,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      availableModels: availableModels ?? this.availableModels,
    );
  }
}

// Model availability notifier
class ModelAvailabilityNotifier extends StateNotifier<ModelAvailabilityState> {
  ModelAvailabilityNotifier() : super(ModelAvailabilityState(
    hasModel: false,
    isLoading: true,
    availableModels: [],
  ));

  Future<void> checkForModels() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDir.path}/models');
      if (!await dir.exists()) {
        state = state.copyWith(
          hasModel: false,
          isLoading: false,
          availableModels: [],
        );
        return;
      }

      final files = await dir.list().toList();
      final ggufFiles = files
          .where((f) => f is File && f.path.endsWith('.gguf'))
          .cast<File>()
          .toList();

      final modelPaths = ggufFiles.map((f) => f.path).toList();
      
      log('DEBUG: Found ${ggufFiles.length} GGUF models: $modelPaths');

      state = state.copyWith(
        hasModel: ggufFiles.isNotEmpty,
        isLoading: false,
        availableModels: modelPaths,
      );
    } catch (e) {
      log('Error checking for models: $e');
      state = state.copyWith(
        hasModel: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshModels() async {
    await checkForModels();
  }
}

// Auth state
class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;

  AuthState({
    required this.isLoggedIn,
    required this.isLoading,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(
    isLoggedIn: false,
    isLoading: true,
  ));

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final auth = AuthService();
      final isLoggedIn = await auth.isLoggedIn();
      
      state = state.copyWith(
        isLoggedIn: isLoggedIn,
        isLoading: false,
      );
    } catch (e) {
      log('Error checking auth status: $e');
      state = state.copyWith(
        isLoggedIn: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Model loader state
class ModelLoaderState {
  final bool isLoaded;
  final bool isLoading;
  final String? status;
  final String? error;
  final String? loadedModelPath;

  ModelLoaderState({
    required this.isLoaded,
    required this.isLoading,
    this.status,
    this.error,
    this.loadedModelPath,
  });

  ModelLoaderState copyWith({
    bool? isLoaded,
    bool? isLoading,
    String? status,
    String? error,
    String? loadedModelPath,
  }) {
    return ModelLoaderState(
      isLoaded: isLoaded ?? this.isLoaded,
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      error: error ?? this.error,
      loadedModelPath: loadedModelPath ?? this.loadedModelPath,
    );
  }
}

// Model loader notifier
class ModelLoaderNotifier extends StateNotifier<ModelLoaderState> {
  final ModelLoaderService _modelLoader = ModelLoaderService();
  
  ModelLoaderNotifier() : super(ModelLoaderState(
    isLoaded: false,
    isLoading: false,
  ));

  Future<bool> loadFirstAvailableModel({
    required Function(String) onStatus,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      onStatus('Loading model...');
      
      final loaded = await _modelLoader.loadFirstAvailableModel(
        onStatus: (status) {
          state = state.copyWith(status: status);
          onStatus(status);
        },
      );

      state = state.copyWith(
        isLoaded: loaded,
        isLoading: false,
        status: loaded ? 'Model loaded successfully!' : 'Failed to load model',
        loadedModelPath: loaded ? _modelLoader.currentModelPath : null,
      );

      return loaded;
    } catch (e) {
      log('Error loading model: $e');
      state = state.copyWith(
        isLoaded: false,
        isLoading: false,
        status: 'Error loading model',
        error: e.toString(),
        loadedModelPath: null,
      );
      return false;
    }
  }

  Future<bool> loadSpecificModel(String modelPath, {
    required Function(String) onStatus,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      onStatus('Loading model...');
      
      final loaded = await _modelLoader.loadModel(modelPath, onStatus: (status) {
        state = state.copyWith(status: status);
        onStatus(status);
      });

      state = state.copyWith(
        isLoaded: loaded,
        isLoading: false,
        status: loaded ? 'Model loaded successfully!' : 'Failed to load model',
        loadedModelPath: loaded ? _modelLoader.currentModelPath : null,
      );

      return loaded;
    } catch (e) {
      log('Error loading model: $e');
      state = state.copyWith(
        isLoaded: false,
        isLoading: false,
        status: 'Error loading model',
        error: e.toString(),
        loadedModelPath: null,
      );
      return false;
    }
  }

  Future<void> unloadModel() async {
    try {
      await _modelLoader.unloadModel();
      state = state.copyWith(
        isLoaded: false,
        status: 'Model unloaded',
        loadedModelPath: null,
      );
    } catch (e) {
      log('Error unloading model: $e');
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }

  bool get isModelLoaded => _modelLoader.isLoaded;
  String? get currentModelPath => _modelLoader.currentModelPath;
}

// Providers
final modelAvailabilityProvider = StateNotifierProvider<ModelAvailabilityNotifier, ModelAvailabilityState>(
  (ref) => ModelAvailabilityNotifier(),
);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

final modelLoaderProvider = StateNotifierProvider<ModelLoaderNotifier, ModelLoaderState>(
  (ref) => ModelLoaderNotifier(),
);

// Watch providers for convenience
final modelAvailabilityStateProvider = Provider<ModelAvailabilityState>(
  (ref) => ref.watch(modelAvailabilityProvider),
);

final authStateProvider = Provider<AuthState>(
  (ref) => ref.watch(authProvider),
);

final modelLoaderStateProvider = Provider<ModelLoaderState>(
  (ref) => ref.watch(modelLoaderProvider),
);
