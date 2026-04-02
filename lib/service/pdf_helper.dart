import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class PdfHelper {
  static Future<List<File>> loadLocalPdfs() async {
    final directory = await getApplicationDocumentsDirectory();
    final comicDir = Directory('${directory.path}/comics');

    if (!await comicDir.exists()) {
      await comicDir.create(recursive: true);
      await _copyAssetsToLocal(comicDir);
    }

    return comicDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.pdf'))
        .toList();
  }

  static Future<void> _copyAssetsToLocal(Directory comicDir) async {
    try {
      // List your PDF files here - update with your actual PDF names
      final pdfFiles = [
        'astrobiology-issue-1-mobile.pdf',
        'astrobiobot-issue-1-full.pdf',
        'issue2_5th_edition_lowres.pdf',
        'astrobio_novel_3_3rd_print_2023_lowres.pdf',
        'astrobio_novel_4_4thedition_lowres.pdf',
        'astrobio_novel_5_firstedition_lowres.pdf',
        'astrobiology_issue6_lowres.pdf',
        'issue7_mobile.pdf',
        'astrobiology_issue_8_1st_edition_mobile.pdf',
        'astrobio_novel_9_1st_edition_mobile.pdf',
      ];

      for (String pdfFile in pdfFiles) {
        try {
          final byteData = await rootBundle.load('asset/$pdfFile');
          final file = File('${comicDir.path}/$pdfFile');
          if (!await file.exists()) {
            await file.writeAsBytes(byteData.buffer.asUint8List());
          }
        } catch (e) {
          log('Error copying $pdfFile: $e');
        }
      }
    } catch (e) {
      log('Error copying assets: $e');
    }
  }

  // Get just the filename from path
  static String getFileName(String path) {
    return path.split('/').last.replaceAll('.pdf', '');
  }
}





// final pdfFiles = [
//         'astrobiology-issue-1-mobile.pdf',
//         'astrobiobot-issue-1-full.pdf',
//         'issue2_5th_edition_lowres.pdf',
//         'astrobio_novel_3_3rd_print_2023_lowres.pdf',
//         'astrobio_novel_4_4thedition_lowres.pdf',
//         'astrobio_novel_5_firstedition_lowres.pdf',
//         'astrobiology_issue6_lowres.pdf',
//         'issue7_mobile.pdf',
//         'astrobiology_issue_8_1st_edition_mobile.pdf',
//         'astrobio_novel_9_1st_edition_mobile.pdf',
//       ];