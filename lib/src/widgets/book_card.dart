import 'package:flutter/material.dart';
import 'package:ebook_reader/src/models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final Function(Book) onReadPressed;

  const BookCard({
    Key? key,
    required this.book,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onReadPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isHorizontal =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Card(
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () => onReadPressed(book),
                child: Image.network(
                  book.coverUrl,
                  fit: BoxFit.cover,
                  height: isHorizontal ? 190 : 200,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isHorizontal ? 8 : 12,
                      ),
                    ),
                    Text(
                      'by ${book.author}',
                      style: TextStyle(
                        fontSize: isHorizontal ? 8 : 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: isHorizontal ? -10 : -10,
            right: isHorizontal ? -10 : -10,
            child: IconButton(
              icon: const Icon(Icons.bookmark),
              iconSize: isHorizontal ? 25 : 35,
              color: isFavorite
                  ? const Color.fromARGB(255, 236, 50, 36)
                  : const Color.fromARGB(255, 87, 87, 87),
              onPressed: onFavoritePressed,
            ),
          ),
        ],
      ),
    );
  }
}
