import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swarn_abhushan/utils/constant.dart';

class PdfViewerScreen extends StatefulWidget {
  final Uint8List pdfBytes;
  final String fileName;

  const PdfViewerScreen({
    super.key,
    required this.pdfBytes,
    required this.fileName,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    saveTempFile();
  }

  Future<void> saveTempFile() async {
    final dir = await getTemporaryDirectory();
    final filePath = "${dir.path}/${widget.fileName}";

    final file = File(filePath);
    await file.writeAsBytes(widget.pdfBytes);

    setState(() => localPath = filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice PDF"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: localPath == null ? null : () => sharePdf(widget.pdfBytes, widget.fileName),
          )
        ],
      ),
      body: localPath == null
          ? const Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: localPath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
            ),
    );
  }
}
