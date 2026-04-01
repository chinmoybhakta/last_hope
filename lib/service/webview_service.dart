import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewService {
  WebViewController? _controller;
  String? _currentTitle;
  final Map<String, String> _articleCache = {};
  
  WebViewController get controller {
    _controller ??= WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000));
    return _controller!;
  }
  
  Future<void> loadWelcomePage(
    String title,
    Color primaryColor,
    IconData icon,
    int articleCount,
  ) async {
    final html = _buildWelcomeHtml(title, primaryColor, icon, articleCount);
    await controller.loadHtmlString(html);
    _currentTitle = title;
  }
  
  Future<void> loadArticle(
    String title,
    String content,
    Color primaryColor,
    bool isFromCache,
  ) async {
    if (!isFromCache && _articleCache.containsKey(title)) {
      await controller.loadHtmlString(_articleCache[title]!);
      _currentTitle = title;
      return;
    }
    
    final html = _buildArticleHtml(title, content, primaryColor);
    _articleCache[title] = html;
    await controller.loadHtmlString(html);
    _currentTitle = title;
  }
  
  Future<void> showLoading(String title, Color primaryColor) async {
    final html = _buildLoadingHtml(title, primaryColor);
    await controller.loadHtmlString(html);
  }
  
  Future<void> showError(String error) async {
    final html = _buildErrorHtml(error);
    await controller.loadHtmlString(html);
  }
  
  String _buildWelcomeHtml(String title, Color primaryColor, IconData icon, int articleCount) {
    final iconChar = icon == Icons.medical_services ? '🏥' : '📚';
    final colorHex = '#${primaryColor.toARGB32().toRadixString(16).substring(2)}';
    
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
              background: linear-gradient(135deg, $colorHex 0%, ${primaryColor.withValues(alpha: 0.8)} 100%);
              padding: 40px 20px;
              text-align: center;
              color: white;
              border-radius: 0 0 30px 30px;
              margin-bottom: 20px;
            }
            .hero-icon { font-size: 64px; margin-bottom: 16px; }
            .hero h1 { font-size: 28px; font-weight: 700; margin-bottom: 8px; }
            .hero p { font-size: 16px; opacity: 0.95; color: #555; }
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
              color: $colorHex;
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
              border-left: 4px solid $colorHex;
            }
            .tip-title { font-weight: 600; margin-bottom: 12px; }
            .tip-item { padding: 6px 0; color: #555; font-size: 13px; }
          </style>
        </head>
        <body>
          <div class="hero">
            <div class="hero-icon">$iconChar</div>
          </div>
          <div class="stats-container">
            <div class="stats-card">
              <div class="stats-grid">
                <div><div class="stat-number">$articleCount</div><div class="stat-label">Articles</div></div>
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
  
  String _buildArticleHtml(String title, String content, Color primaryColor) {
    final colorHex = '#${primaryColor.toARGB32().toRadixString(16).substring(2)}';
    final finalContent = _extractAndCleanContent(content);
    
    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f7fa; margin: 0; padding: 20px; }
            .container { max-width: 800px; margin: 0 auto; }
            .header { background: white; border-radius: 20px; padding: 30px; margin-bottom: 20px; border-left: 5px solid $colorHex; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
            h1 { font-size: 28px; margin: 0 0 8px 0; color: #2c3e50; }
            .content { background: white; border-radius: 20px; padding: 30px; line-height: 1.8; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
            .content p { margin-bottom: 16px; }
            .content h2 { color: $colorHex; margin: 24px 0 12px; }
            .content h3 { color: #2c3e50; margin: 20px 0 10px; }
            @media (max-width: 600px) { .header, .content { padding: 20px; } h1 { font-size: 24px; } }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header"><h1>$title</h1></div>
            <div class="content">$finalContent</div>
          </div>
        </body>
      </html>
    ''';
  }
  
  String _buildLoadingHtml(String title, Color primaryColor) {
    final colorHex = '#${primaryColor.toARGB32().toRadixString(16).substring(2)}';
    return '''
      <!DOCTYPE html>
      <html>
        <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
        <body style="display:flex;justify-content:center;align-items:center;height:100vh;margin:0;background:#f5f7fa;">
          <div style="text-align:center;">
            <div style="border:4px solid #f3f3f3;border-top:4px solid $colorHex;border-radius:50%;width:50px;height:50px;animation:spin 1s linear infinite;margin:20px auto;"></div>
            <p>Loading "$title"...</p>
            <style>@keyframes spin{0%{transform:rotate(0deg);}100%{transform:rotate(360deg);}}</style>
          </div>
        </body>
      </html>
    ''';
  }
  
  String _buildErrorHtml(String error) {
    return '''
      <!DOCTYPE html>
      <html>
        <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
        <body style="display:flex;justify-content:center;align-items:center;height:100vh;margin:0;background:#f5f7fa;">
          <div style="background:white;border-radius:20px;padding:40px;text-align:center;max-width:400px;margin:20px;">
            <div style="font-size:64px;">⚠️</div>
            <h2 style="color:#e74c3c;">Error Loading Article</h2>
            <p style="color:#7f8c8d;">$error</p>
          </div>
        </body>
      </html>
    ''';
  }
  
  String _extractAndCleanContent(String content) {
    // Remove redirect meta tags
    final redirectRegex = RegExp(r'<meta\s+http-equiv="refresh"[^>]*>');
    String cleaned = content.replaceAll(redirectRegex, '');
    
    // Extract redirect target if present
    final refreshRegex = RegExp(r'<meta\s+http-equiv="refresh"\s+content="0;url=([^"]+)"');
    final match = refreshRegex.firstMatch(content);
    if (match != null) {
      return ''; // Return empty to indicate redirect
    }
    
    return cleaned;
  }
  
  String? extractRedirectTarget(String content) {
    final refreshRegex = RegExp(r'<meta\s+http-equiv="refresh"\s+content="0;url=([^"]+)"');
    final match = refreshRegex.firstMatch(content);
    return match?.group(1);
  }
  
  String? getCurrentTitle() => _currentTitle;
  
  void clearCache() {
    _articleCache.clear();
  }
  
  void dispose() {
    _controller = null;
    _articleCache.clear();
  }
}