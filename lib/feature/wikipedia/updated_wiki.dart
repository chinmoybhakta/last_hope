import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667eea),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: 10),
                        Center(
                          child:  const Text(
                            'Offline WIKI',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your complete offline medical reference library',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Stats Cards
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.medical_services,
                          title: 'Survival',
                          value: 'Survival DB',
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.library_books,
                          title: 'Reference',
                          value: 'Reference DB',
                          color: const Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Database Cards Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildDatabaseCard(
                            title: 'Medical Reference Library',
                            subtitle: 'Emergency Medicine & Clinical Guidelines',
                            icon: Icons.medical_services,
                            color: const Color(0xFF2E7D32),
                            gradientColors: const [
                              Color(0xFF2E7D32),
                              Color(0xFF4CAF50),
                            ],
                            databaseName: 'final_clean_medicine',
                            databaseAssetPath: 'assets/updated_sqlites/final_clean_medicine.sqlite',
                            description: 'Comprehensive medical articles including emergency medicine, clinical guidelines, treatment protocols, and disease information.',
                            stats: ['3,864+ Articles', 'Offline Access', 'Quick Search'],
                          ),
                          const SizedBox(height: 24),
                          _buildDatabaseCard(
                            title: 'Survival Knowledge Base',
                            subtitle: 'Complete Medical Reference Collection',
                            icon: Icons.library_books,
                            color: const Color(0xFF1976D2),
                            gradientColors: const [
                              Color(0xFF1976D2),
                              Color(0xFF42A5F5),
                            ],
                            databaseName: 'final_clean_four_sqlite',
                            databaseAssetPath: 'assets/updated_sqlites/final_clean_four_sqlite.sqlite',
                            description: 'Extensive medical reference collection with detailed articles, research materials, and comprehensive medical information.',
                            stats: ['Comprehensive', 'Full-text Search', 'Fast Loading'],
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Color> gradientColors,
    required String databaseName,
    required String databaseAssetPath,
    required String description,
    required List<String> stats,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OfflineWikiScreen(
              databaseName: databaseName,
              databaseAssetPath: databaseAssetPath,
              title: title,
              primaryColor: color,
              icon: icon,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(24),
          elevation: 0,
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                // Description
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Stats Section
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: stats.map((stat) {
                      return Expanded(
                        child: Column(
                          children: [
                            Icon(
                              _getIconForStat(stat),
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              stat,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                // Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Open Database',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForStat(String stat) {
    if (stat.contains('Articles')) return Icons.article;
    if (stat.contains('Offline')) return Icons.offline_bolt;
    if (stat.contains('Search')) return Icons.search;
    if (stat.contains('Comprehensive')) return Icons.menu_book;
    if (stat.contains('Full-text')) return Icons.text_fields;
    if (stat.contains('Fast')) return Icons.speed;
    return Icons.star;
  }
}

class OfflineWikiScreen extends StatefulWidget {
  final String databaseName;
  final String databaseAssetPath;
  final String title;
  final Color primaryColor;
  final IconData icon;

  const OfflineWikiScreen({
    super.key,
    required this.databaseName,
    required this.databaseAssetPath,
    required this.title,
    required this.primaryColor,
    required this.icon,
  });

  @override
  State<OfflineWikiScreen> createState() => _OfflineWikiScreenState();
}

class _OfflineWikiScreenState extends State<OfflineWikiScreen> with SingleTickerProviderStateMixin {
  late Database _database;
  late WebViewController _webViewController;
  List<String> _allTitles = [];
  String _currentTitle = '';
  bool _isReady = false;
  String _loadingStatus = 'Initializing...';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final Map<String, String> _articleCache = {};
  List<String> _recentArticles = [];

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.title;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
    _initializeEverything();
  }

  Future<void> _initializeEverything() async {
    try {
      _updateStatus('Getting app directory...');
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(appDocDir.path, '${widget.databaseName}.sqlite');

      _updateStatus('Loading database...');
      final dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        _updateStatus('Copying database file...');
        final dbData = await rootBundle.load(widget.databaseAssetPath);
        final bytes = dbData.buffer.asUint8List();
        await dbFile.writeAsBytes(bytes, flush: true);
        _updateStatus('Database copied successfully');
      }

      _updateStatus('Opening database...');
      _database = await openDatabase(dbPath);

      _updateStatus('Loading articles...');
      await _loadTitlesFromDatabase();

      _updateStatus('Initializing viewer...');
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) => debugPrint('Page started: $url'),
            onPageFinished: (String url) => debugPrint('Page finished: $url'),
            onWebResourceError: (error) => debugPrint('WebView error: $error'),
          ),
        )
        ..loadHtmlString(_getWelcomeHtml());

      _updateStatus('Ready!');
      if (mounted) setState(() => _isReady = true);
    } catch (e) {
      _updateStatus('Error: $e');
      debugPrint('Initialization error: $e');
    }
  }

  void _updateStatus(String status) {
    if (mounted) setState(() => _loadingStatus = status);
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  String _getWelcomeHtml() {
    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
              background: linear-gradient(135deg, #f5f7fa 0%, #e8eef4 100%);
              min-height: 100vh;
            }
            .hero {
              background: linear-gradient(135deg, ${_colorToHex(widget.primaryColor)} 0%, ${_colorToHex(widget.primaryColor.withOpacity(0.8))} 100%);
              padding: 40px 20px;
              text-align: center;
              color: white;
              border-radius: 0 0 30px 30px;
              margin-bottom: 20px;
            }
            .hero-icon { font-size: 64px; margin-bottom: 16px; }
            .hero h1 { font-size: 28px; font-weight: 700; margin-bottom: 8px; }
            .hero p { font-size: 16px; opacity: 0.95; }
            .stats-container { max-width: 800px; margin: -30px auto 20px; padding: 0 16px; }
            .stats-card {
              background: white;
              border-radius: 20px;
              padding: 24px;
              box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            }
            .stats-grid {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
              gap: 20px;
              text-align: center;
            }
            .stat-number {
              font-size: 32px;
              font-weight: bold;
              color: ${_colorToHex(widget.primaryColor)};
            }
            .stat-label { font-size: 12px; color: #666; margin-top: 4px; }
            .feature-section { max-width: 800px; margin: 40px auto; padding: 0 20px; }
            .feature-grid {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
              gap: 16px;
            }
            .feature-card {
              background: white;
              padding: 20px;
              border-radius: 16px;
              text-align: center;
              box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            }
            .feature-icon { font-size: 32px; margin-bottom: 8px; }
            .feature-title { font-weight: 600; color: #333; font-size: 14px; }
            .search-tips {
              background: white;
              border-radius: 16px;
              padding: 20px;
              margin-top: 20px;
              border-left: 4px solid ${_colorToHex(widget.primaryColor)};
            }
            .tip-title { font-weight: 600; margin-bottom: 12px; }
            .tip-item { padding: 6px 0; color: #555; font-size: 13px; }
          </style>
        </head>
        <body>
          <div class="hero">
            <div class="hero-icon">${widget.icon == Icons.medical_services ? '🏥' : '📚'}</div>
            <h1>${widget.title}</h1>
            <p>Your complete offline medical reference</p>
          </div>
          <div class="stats-container">
            <div class="stats-card">
              <div class="stats-grid">
                <div><div class="stat-number">${_allTitles.length}</div><div class="stat-label">Articles</div></div>
                <div><div class="stat-number">100%</div><div class="stat-label">Offline</div></div>
                <div><div class="stat-number">⚡</div><div class="stat-label">Fast Search</div></div>
              </div>
            </div>
          </div>
          <div class="feature-section">
            <div class="feature-grid">
              <div class="feature-card"><div class="feature-icon">🔍</div><div class="feature-title">Smart Search</div></div>
              <div class="feature-card"><div class="feature-icon">📖</div><div class="feature-title">Full Content</div></div>
              <div class="feature-card"><div class="feature-icon">⚡</div><div class="feature-title">Instant Loading</div></div>
            </div>
            <div class="search-tips">
              <div class="tip-title">📖 Search Tips</div>
              <div class="tip-item">• Search by disease, symptom, or treatment</div>
              <div class="tip-item">• Try: "Syphilis", "Emergency", "Antibiotic"</div>
              <div class="tip-item">• Type partial titles for suggestions</div>
            </div>
          </div>
        </body>
      </html>
    ''';
  }

  Future<void> _loadTitlesFromDatabase() async {
    try {
      final results = await _database.query('articles', columns: ['title']);
      _allTitles = results
          .map((r) => r['title']?.toString() ?? '')
          .where((title) => title.isNotEmpty)
          .toList();
      _recentArticles = _allTitles.take(5).toList();
    } catch (dbError) {
      _updateStatus('Database error: $dbError');
    }
  }

  Future<List<String>> _getSuggestions(String query) async {
    if (!_isReady || _allTitles.isEmpty) return [];
    final lower = query.toLowerCase().trim();
    if (lower.isEmpty) return _recentArticles;
    return _allTitles
        .where((title) => title.toLowerCase().contains(lower))
        .take(20)
        .toList();
  }

  String _extractRedirectTarget(String content) {
    final refreshRegex = RegExp(r'<meta\s+http-equiv="refresh"\s+content="0;url=([^"]+)"');
    final match = refreshRegex.firstMatch(content);
    return match?.group(1) ?? '';
  }

  Future<void> _loadArticle(String selectedTitle) async {
    try {
      if (mounted) {
        _webViewController.loadHtmlString('''
          <!DOCTYPE html>
          <html>
            <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
            <body style="display:flex;justify-content:center;align-items:center;height:100vh;margin:0;background:#f5f7fa;">
              <div style="text-align:center;">
                <div style="border:4px solid #f3f3f3;border-top:4px solid ${_colorToHex(widget.primaryColor)};border-radius:50%;width:50px;height:50px;animation:spin 1s linear infinite;margin:20px auto;"></div>
                <p>Loading "$selectedTitle"...</p>
                <style>@keyframes spin{0%{transform:rotate(0deg);}100%{transform:rotate(360deg);}}</style>
              </div>
            </body>
          </html>
        ''');
      }

      Future<String> getFinalContent(String title, {Set<String> visited = const {}}) async {
        if (visited.contains(title)) return '<p>Circular redirect detected</p>';
        final results = await _database.rawQuery('SELECT content FROM articles WHERE title = ?', [title]);
        if (results.isEmpty) return '<p>Article not found: $title</p>';
        String content = results.first['content'] as String? ?? '';
        final redirectTarget = _extractRedirectTarget(content);
        if (redirectTarget.isNotEmpty) {
          return getFinalContent(redirectTarget, visited: {...visited, title});
        }
        return content;
      }

      String finalContent = await getFinalContent(selectedTitle);
      if (finalContent.isNotEmpty && mounted) {
        String htmlToLoad = finalContent.trim().startsWith('<!DOCTYPE') || finalContent.trim().startsWith('<html')
            ? finalContent
            : '''
                <!DOCTYPE html>
                <html>
                  <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <style>
                      body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f7fa; margin: 0; padding: 20px; }
                      .container { max-width: 800px; margin: 0 auto; }
                      .header { background: white; border-radius: 20px; padding: 30px; margin-bottom: 20px; border-left: 5px solid ${_colorToHex(widget.primaryColor)}; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
                      h1 { font-size: 28px; margin: 0 0 8px 0; color: #2c3e50; }
                      .content { background: white; border-radius: 20px; padding: 30px; line-height: 1.8; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
                      .content p { margin-bottom: 16px; }
                      .content h2 { color: ${_colorToHex(widget.primaryColor)}; margin: 24px 0 12px; }
                      @media (max-width: 600px) { .header, .content { padding: 20px; } h1 { font-size: 24px; } }
                    </style>
                  </head>
                  <body>
                    <div class="container">
                      <div class="header"><h1>$selectedTitle</h1></div>
                      <div class="content">$finalContent</div>
                    </div>
                  </body>
                </html>
              ''';

        _articleCache[selectedTitle] = htmlToLoad;
        await _webViewController.loadHtmlString(htmlToLoad);
        if (mounted) {
          setState(() => _currentTitle = selectedTitle);
          if (!_recentArticles.contains(selectedTitle)) {
            _recentArticles.insert(0, selectedTitle);
            if (_recentArticles.length > 10) _recentArticles.removeLast();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _webViewController.loadHtmlString('''
          <!DOCTYPE html>
          <html>
            <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
            <body style="display:flex;justify-content:center;align-items:center;height:100vh;margin:0;background:#f5f7fa;">
              <div style="background:white;border-radius:20px;padding:40px;text-align:center;max-width:400px;margin:20px;">
                <div style="font-size:64px;">⚠️</div>
                <h2 style="color:#e74c3c;">Error Loading Article</h2>
                <p style="color:#7f8c8d;">$e</p>
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.primaryColor.withOpacity(0.05), Colors.white],
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.primaryColor,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(widget.icon, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentTitle != widget.title ? _currentTitle : widget.title,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_currentTitle == widget.title)
                                Text(
                                  '${_allTitles.length} articles available',
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                                ),
                            ],
                          ),
                        ),
                        if (_isReady && _allTitles.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_allTitles.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TypeAheadField<String>(
                      controller: _searchController,
                      suggestionsCallback: _getSuggestions,
                      builder: (context, controller, focusNode) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            enabled: _isReady,
                            decoration: InputDecoration(
                              hintText: _isReady ? 'Search articles...' : 'Loading...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: Icon(Icons.search, color: widget.primaryColor),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () => _searchController.clear(),
                              )
                                  : null,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty && _isReady) _loadArticle(value);
                            },
                          ),
                        );
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          leading: Icon(Icons.article, color: widget.primaryColor),
                          title: Text(suggestion, style: const TextStyle(fontSize: 14)),
                          trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
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
                  ],
                ),
              ),
              Expanded(
                child: _isReady
                    ? WillPopScope(
                  onWillPop: () async {
                    if (_currentTitle != widget.title) {
                      _webViewController.loadHtmlString(_getWelcomeHtml());
                      _searchController.clear();
                      setState(() => _currentTitle = widget.title);
                      return false;
                    }
                    return true;
                  },
                  child: WebViewWidget(controller: _webViewController),
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(_loadingStatus, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isReady && _currentTitle != widget.title
          ? FloatingActionButton.extended(
        onPressed: () {
          _webViewController.loadHtmlString(_getWelcomeHtml());
          _searchController.clear();
          setState(() => _currentTitle = widget.title);
        },
        label: const Text('Home'),
        icon: const Icon(Icons.home),
        backgroundColor: widget.primaryColor,
      )
          : null,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _database.close().catchError((e) => debugPrint('DB close error: $e'));
    super.dispose();
  }
}