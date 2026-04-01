import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? _database;
  String? _currentDatabaseName;
  
  Future<Database> getDatabase(String databaseName, String assetPath) async {
    if (_database != null && _currentDatabaseName == databaseName) {
      return _database!;
    }
    
    _currentDatabaseName = databaseName;
    final appDocDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDocDir.path, '$databaseName.sqlite');
    
    final dbFile = File(dbPath);
    if (!await dbFile.exists()) {
      final dbData = await rootBundle.load(assetPath);
      final bytes = dbData.buffer.asUint8List();
      await dbFile.writeAsBytes(bytes, flush: true);
    }
    
    _database = await openDatabase(dbPath);
    return _database!;
  }
  
  Future<List<String>> getAllTitles(Database db) async {
    try {
      final results = await db.query('articles', columns: ['title']);
      return results
          .map((r) => r['title']?.toString() ?? '')
          .where((title) => title.isNotEmpty)
          .toList();
    } catch (e) {
      log('Error loading titles: $e');
      return [];
    }
  }
  
  Future<String?> getArticleContent(Database db, String title) async {
    try {
      final results = await db.rawQuery(
        'SELECT content FROM articles WHERE title = ?',
        [title],
      );
      if (results.isEmpty) return null;
      return results.first['content'] as String? ?? '';
    } catch (e) {
      log('Error loading article: $e');
      return null;
    }
  }
  
  Future<List<String>> searchArticles(Database db, String query, List<String> allTitles) async {
    if (query.isEmpty) return [];
    final lower = query.toLowerCase().trim();
    return allTitles
        .where((title) => title.toLowerCase().contains(lower))
        .take(20)
        .toList();
  }
  
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}