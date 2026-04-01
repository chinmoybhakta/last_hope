import 'package:flutter/material.dart';

class DatabaseInfo {
  final String name;
  final String assetPath;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final List<Color> gradientColors;
  final List<String> stats;
  final List<StatInfo> statDetails;

  const DatabaseInfo({
    required this.name,
    required this.assetPath,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.gradientColors,
    required this.stats,
    this.statDetails = const [],
  });
}

class StatInfo {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatInfo({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class Article {
  final String title;
  final String content;

  const Article({
    required this.title,
    required this.content,
  });
}

class DatabaseConfig {
  static const List<DatabaseInfo> databases = [
    DatabaseInfo(
      name: 'final_clean_medicine',
      assetPath: 'asset/medicine.sqlite',
      title: 'Medical Reference Library',
      subtitle: 'Emergency Medicine & Clinical Guidelines',
      description: 'Comprehensive medical articles including emergency medicine, clinical guidelines, treatment protocols, and disease information.',
      icon: Icons.medical_services,
      primaryColor: Color(0xFF2E7D32),
      gradientColors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
      stats: ['3,864+ Articles', 'Offline Access', 'Quick Search'],
    ),
    DatabaseInfo(
      name: 'final_clean_four_sqlite',
      assetPath: 'asset/survival.sqlite',
      title: 'Survival Knowledge Base',
      subtitle: 'Complete Medical Reference Collection',
      description: 'Extensive medical reference collection with detailed articles, research materials, and comprehensive medical information.',
      icon: Icons.library_books,
      primaryColor: Color(0xFF1976D2),
      gradientColors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
      stats: ['Comprehensive', 'Full-text Search', 'Fast Loading'],
    ),
  ];
}