class HFModelInfo {
  final String id;
  final String displayName;
  final String description;
  final int downloads;
  final int likes;
  final String author;
  final String createdAt;
  final String lastModified;
  final List<String> tags;
  List<String> files;
  final Map<String, dynamic> rawData;
  Map<String, dynamic>? customData;

  HFModelInfo({
    required this.id,
    required this.displayName,
    required this.description,
    required this.downloads,
    required this.likes,
    required this.author,
    required this.createdAt,
    required this.lastModified,
    required this.tags,
    this.files = const [],
    required this.rawData,
    this.customData
  });

  factory HFModelInfo.fromJson(Map<String, dynamic> json) {
    return HFModelInfo(
      id: json['id'] ?? '',
      displayName: json['modelId'] ?? json['id'] ?? '',
      description: json['description'] ?? '',
      downloads: json['downloads'] ?? 0,
      likes: json['likes'] ?? 0,
      author: json['author'] ?? '',
      createdAt: json['createdAt'] ?? '',
      lastModified: json['lastModified'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      rawData: json,
      customData: null
    );
  }

  bool get isGGUF {
    return tags.any((tag) => tag.toLowerCase().contains('gguf')) ||
        displayName.toLowerCase().contains('gguf') ||
        files.any((file) => file.toLowerCase().endsWith('.gguf'));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelId': displayName,
      'description': description,
      'downloads': downloads,
      'likes': likes,
      'author': author,
      'createdAt': createdAt,
      'lastModified': lastModified,
      'tags': tags,
      'files': files,
      ...rawData,
    };
  }
}