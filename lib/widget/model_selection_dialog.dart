import 'package:flutter/material.dart';
import 'package:last_hope_ai/service/model_service.dart';

class ModelSelectionDialog extends StatefulWidget {
  const ModelSelectionDialog({super.key});

  @override
  State<ModelSelectionDialog> createState() => _ModelSelectionDialogState();
}

class _ModelSelectionDialogState extends State<ModelSelectionDialog> {
  final ModelService _modelService = ModelService();
  List<ModelInfo> _models = [];
  bool _isLoading = true;
  String? _selectedModelPath;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final models = await _modelService.getAvailableModels();
      setState(() {
        _models = models;
        _isLoading = false;
        // Select first model by default
        if (_models.isNotEmpty && _selectedModelPath == null) {
          _selectedModelPath = _models.first.path;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteModel(ModelInfo model) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Model'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${model.name}"?'),
            const SizedBox(height: 8),
            Text(
              'Size: ${model.formattedSize}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final success = await _modelService.deleteModel(model.path);
      if (success) {
        await _loadModels(); // Refresh model list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Model deleted successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete model')),
          );
        }
      }
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade900,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.model_training, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Select Model',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _loadModels,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Refresh Models',
                  ),
                ],
              ),
            ),

            // Content
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              )
            else if (_models.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_off, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No models found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please download a model first',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _models.length,
                  itemBuilder: (context, index) {
                    final model = _models[index];
                    final isSelected = _selectedModelPath == model.path;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: RadioListTile<String>(
                        value: model.path,
                        // ignore: deprecated_member_use
                        groupValue: _selectedModelPath,
                        // ignore: deprecated_member_use
                        onChanged: (value) {
                          setState(() {
                            _selectedModelPath = value;
                          });
                        },
                        title: Text(
                          model.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Size: ${model.formattedSize}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Modified: ${model.formattedDate}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        secondary: IconButton(
                          onPressed: _isDeleting ? null : () => _deleteModel(model),
                          icon: _isDeleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete Model',
                        ),
                        selected: isSelected,
                        activeColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedModelPath != null
                          ? () => Navigator.of(context).pop(_selectedModelPath)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Select Model'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
