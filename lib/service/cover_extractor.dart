import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

class CoverExtractor {
  static const String coverFolder = 'comic_covers';
  
  // Generate a unique cache key for each PDF
  static String _getCacheKey(String pdfPath) {
    return pdfPath.hashCode.toString();
  }

  // Get cover image path (creates if doesn't exist)
  static Future<String?> getCoverPath(String pdfPath) async {
    try {
      final cacheKey = _getCacheKey(pdfPath);
      final coverFile = await _getCoverFile(cacheKey);
      
      // Check if cover already exists
      if (await coverFile.exists()) {
        return coverFile.path;
      }
      
      // Extract first page as image
      final coverPath = await _extractFirstPage(pdfPath, coverFile);
      return coverPath;
    } catch (e) {
      log('Error getting cover for $pdfPath: $e');
      return null;
    }
  }

  static Future<File> _getCoverFile(String cacheKey) async {
    final directory = await getApplicationDocumentsDirectory();
    final coverDir = Directory('${directory.path}/$coverFolder');
    
    if (!await coverDir.exists()) {
      await coverDir.create(recursive: true);
    }
    
    return File('${coverDir.path}/$cacheKey.jpg');
  }

  static Future<String?> _extractFirstPage(String pdfPath, File outputFile) async {
    PdfDocument? document;
    
    try {
      // Open PDF document
      document = await PdfDocument.openFile(pdfPath);
      
      if (document.pagesCount == 0) {
        return null;
      }
      
      // Get first page
      final page = await document.getPage(1);
      
      // Render page to image (width: 400px for thumbnail)
      final pageImage = await page.render(
        width: 400,
        height: 600,
      );
      
      // Save image to file
      final imageFile = File(outputFile.path);
      await imageFile.writeAsBytes(pageImage!.bytes);
      
      return imageFile.path;
    } catch (e) {
      log('Error extracting cover: $e');
      return null;
    } finally {
      document?.close();
    }
  }

  // Clear all cached covers (optional)
  static Future<void> clearAllCovers() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final coverDir = Directory('${directory.path}/$coverFolder');
      
      if (await coverDir.exists()) {
        await coverDir.delete(recursive: true);
      }
    } catch (e) {
      log('Error clearing covers: $e');
    }
  }
}