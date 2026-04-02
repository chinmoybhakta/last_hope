class Comic {
  final String id;
  final String title;
  final String filePath;
  String coverPath;

  Comic({
    required this.id,
    required this.title,
    required this.filePath,
    this.coverPath = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'filePath': filePath,
    'coverPath': coverPath,
  };

  factory Comic.fromJson(Map<String, dynamic> json) => Comic(
    id: json['id'],
    title: json['title'],
    filePath: json['filePath'],
    coverPath: json['coverPath'] ?? '',
  );
}