import 'package:flutter/material.dart';
import 'package:ebook_reader/src/models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback onReadPressed;

  const BookCard({
    Key? key,
    required this.book,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onReadPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(book.coverUrl, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(book.title),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: onFavoritePressed,
              ),
              IconButton(
                icon: Icon(Icons.read_more),
                onPressed: onReadPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
