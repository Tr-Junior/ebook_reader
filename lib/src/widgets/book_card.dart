import 'package:flutter/material.dart';
import 'package:ebook_reader/src/models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final Function(Book) onReadPressed;

  const BookCard({
    super.key,
    required this.book,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onReadPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () {
                  onReadPressed(book);
                },
                child: Image.network(book.coverUrl, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(book.title),
              ),
              // A Row foi removida aqui.
            ],
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            iconSize: 40,
            color: isFavorite
                ? const Color.fromARGB(255, 236, 50, 36)
                : const Color.fromARGB(255, 87, 87, 87),
            onPressed: onFavoritePressed,
          ),
        ],
      ),
    );
  }
}
