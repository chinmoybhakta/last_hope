import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class OfflineWikiScreen extends StatefulWidget {
  const OfflineWikiScreen({super.key});

  @override
  State<OfflineWikiScreen> createState() => _OfflineWikiScreenState();
}

class _OfflineWikiScreenState extends State<OfflineWikiScreen> {
  late Database _database;
  late WebViewController _webViewController;
  List<String> _allTitles = [];
  String _currentTitle = 'Offline Wikipedia';
  bool _isReady = false;
  String _loadingStatus = 'Initializing...';
  final TextEditingController _searchController = TextEditingController();

  // Cache for article content
  final Map<String, String> _articleCache = {};

  @override
  void initState() {
    super.initState();
    _initializeEverything();
  }

  Future<void> _initializeEverything() async {
    try {
      _updateStatus('Getting app directory...');
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(appDocDir.path, 'wiki.sqlite');

      _updateStatus('Copying database file...');
      final dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        final dbData = await rootBundle.load('assets/wiki_sqlite_file/wiki.sqlite');
        final bytes = dbData.buffer.asUint8List();
        await dbFile.writeAsBytes(bytes, flush: true);
        _updateStatus('Database file copied');
      } else {
        _updateStatus('Database file already exists');
      }

      _updateStatus('Opening database...');
      _database = await openDatabase(dbPath);

      _updateStatus('Loading article titles...');
      await _loadTitlesFromDatabase();

      _updateStatus('Initializing WebView...');
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              debugPrint('Page started: $url');
            },
            onPageFinished: (String url) {
              debugPrint('Page finished: $url');
            },
            onWebResourceError: (error) {
              debugPrint('WebView error: $error');
            },
          ),
        )
        ..loadHtmlString(_getWelcomeHtml());

      _updateStatus('Ready!');

      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    } catch (e) {
      _updateStatus('Error: $e');
      debugPrint('Initialization error: $e');
    }
  }

  void _updateStatus(String status) {
    debugPrint('Status: $status');
    if (mounted) {
      setState(() {
        _loadingStatus = status;
      });
    }
  }

  String _getWelcomeHtml() {
    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { 
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
              padding: 20px; 
              line-height: 1.6;
              color: #333;
              max-width: 800px;
              margin: 0 auto;
            }
            h1 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
            .info { background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0; }
            .stats { font-weight: bold; color: #3498db; }
          </style>
        </head>
        <body>
          <h1>📚 Offline Wikipedia</h1>
          <div class="info">
            <p>✨ Search any article using the search bar above</p>
            <p>💾 All content is loaded from your local files</p>
            <p>📱 <span class="stats">${_allTitles.length}</span> articles available offline</p>
            <p><strong>🌐 Completely offline • No internet required</strong></p>
          </div>
          <p>Try searching for: "Thirteenth_Amendment" (the full title)</p>
        </body>
      </html>
    ''';
  }

  Future<void> _loadTitlesFromDatabase() async {
    try {
      _updateStatus('Querying database for titles...');

      final countResult = await _database.rawQuery('SELECT COUNT(*) as count FROM articles');
      final totalCount = countResult.first['count'] as int;
      _updateStatus('Total records in database: $totalCount');

      final results = await _database.query(
        'articles',
        columns: ['title'],
      );

      _allTitles = results
          .map((r) => r['title']?.toString() ?? '')
          .where((title) => title.isNotEmpty)
          .toList();

      _updateStatus('Loaded ${_allTitles.length} titles from database');

      if (_allTitles.isNotEmpty) {
        debugPrint('First 5 titles: ${_allTitles.take(5).toList()}');
      }

    } catch (dbError) {
      _updateStatus('Database error: $dbError');
      debugPrint('Database error: $dbError');
    }
  }

  Future<List<String>> _getSuggestions(String query) async {
    if (!_isReady || _allTitles.isEmpty) return [];

    final lower = query.toLowerCase().trim();

    if (lower.isEmpty) {
      return _allTitles.take(15).toList();
    }

    return _allTitles
        .where((title) => title.toLowerCase().contains(lower))
        .take(20)
        .toList();
  }

  String _extractRedirectTarget(String content) {
    // Check for meta refresh redirect
    final refreshRegex = RegExp(r'<meta\s+http-equiv="refresh"\s+content="0;url=([^"]+)"');
    final match = refreshRegex.firstMatch(content);
    if (match != null) {
      return match.group(1) ?? '';
    }
    return '';
  }

  Future<void> _loadArticle(String selectedTitle) async {
    try {
      debugPrint('Loading article: $selectedTitle');

      // Show loading indicator
      if (mounted) {
        _webViewController.loadHtmlString('''
          <!DOCTYPE html>
          <html>
            <head>
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <style>
                body { 
                  font-family: sans-serif; 
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  height: 100vh;
                  margin: 0;
                  color: #666;
                }
                .loader {
                  text-align: center;
                }
                .spinner {
                  border: 4px solid #f3f3f3;
                  border-top: 4px solid #3498db;
                  border-radius: 50%;
                  width: 40px;
                  height: 40px;
                  animation: spin 1s linear infinite;
                  margin: 20px auto;
                }
                @keyframes spin {
                  0% { transform: rotate(0deg); }
                  100% { transform: rotate(360deg); }
                }
              </style>
            </head>
            <body>
              <div class="loader">
                <div class="spinner"></div>
                <p>Loading "$selectedTitle"...</p>
              </div>
            </body>
          </html>
        ''');
      }

      // Function to recursively follow redirects
      Future<String> getFinalContent(String title, {Set<String> visited = const {}}) async {
        if (visited.contains(title)) {
          return '<p>Circular redirect detected for: $title</p>';
        }

        final results = await _database.rawQuery(
          'SELECT content FROM articles WHERE title = ?',
          [title],
        );

        if (results.isEmpty) {
          return '<p>Article not found: $title</p>';
        }

        String content = results.first['content'] as String? ?? '';

        // Check if this is a redirect
        final redirectTarget = _extractRedirectTarget(content);
        if (redirectTarget.isNotEmpty) {
          debugPrint('Redirecting from "$title" to "$redirectTarget"');
          final newVisited = {...visited, title};
          return getFinalContent(redirectTarget, visited: newVisited);
        }

        return content;
      }

      // Get the final content after following redirects
      String finalContent = await getFinalContent(selectedTitle);

      if (finalContent.isNotEmpty && mounted) {
        debugPrint('Final content length: ${finalContent.length}');

        // Ensure we have a complete HTML document
        String htmlToLoad;
        if (finalContent.trim().startsWith('<!DOCTYPE') || finalContent.trim().startsWith('<html')) {
          htmlToLoad = finalContent;
        } else {
          // Wrap in a basic HTML structure
          htmlToLoad = '''
            <!DOCTYPE html>
            <html>
              <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                  body { 
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
                    padding: 16px; 
                    line-height: 1.6;
                    color: #333;
                    max-width: 800px;
                    margin: 0 auto;
                  }
                  h1 { 
                    color: #2c3e50; 
                    border-bottom: 2px solid #3498db; 
                    padding-bottom: 10px;
                  }
                  img { max-width: 100%; height: auto; }
                </style>
              </head>
              <body>
                <h1>$selectedTitle</h1>
                $finalContent
              </body>
            </html>
          ''';
        }

        _articleCache[selectedTitle] = htmlToLoad;
        await _webViewController.loadHtmlString(htmlToLoad);

        if (mounted) {
          setState(() => _currentTitle = selectedTitle);
        }
      }
    } catch (e) {
      debugPrint('Error loading article: $e');
      if (mounted) {
        _webViewController.loadHtmlString('''
          <!DOCTYPE html>
          <html>
            <head>
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <style>
                body { 
                  font-family: sans-serif; 
                  padding: 20px;
                  text-align: center;
                }
                .error { 
                  background: #f8d7da; 
                  color: #721c24;
                  border: 1px solid #f5c6cb;
                  border-radius: 8px;
                  padding: 20px;
                  margin: 20px;
                }
              </style>
            </head>
            <body>
              <div class="error">
                <h2>⚠️ Error Loading Article</h2>
                <p>Error: $e</p>
              </div>
            </body>
          </html>
        ''');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentTitle,
          style: const TextStyle(fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (_isReady && _allTitles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '${_allTitles.length} articles',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TypeAheadField<String>(
              controller: _searchController,
              suggestionsCallback: (pattern) async {
                return await _getSuggestions(pattern);
              },
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: _isReady,
                  decoration: InputDecoration(
                    hintText: _isReady ? 'Search Wikipedia articles...' : 'Loading...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty && _isReady) {
                      _loadArticle(value);
                    }
                  },
                );
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: const Icon(Icons.article, color: Colors.blue),
                  title: Text(suggestion),
                  onTap: () {
                    _searchController.text = suggestion;
                    _loadArticle(suggestion);
                  },
                );
              },
              onSelected: (suggestion) {
                _searchController.text = suggestion;
                _loadArticle(suggestion);
              },
            ),
          ),

          Expanded(
            child: _isReady
                ? WillPopScope(
              onWillPop: () async {
                if (_currentTitle != 'Offline Wikipedia') {
                  _webViewController.loadHtmlString(_getWelcomeHtml());
                  _searchController.clear();
                  setState(() => _currentTitle = 'Offline Wikipedia');
                  return false;
                }
                return true;
              },
              child: WebViewWidget(
                controller: _webViewController,
              ),
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(_loadingStatus),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isReady && _currentTitle != 'Offline Wikipedia'
          ? FloatingActionButton.extended(
        onPressed: () {
          _webViewController.loadHtmlString(_getWelcomeHtml());
          _searchController.clear();
          setState(() => _currentTitle = 'Offline Wikipedia');
        },
        label: const Text('Home'),
        icon: const Icon(Icons.home),
        backgroundColor: Colors.blueGrey[800],
      )
          : null,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _database.close().catchError((e) => debugPrint('DB close error: $e'));
    super.dispose();
  }
}