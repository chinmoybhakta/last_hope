import 'package:flutter/material.dart';
import '../../../core/services/download_service.dart';

class DownloadScreen extends StatefulWidget {
  final String modelId;
  final String filename;

  const DownloadScreen({
    super.key,
    required this.modelId,
    required this.filename,
  });

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final DownloadService _download = DownloadService();
  double _progress = 0;
  String _status = 'Starting...';
  String? _downloadedPath;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  @override
  void dispose() {
    // Cancel download if in progress
    _download.cancelDownload();
    super.dispose();
  }

  Future<void> _startDownload() async {
    final path = await _download.downloadModel(
      modelId: widget.modelId,
      filename: widget.filename,
      onProgress: (progress, status) {
        if (mounted) {
          setState(() {
            _progress = progress;
            _status = status;
          });
        }
      },
    );
    
    if (mounted) {
      setState(() {
        _downloadedPath = path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloading Model'),
        backgroundColor: Colors.green[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download, size: 64),
            const SizedBox(height: 24),
            Text(
              widget.filename,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 12),
            Text(_status),
            const SizedBox(height: 24),
            if (_downloadedPath != null)
              ElevatedButton(
                onPressed: () => Navigator.pop(context, _downloadedPath),
                child: const Text('Continue to Chat'),
              ),
          ],
        ),
      ),
    );
  }
}