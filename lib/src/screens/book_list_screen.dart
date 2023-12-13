import 'package:flutter/material.dart';
import 'package:read_up/src/models/book.dart';
import 'package:read_up/src/widgets/book_card.dart';

class BookListScreen extends StatelessWidget {
  final List<Book> books;
  final List<int> favoriteBookIds;
  final Function(Book) toggleFavorite;
  final Function(Book) downloadAndOpenBook;
  final bool isFavoriteScreen;

  BookListScreen({
    required this.books,
    required this.favoriteBookIds,
    required this.toggleFavorite,
    required this.downloadAndOpenBook,
    required this.isFavoriteScreen,
  });

  @override
  Widget build(BuildContext context) {
    return books.isNotEmpty
        ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              crossAxisSpacing: 6.0,
              mainAxisSpacing: 6.0,
              childAspectRatio: 0.7,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                book: book,
                isFavorite: favoriteBookIds.contains(book.id),
                onFavoritePressed: () => toggleFavorite(book),
                onReadPressed: downloadAndOpenBook,
              );
            },
          )
        : Center(
            child: Text(
              isFavoriteScreen
                  ? 'Seus livros favoritos aparecem aqui.'
                  : 'Nenhum livro disponível.',
            ),
          );
  }
}
