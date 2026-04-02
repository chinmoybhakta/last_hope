import 'package:flutter/material.dart';
import 'package:last_hope_nasa/model/comic_model.dart';
import 'package:pdfx/pdfx.dart';

class ReaderScreen extends StatefulWidget {
  final Comic comic;

  const ReaderScreen({
    super.key,
    required this.comic,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late PdfControllerPinch _pdfController;
  int _totalPages = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _initializePdf();
  }

  Future<void> _initializePdf() async {
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openFile(widget.comic.filePath),
    );
    
    final document = await PdfDocument.openFile(widget.comic.filePath);
    setState(() {
      _totalPages = document.pagesCount;
    });
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      _pdfController.jumpToPage(_currentPage - 1);
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      _pdfController.jumpToPage(_currentPage + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.comic.title),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                _totalPages > 0 ? 'Page $_currentPage of $_totalPages' : 'Loading...',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: _totalPages == 0
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                PdfViewPinch(
                  controller: _pdfController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
                // Left tap zone for previous page
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width / 3,
                  child: GestureDetector(
                    onTap: _goToPreviousPage,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                // Right tap zone for next page
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width / 3,
                  child: GestureDetector(
                    onTap: _goToNextPage,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}