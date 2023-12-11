import 'package:flutter/material.dart';
import 'package:ebook_reader/src/models/book.dart';
import 'package:ebook_reader/src/widgets/book_card.dart';

class FavoriteBooksScreen extends StatelessWidget {
  final List<Book> books;

  const FavoriteBooksScreen({Key? key, required this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livros Favoritos'),
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return BookCard(
            book: book,
            isFavorite: true,
            onFavoritePressed: () {},
            onReadPressed: () {},
          );
        },
      ),
    );
  }
}
