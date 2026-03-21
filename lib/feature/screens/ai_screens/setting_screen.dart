import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/download_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DownloadService _download = DownloadService();
  List<File> _downloadedModels = [];

  @override
  void initState() {
    super.initState();
    _loadDownloadedModels();
  }

  Future<void> _loadDownloadedModels() async {
    final models = await _download.getDownloadedModelFiles();
    setState(() {
      _downloadedModels = models;
    });
  }

  Future<void> _deleteModel(File file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Model'),
        content: Text('Delete ${file.path.split('/').last}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _download.deleteModel(file.path);
      await _loadDownloadedModels();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green[900],
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Downloaded Models'),
            subtitle: Text('Manage your local models'),
          ),
          ..._downloadedModels.map((file) => ListTile(
            title: Text(file.path.split('/').last),
            subtitle: Text('${(file.lengthSync() / 1024 / 1024).toStringAsFixed(1)} MB'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteModel(file),
            ),
          )),
        ],
      ),
    );
  }
}