import 'package:ebook_reader/src/models/book.dart';
import 'package:flutter/material.dart';

class ReaderScreen extends StatelessWidget {
  final Book book;

  const ReaderScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: EpubViewer(bookUrl: book.coverUrl),
    );
  }

  EpubViewer({required String bookUrl}) {}
}
