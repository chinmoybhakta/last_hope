import 'package:flutter/material.dart';
import 'package:last_hope_nasa/model/comic_model.dart';
import 'package:last_hope_nasa/screen/reader_screen.dart';
import 'package:last_hope_nasa/service/cover_extractor.dart';
import 'package:last_hope_nasa/service/pdf_helper.dart';
import 'package:last_hope_nasa/widget/comic_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Comic> comics = [];
  bool isLoading = true;
  bool isLoadingCovers = false;

  @override
  void initState() {
    super.initState();
    loadComics();
  }

  Future<void> loadComics() async {
    setState(() => isLoading = true);

    final pdfFiles = await PdfHelper.loadLocalPdfs();

    comics = pdfFiles.asMap().entries.map((entry) {
      final index = entry.key;
      final file = entry.value;
      return Comic(
        id: index.toString(),
        title: PdfHelper.getFileName(file.path),
        filePath: file.path,
      );
    }).toList();

    setState(() => isLoading = false);

    // Load covers in background
    _loadAllCovers();
  }

  Future<void> _loadAllCovers() async {
    setState(() => isLoadingCovers = true);

    // Load covers for all comics
    for (int i = 0; i < comics.length; i++) {
      final comic = comics[i];
      final coverPath = await CoverExtractor.getCoverPath(comic.filePath);

      if (coverPath != null && mounted) {
        setState(() {
          comics[i].coverPath = coverPath;
        });
      }
    }

    if (mounted) {
      setState(() => isLoadingCovers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comic Reader'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: isLoadingCovers
            ? [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : comics.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No comics found!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add PDF files to assets/comics/ folder',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: comics.length,
              itemBuilder: (context, index) {
                return ComicCard(
                  comic: comics[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ReaderScreen(comic: comics[index]),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
