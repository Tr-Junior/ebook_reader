import 'package:ebook_reader/src/models/book.dart';
import 'package:flutter/material.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReaderScreen(book: book),
              ),
            );
          },
          child: const Text('Ler Livro'),
        ),
      ),
    );
  }
}
