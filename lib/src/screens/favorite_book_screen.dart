import 'dart:convert';

import 'package:ReadUP/src/models/book.dart';
import 'package:ReadUP/src/services/book_service.dart';
import 'package:ReadUP/src/widgets/book_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

class FavoriteBooksScreen extends StatefulWidget {
  final List<Book> books;
  final Function(Book) onFavoriteToggled;

  const FavoriteBooksScreen({
    Key? key,
    required this.books,
    required this.onFavoriteToggled,
  }) : super(key: key);

  @override
  _FavoriteBooksScreenState createState() => _FavoriteBooksScreenState();
}

class _FavoriteBooksScreenState extends State<FavoriteBooksScreen> {
  late SharedPreferences prefs;
  List<int> favoriteBookIds = [];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  void _initSharedPreferences() {
    _prefs.then((SharedPreferences prefs) {
      String value = prefs.getString('books_id') ?? '';
      favoriteBookIds = utf8.encode(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBookList(),
    );
  }

  Widget _buildBookList() {
    final List<Book> favoriteBooksCopy = List.from(widget.books);

    return favoriteBooksCopy.isNotEmpty
        ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              crossAxisSpacing: 6.0,
              mainAxisSpacing: 6.0,
              childAspectRatio: 0.7,
            ),
            itemCount: favoriteBooksCopy.length,
            itemBuilder: (context, index) {
              final book = favoriteBooksCopy[index];
              return BookCard(
                book: book,
                isFavorite: true,
                onFavoritePressed: () async {
                  widget.onFavoriteToggled(book);

                  await Future.delayed(const Duration(milliseconds: 300));

                  setState(() {
                    widget.books.remove(book);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Livro removido dos favoritos: ${book.title}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                onReadPressed: (Book selectedBook) {
                  _downloadAndOpenBook(context, selectedBook);
                },
              );
            },
          )
        : const Center(
            child: Text('Nenhum livro favorito.'),
          );
  }

  Future<void> _downloadAndOpenBook(BuildContext context, Book book) async {
    try {
      final String downloadedBookPath =
          await BookService().downloadOrOpenBook(book);

      VocsyEpub.setConfig(
        themeColor: Theme.of(context).primaryColor,
        identifier: "ABook",
        scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
        allowSharing: true,
        enableTts: true,
        nightMode: true,
      );

      VocsyEpub.open(downloadedBookPath);
    } catch (error) {
      print('Erro ao abrir o livro: $error');
    }
  }
}
