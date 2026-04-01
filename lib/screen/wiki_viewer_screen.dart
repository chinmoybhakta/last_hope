import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:last_hope_wiki/model/wiki_models.dart';
import 'package:last_hope_wiki/service/database_service.dart';
import 'package:last_hope_wiki/service/webview_service.dart';
import 'package:last_hope_wiki/widget/article_viewer.dart';
import 'package:last_hope_wiki/widget/custom_search_bar.dart';
import 'package:last_hope_wiki/widget/loading_indicator.dart';

class WikiViewerScreen extends StatefulWidget {
  final DatabaseInfo databaseInfo;
  
  const WikiViewerScreen({
    super.key,
    required this.databaseInfo,
  });

  @override
  State<WikiViewerScreen> createState() => _WikiViewerScreenState();
}

class _WikiViewerScreenState extends State<WikiViewerScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _dbService = DatabaseService();
  final WebViewService _webViewService = WebViewService();
  final TextEditingController _searchController = TextEditingController();
  
  List<String> _allTitles = [];
  String _currentTitle = '';
  bool _isReady = false;
  String _loadingStatus = 'Initializing...';
  List<String> _recentArticles = [];
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _currentTitle = widget.databaseInfo.title;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    _initializeEverything();
  }
  
  Future<void> _initializeEverything() async {
    try {
      _updateStatus('Loading database...');
      final db = await _dbService.getDatabase(
        widget.databaseInfo.name,
        widget.databaseInfo.assetPath,
      );
      
      _updateStatus('Loading articles...');
      _allTitles = await _dbService.getAllTitles(db);
      _recentArticles = _allTitles.take(5).toList();
      
      _updateStatus('Initializing viewer...');
      await _webViewService.loadWelcomePage(
        widget.databaseInfo.title,
        widget.databaseInfo.primaryColor,
        widget.databaseInfo.icon,
        _allTitles.length,
      );
      
      _updateStatus('Ready!');
      if (mounted) setState(() => _isReady = true);
    } catch (e) {
      _updateStatus('Error: $e');
      log('Initialization error: $e');
    }
  }
  
  void _updateStatus(String status) {
    if (mounted) setState(() => _loadingStatus = status);
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
  
  Future<String?> _getFinalContent(String title, {Set<String> visited = const {}}) async {
    if (visited.contains(title)) return null;
    
    final db = await _dbService.getDatabase(
      widget.databaseInfo.name,
      widget.databaseInfo.assetPath,
    );
    final content = await _dbService.getArticleContent(db, title);
    if (content == null) return null;
    
    final redirectTarget = _webViewService.extractRedirectTarget(content);
    if (redirectTarget != null && redirectTarget.isNotEmpty) {
      return _getFinalContent(redirectTarget, visited: {...visited, title});
    }
    
    return content;
  }
  
  Future<void> _loadArticle(String selectedTitle) async {
    try {
      await _webViewService.showLoading(selectedTitle, widget.databaseInfo.primaryColor);
      
      final content = await _getFinalContent(selectedTitle);
      
      if (content != null && mounted) {
        await _webViewService.loadArticle(
          selectedTitle,
          content,
          widget.databaseInfo.primaryColor,
          false,
        );
        
        setState(() {
          _currentTitle = selectedTitle;
          if (!_recentArticles.contains(selectedTitle)) {
            _recentArticles.insert(0, selectedTitle);
            if (_recentArticles.length > 10) _recentArticles.removeLast();
          }
        });
      } else {
        await _webViewService.showError('Article not found: $selectedTitle');
      }
    } catch (e) {
      if (mounted) {
        await _webViewService.showError(e.toString());
      }
    }
  }
  
  Future<void> _goHome() async {
    await _webViewService.loadWelcomePage(
      widget.databaseInfo.title,
      widget.databaseInfo.primaryColor,
      widget.databaseInfo.icon,
      _allTitles.length,
    );
    _searchController.clear();
    setState(() => _currentTitle = widget.databaseInfo.title);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _webViewService.dispose();
    _dbService.closeDatabase();
    super.dispose();
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
              colors: [
                widget.databaseInfo.primaryColor.withValues(alpha: 0.05),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isReady
                    ? PopScope(
                        canPop: _currentTitle == widget.databaseInfo.title,
                        onPopInvokedWithResult: (didPop, result) async {
                          if (!didPop && _currentTitle != widget.databaseInfo.title) {
                            await _goHome();
                          }
                        },
                        child: ArticleViewer(controller: _webViewService.controller),
                      )
                    : LoadingIndicator(
                        message: _loadingStatus,
                        color: widget.databaseInfo.primaryColor,
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isReady && _currentTitle != widget.databaseInfo.title
          ? FloatingActionButton.extended(
              onPressed: _goHome,
              label: const Text('Home'),
              icon: const Icon(Icons.home),
              backgroundColor: widget.databaseInfo.primaryColor,
            )
          : null,
    );
  }
  
  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: widget.databaseInfo.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.databaseInfo.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentTitle != widget.databaseInfo.title
                          ? _currentTitle
                          : widget.databaseInfo.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_currentTitle == widget.databaseInfo.title)
                      Text(
                        '${_allTitles.length} articles available',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (_isReady && _allTitles.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_allTitles.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          CustomSearchBar(
            controller: _searchController,
            enabled: _isReady,
            suggestionsCallback: _getSuggestions,
            onSelected: _loadArticle,
            primaryColor: widget.databaseInfo.primaryColor,
          ),
        ],
      ),
    );
  }
}