import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:last_hope_ai/data/model/model_info.dart';
import 'package:last_hope_ai/screen/login_screen.dart';
import 'package:last_hope_ai/service/auth_service.dart';
import 'package:last_hope_ai/service/hf_api_service.dart';
import 'package:last_hope_ai/service/model_loader_service.dart';
import 'package:last_hope_ai/widget/model_card.dart';
import 'download_screen.dart';
import 'chat_screen.dart';

class ModelBrowserScreen extends StatefulWidget {
  const ModelBrowserScreen({super.key});

  @override
  State<ModelBrowserScreen> createState() => _ModelBrowserScreenState();
}

class _ModelBrowserScreenState extends State<ModelBrowserScreen> {
  final HFAPIService _api = HFAPIService();
  final ModelLoaderService _loader = ModelLoaderService(); // Create instance directly

  List<HFModelInfo> _models = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // This will now only show our 2 survival models
      final models = await _api.getSurvivalModels();
      setState(() {
        _models = models;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      log(e.toString());
    }
  }

  Future<void> _downloadModel(HFModelInfo model, String filename) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DownloadScreen(modelId: model.id, filename: filename),
      ),
    );

    if (result != null && mounted) {
      // Model downloaded successfully
      log('DEBUG: ModelBrowser - DownloadScreen returned path: $result');
      final loaded = await _loader.loadModel(
        result,
        onStatus: (status) {
          log('DEBUG: ModelBrowser - Status: $status');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(status)));
        },
      );

      if (loaded && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Models'),
        backgroundColor: Colors.green[900],
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadModels),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (mounted) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _models.isEmpty
          ? const Center(child: Text('No GGUF models found'))
          : ListView.builder(
        itemCount: _models.length,
        itemBuilder: (context, index) {
          final model = _models[index];
          return ModelCard(
            model: model,
            onDownload: (repoId, filename) {
              _downloadModel(model, filename);
            },
          );
        },
      ),
    );
  }
}
