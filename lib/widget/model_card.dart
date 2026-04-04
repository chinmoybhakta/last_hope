import 'package:flutter/material.dart';
import 'package:last_hope_ai/data/model/model_info.dart';
import 'package:last_hope_ai/service/hf_api_service.dart';

class ModelCard extends StatelessWidget {
  final HFModelInfo model;
  final Function(String, String) onDownload;  // Now takes repo and filename

  const ModelCard({
    super.key,
    required this.model,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final api = HFAPIService();
    final displayName = api.getDisplayName(model);
    final size = api.getModelSize(model);
    final description = api.getModelDescription(model);
    final repoId = model.id;
    final filename = api.getRecommendedFile(model);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: const Icon(Icons.model_training),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Size: $size'),
            Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: filename != null
              ? () => onDownload(repoId, filename)
              : null,
          child: const Text('Download'),
        ),
      ),
    );
  }
}