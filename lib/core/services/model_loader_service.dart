import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:llama_flutter_android/llama_flutter_android.dart' as llama;

class ModelLoaderService {
  static final ModelLoaderService _instance = ModelLoaderService._internal();
  factory ModelLoaderService() => _instance;
  ModelLoaderService._internal();

  bool _isLoading = false;
  bool _isLoaded = false;
  String? _currentModelPath;

  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;
  String? get currentModelPath => _currentModelPath;

  final controller = llama.LlamaController();

  // Get the correct models directory (native path)
  Future<String> get _modelsDir async {
    final modelsDir = Directory('/data/user/0/com.example.last_hope/app_flutter/models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir.path;
  }

  // Get model path by filename
  Future<String> getModelPath(String filename) async {
    final dir = await _modelsDir;
    return '$dir/$filename';
  }

  // Load first available model
  Future<bool> loadFirstAvailableModel({
    required Function(String status) onStatus,
  }) async {
    try {
      final dir = await _modelsDir;
      final modelsDir = Directory(dir);
      
      if (!await modelsDir.exists()) {
        onStatus('Models directory not found');
        return false;
      }

      final files = await modelsDir.list().toList();
      final ggufFiles = files.where((f) => 
        f is File && f.path.endsWith('.gguf')
      ).cast<File>().toList();

      if (ggufFiles.isEmpty) {
        onStatus('No GGUF models found. Please download a model first.');
        return false;
      }

      // Load the first GGUF file found
      final modelPath = ggufFiles.first.path;
      return await loadModel(modelPath, onStatus: onStatus);
    } catch (e) {
      onStatus('Error finding model: $e');
      return false;
    }
  }

  // Load model using llama_flutter_android
  Future<bool> loadModel(String modelPath, {
    required Function(String status) onStatus,
  }) async {
    try {
      // Check if model is already loaded
      if (_isLoaded && _currentModelPath == modelPath) {
        // onStatus('Model already loaded!');
        log('DEBUG: Model already loaded, skipping load');
        return true;
      }

      // If a different model is loaded, unload it first
      if (_isLoaded && _currentModelPath != modelPath) {
        log('DEBUG: Different model loaded, unloading first');
        await unloadModel();
      }

      _isLoading = true;
      onStatus('Loading model...');
      
      log('DEBUG: loadModel called with path: $modelPath');

      // Check if model file exists
      final modelFile = File(modelPath);
      onStatus('Checking model file...');
      
      log('DEBUG: File exists check for: ${modelFile.path}');
      
      if (!await modelFile.exists()) {
        onStatus('Model file not found. Please download the model first.');
        log('DEBUG: File does not exist at: ${modelFile.path}');
        return false;
      }

      log('DEBUG: File exists, proceeding with model load');
      onStatus('Model file found, loading...');
      
      // Check file size and permissions
      final stat = await modelFile.stat();
      log('DEBUG: Model file size: ${stat.size} bytes');
      log('DEBUG: Model file modified: ${stat.modified}');
      
      if (stat.size == 0) {
        onStatus('Model file is empty. Please re-download.');
        return false;
      }

      // Load model using llama_flutter_android
      log('DEBUG: Loading model with llama_flutter_android...');
      await controller.loadModel(modelPath: modelPath);
      
      log('DEBUG: Model loaded successfully');
      _isLoaded = true;
      _currentModelPath = modelPath;
      onStatus('Model loaded successfully!');
      return true;

    } catch (e) {
      onStatus('Error loading model: $e');
      log('DEBUG: Error loading model: $e');
      
      // If it's "Model already loaded" error, treat as success and update state
      if (e.toString().contains('Model already loaded')) {
        log('DEBUG: Model already loaded in controller, updating state');
        _isLoaded = true;
        _currentModelPath = modelPath;
        onStatus('Model loaded successfully!');
        return true;
      }
      
      _isLoaded = false;
      _currentModelPath = null;
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Generate response using llama_flutter_android
  Stream<String> generateResponse(String prompt) {
    if (!_isLoaded) {
      return Stream.error('Model not loaded');
    }

    log('DEBUG: Generating response for prompt: $prompt');
    
    return controller.generate(
      prompt: prompt,
      maxTokens: 1000,
      temperature: 0.7,
      topP: 0.9,
      topK: 40,
      repeatPenalty: 1.1,
      frequencyPenalty: 0.5,
      presencePenalty: 0.3,
      seed: 42,
    );
  }

  // Generate chat response with template formatting
  Stream<String> generateChatResponse(String prompt) {
    if (!_isLoaded) {
      return Stream.error('Model not loaded');
    }

    log('DEBUG: Generating chat response for prompt: $prompt');
    
    // Create survival-focused system prompt
    final systemPrompt = '''You are an expert survival assistant specializing in wilderness and emergency survival scenarios. Your expertise includes:

CORE SURVIVAL AREAS:
• Daily needs: Water purification, food collection, shelter building, fire starting
• Hunting & fishing: Trapping, tracking, cleaning, cooking wild game
• First aid: Injury treatment, emergency medical care, natural remedies
• Navigation: Map reading, compass use, GPS, celestial navigation
• Emergency protocols: Weather preparedness, signaling, evacuation planning
• Resource management: Sustainable living, tool maintenance, conservation

RESPONSE FORMAT RULES:
- Use clean, clear language without unnecessary symbols or punctuation
- Start new sentences on new lines for better readability
- Use numbered lists for step-by-step instructions (1. 2. 3.)
- Use bullet points for lists of items or options (• item)
- Keep responses practical and actionable
- Prioritize safety in all recommendations
- Consider different experience levels (beginner to expert)

Your goal is to provide reliable, life-saving information that could help someone in real survival situations.''';
    
    return controller.generateChat(
      messages: [
        llama.ChatMessage(role: 'system', content: systemPrompt),
        llama.ChatMessage(role: 'user', content: prompt),
      ],
      maxTokens: 1200,  // Increased for detailed responses
      temperature: 0.6,    // Slightly lower for more consistent, factual responses
      topP: 0.9,
      topK: 40,
      repeatPenalty: 1.1,
      frequencyPenalty: 0.5,
      presencePenalty: 0.3,
      seed: 42,
      template: 'chatml', // Use chatml format
    );
  }

  // Stop generation
  Future<void> stopGeneration() async {
    try {
      await controller.stop();
      log('DEBUG: Generation stopped');
    } catch (e) {
      log('DEBUG: Error stopping generation: $e');
    }
  }

  // Unload model
  Future<void> unloadModel() async {
    try {
      await controller.dispose();
      _isLoaded = false;
      _currentModelPath = null;
      log('DEBUG: Model unloaded');
    } catch (e) {
      log('DEBUG: Error unloading model: $e');
      // Even if dispose fails, reset state
      _isLoaded = false;
      _currentModelPath = null;
    }
  }

  // Force unload model (used to handle "Model already loaded" state)
  Future<void> forceUnloadModel() async {
    try {
      log('DEBUG: Force unloading model...');
      await controller.dispose();
      _isLoaded = false;
      _currentModelPath = null;
      log('DEBUG: Model force unloaded');
    } catch (e) {
      log('DEBUG: Error force unloading model: $e');
      // Even if dispose fails, reset state
      _isLoaded = false;
      _currentModelPath = null;
    }
  }
}